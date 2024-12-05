
// Lowest Level LCD FSM States
typedef enum logic [4:0]    {s0_powerup, 
  s1_set_f1, s2_write_f1, s3_off_f1, 
            s4_write_f2, s5_off_f2, 
            s6_write_f3, s7_off_f3,
  s8_set_f4, s9_write_f4, s10_off_f4,
  s11_set_f5, s12_write_f5, s13_off_f5,
  s14_set_f6, s15_write_f6, s16_off_f6,
  s17_set_f7, s18_write_f7, s19_off_f7,
  s20_set_f8, s21_write_f8, s22_off_f8,
  boot, idle,
  set, write, off} 
  lcd_fsm_statetype;

module lcdFSM(
    input   logic   reset,
    input   logic   clk,
    input   logic   data_ready,
    input   logic   [7:0]   d_in,
    input   logic   rs_in,
    output  logic   [7:0]   d,
    output  logic   e,
    output  logic   rs,
    output  logic   busy_flag
    );

  /*
  Instruction Set (some key ones pulled out):
  -Clear display screen                            01	00000001
  -Return cursor home                              02	00000010
  -Shift cursor left                               10	00010000
  -Shift cursor right                              14	00010100
  -Shift display left                              18	00011000
  -Shift display right                             1C	00011100
  -Move cursor to beginning of 1st line            80	10000000
  -Move cursor to beginning to 2nd line            C0	11000000
  -Function Set: 2 lines, 5x7 matrix, 8-bit mode   38	00111000
  -Entry Mode: Cursor moves right on new char      06	00000110

  Initialization Sequence:
  1. Power up	        No Instruction	100ms
  2. Function Set	    8'b00110000	    5ms
  3. Function Set	    8'b00110000	    200us
  4. Function Set	    8'b00110000	    200us
  5. Configure	    8'b00111000	    60us
  6. Display Off	    8'b00001000	    60us
  7. Clear	        8'b00000001	    5ms
  8. Entry Mode Set	8'b00000110	    60us
  9. Display On	    8'b00001100	    60us
  */

  ////////////////////////  Parameters  ////////////////////////////////////////////////////

  /* Note: Clock Frequency on MicroPs iCE40 FPGA is 48MHz. Flag values are rounded up.
					WE CHANGED THE CLOCK FREQUENCY
  parameter integer D_50ns  = 3;    // 0.000000050 * CLK_FREQ
  parameter integer D_250ns = 12;    // 0.000000250 * CLK_FREQ

  parameter integer D_40us  = 1920;    // 0.000040000 * CLK_FREQ
  parameter integer D_60us  = 2880;    // 0.000060000 * CLK_FREQ
  parameter integer D_200us = 9600;    // 0.000200000 * CLK_FREQ

  parameter integer D_2ms   = 96000;    // 0.002000000 * CLK_FREQ
  parameter integer D_5ms   = 240000;    // 0.005000000 * CLK_FREQ
  parameter integer D_100ms = 4800000;    // 0.100000000 * CLK_FREQ*/

  /* Current divided clock frequency is 24 MHz. Flag Values are rounded up.
  parameter integer D_50ns  = 3;    // 0.000000050 * CLK_FREQ
  parameter integer D_250ns = 12;    // 0.000000250 * CLK_FREQ

  parameter integer D_40us  = 960;    // 0.000040000 * CLK_FREQ
  parameter integer D_60us  = 1440;    // 0.000060000 * CLK_FREQ
  parameter integer D_200us = 4800;    // 0.000200000 * CLK_FREQ

  parameter integer D_2ms   = 48000;    // 0.002000000 * CLK_FREQ
  parameter integer D_5ms   = 120000;    // 0.005000000 * CLK_FREQ
  parameter integer D_100ms = 2400000;    // 0.100000000 * CLK_FREQ */

  /* Simulation and FSM test values -- will not work with display! */
  parameter integer D_50ns  = 30;    // 0.000000050 * CLK_FREQ
  parameter integer D_250ns = 30;    // 0.000000250 * CLK_FREQ

  parameter integer D_40us  = 30;    // 0.000040000 * CLK_FREQ
  parameter integer D_60us  = 30;    // 0.000060000 * CLK_FREQ
  parameter integer D_200us = 30;    // 0.000200000 * CLK_FREQ

  parameter integer D_2ms   = 30;    // 0.002000000 * CLK_FREQ
  parameter integer D_5ms   = 30;    // 0.005000000 * CLK_FREQ
  parameter integer D_100ms = 30;    // 0.100000000 * CLK_FREQ

  ////////////////////////  Function Definitions  //////////////////////////////////////////

  `define DF1 8'h30
  `define DF2 8'h30
  `define DF3 8'h30
  `define DF4 8'h38
  `define DF5 8'h08
  `define DF6 8'h01
  `define DF7 8'h06
  `define DF8 8'h0C


  ////////////////////////  Internal Logic  ////////////////////////////////////////////////

  lcd_fsm_statetype state, nextstate;

  logic [23:0] count;

  logic flag_50ns;
  logic flag_250ns;
  logic flag_40us;
  logic flag_60us;
  logic flag_200us;
  logic flag_2ms;
  logic flag_5ms;
  logic flag_100ms;


  ////////////////////////  Registers  /////////////////////////////////////////////////////
  always_ff @(posedge clk) begin

    // State Register
    if (reset) begin    // Active low reset, so if not reset...
      state <= nextstate;   // Update the state
    end
    else begin          // If yes system reset...
      state <= s0_powerup;  // Reset the State
    end

    // Counter Register
    if ( (nextstate!==state) | (~reset) ) begin    // Reset counter when switching states
      count <= 24'h000000;
      flag_50ns  <= 1'b0;
      flag_250ns <= 1'b0;
      flag_40us  <= 1'b0;
      flag_60us  <= 1'b0;
      flag_200us <= 1'b0;
      flag_2ms   <= 1'b0;
      flag_5ms   <= 1'b0;
      flag_100ms <= 1'b0;
    end
    else begin                  // If counter is not cleared...
      count <= count + 1;           // Count Up and Set Flags
      if (count == D_50ns)  flag_50ns  <= 1'b1;
      if (count == D_250ns) flag_250ns <= 1'b1;
      if (count == D_40us)  flag_40us  <= 1'b1;
      if (count == D_60us)  flag_60us  <= 1'b1;
      if (count == D_200us) flag_200us <= 1'b1;
      if (count == D_2ms)   flag_2ms   <= 1'b1;
      if (count == D_5ms)   flag_5ms   <= 1'b1;
      if (count == D_100ms) flag_100ms <= 1'b1;
    end
  end

  ////////////////////////  Next State Logic  //////////////////////////////////////////////
  always_comb begin
  case (state)
    // Power Up Sequence Begins
    s0_powerup:   if (flag_100ms) nextstate = s1_set_f1;    else nextstate = s0_powerup;
    s1_set_f1:    if (flag_50ns)  nextstate = s2_write_f1;  else nextstate = s1_set_f1;
    s2_write_f1:  if (flag_250ns) nextstate = s3_off_f1;    else nextstate = s2_write_f1;
    s3_off_f1:    if (flag_5ms)   nextstate = s4_write_f2;  else nextstate = s3_off_f1;
    s4_write_f2:  if (flag_250ns) nextstate = s5_off_f2;    else nextstate = s4_write_f2;
    s5_off_f2:    if (flag_200us) nextstate = s6_write_f3;  else nextstate = s5_off_f2;
    s6_write_f3:  if (flag_250ns) nextstate = s7_off_f3;    else nextstate = s6_write_f3;
    s7_off_f3:    if (flag_200us) nextstate = s8_set_f4;    else nextstate = s7_off_f3;
    s8_set_f4:    if (flag_50ns)  nextstate = s9_write_f4;  else nextstate = s8_set_f4;
    s9_write_f4:  if (flag_250ns) nextstate = s10_off_f4;   else nextstate = s9_write_f4;
    s10_off_f4:   if (flag_60us)  nextstate = s11_set_f5;   else nextstate = s10_off_f4;
    s11_set_f5:   if (flag_50ns)  nextstate = s12_write_f5; else nextstate = s11_set_f5;
    s12_write_f5: if (flag_250ns) nextstate = s13_off_f5;   else nextstate = s12_write_f5;
    s13_off_f5:   if (flag_60us)  nextstate = s14_set_f6;   else nextstate = s13_off_f5;
    s14_set_f6:   if (flag_50ns)  nextstate = s15_write_f6; else nextstate = s14_set_f6;
    s15_write_f6: if (flag_250ns) nextstate = s16_off_f6;   else nextstate = s15_write_f6;
    s16_off_f6:   if (flag_5ms)   nextstate = s17_set_f7;   else nextstate = s16_off_f6;
    s17_set_f7:   if (flag_50ns)  nextstate = s18_write_f7; else nextstate = s17_set_f7;
    s18_write_f7: if (flag_250ns) nextstate = s19_off_f7;   else nextstate = s18_write_f7;
    s19_off_f7:   if (flag_60us)  nextstate = s20_set_f8;   else nextstate = s19_off_f7;
    s20_set_f8:   if (flag_50ns)  nextstate = s21_write_f8; else nextstate = s20_set_f8;
    s21_write_f8: if (flag_250ns) nextstate = s22_off_f8;   else nextstate = s21_write_f8;
    s22_off_f8:   if (flag_60us)  nextstate = boot;         else nextstate = s22_off_f8;

    boot:   if (flag_50ns)  nextstate = idle;   else nextstate = boot;
    idle:   if (data_ready) nextstate = set;    else nextstate = idle;
    set:    if (flag_50ns)  nextstate = write;  else nextstate = set;
    write:  if (flag_250ns) nextstate = off;    else nextstate = write;
    off:    if (flag_60us)  nextstate = boot;   else nextstate = off;

    default: nextstate = s0_powerup;
  endcase
  end

  ////////////////////////  Output Logic  //////////////////////////////////////////////////
  always_comb begin
  case (state)
    // Power Up Sequence Begins
    s0_powerup:   begin e=0; rs=0; busy_flag=1; d=8'h00; end
    s1_set_f1:    begin e=0; rs=0; busy_flag=1; d=`DF1; end
    s2_write_f1:  begin e=1; rs=0; busy_flag=1; d=`DF1; end
    s3_off_f1:    begin e=0; rs=0; busy_flag=1; d=`DF1; end
    s4_write_f2:  begin e=1; rs=0; busy_flag=1; d=`DF2; end
    s5_off_f2:    begin e=0; rs=0; busy_flag=1; d=`DF2; end
    s6_write_f3:  begin e=1; rs=0; busy_flag=1; d=`DF3; end
    s7_off_f3:    begin e=0; rs=0; busy_flag=1; d=`DF3; end
    s8_set_f4:    begin e=0; rs=0; busy_flag=1; d=`DF4; end
    s9_write_f4:  begin e=1; rs=0; busy_flag=1; d=`DF4; end
    s10_off_f4:   begin e=0; rs=0; busy_flag=1; d=`DF4; end
    s11_set_f5:   begin e=0; rs=0; busy_flag=1; d=`DF5; end
    s12_write_f5: begin e=1; rs=0; busy_flag=1; d=`DF5; end
    s13_off_f5:   begin e=0; rs=0; busy_flag=1; d=`DF5; end
    s14_set_f6:   begin e=0; rs=0; busy_flag=1; d=`DF6; end
    s15_write_f6: begin e=1; rs=0; busy_flag=1; d=`DF6; end
    s16_off_f6:   begin e=0; rs=0; busy_flag=1; d=`DF6; end
    s17_set_f7:   begin e=0; rs=0; busy_flag=1; d=`DF7; end
    s18_write_f7: begin e=1; rs=0; busy_flag=1; d=`DF7; end
    s19_off_f7:   begin e=0; rs=0; busy_flag=1; d=`DF7; end
    s20_set_f8:   begin e=0; rs=0; busy_flag=1; d=`DF8; end
    s21_write_f8: begin e=1; rs=0; busy_flag=1; d=`DF8; end
    s22_off_f8:   begin e=0; rs=0; busy_flag=1; d=`DF8; end

    boot:     begin e=0; rs=0; busy_flag=0; d=8'h00; end
    idle:     begin e=0; rs=0; busy_flag=0; d=8'h00; end
    set:      begin e=0; rs=rs_in; busy_flag=1; d=d_in; end
    write:    begin e=1; rs=rs_in; busy_flag=1; d=d_in; end
    off:      begin e=0; rs=rs_in; busy_flag=1; d=d_in; end

    default: begin e=0; rs=0; busy_flag=1; d=8'h00; end
  endcase
  end

endmodule

module lcdFSM_testbench();

    // Create necessary variables
  logic   reset;
  logic   clk;
  logic   data_ready;
  logic   [7:0]   d_in;
  logic   rs_in;
  logic   [7:0]   d;
  logic   e;
  logic   rs;
  logic   busy_flag;

  // Call DUT module
  lcdFSM dut(reset,clk,data_ready,d_in,rs_in,d,e,rs,busy_flag);

  // Clock cycle and pulse reset (recall active low)
  always begin clk = 1; #5; clk=0; #5; end
  initial begin reset=1; end

  /* // Feed in the desired signals. 
  initial begin 
	  sense = 4'b0000; #53; sense = 4'b0010; #150; sense = 4'b0000;
  end*/

endmodule