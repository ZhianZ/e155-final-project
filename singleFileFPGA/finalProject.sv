
// Controller FSM States
typedef enum logic [4:0] {
        wait_SPI,
        clear_display,
        cursor_home,
        write_letter, write_number} 
  lcd_controller_statetype;

  // Lowest Level FSM States
typedef enum logic [4:0]    {s0_powerup, 
  s1_set_f1, s2_write_f1, s3_off_f1, 
            s4_write_f2, s5_off_f2, 
            s6_write_f3, s7_off_f3,
  s8_set_f4, s9_write_f4, s10_off_f4,
  s11_set_f5, s12_write_f5, s13_off_f5,
  s14_set_f6, s15_write_f6, s16_off_f6,
  s17_set_f7, s18_write_f7, s19_off_f7,
  s20_set_f8, s21_write_f8, s22_off_f8,
  s23_set_f9, s24_write_f9, s25_off_f9,
  
  boot, idle,
  set, write, off} lcd_fsm_statetype;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////  TOP MODULE  ///////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module top(
    input   logic   reset,
    input   logic   sclk,
    input   logic   cs,
    input   logic   sdi,
    output  logic   [7:0]   d,
    output  logic   e,
    output  logic   rs,
	output  logic   led0_P28,
    output  logic   led1_P38,
    output  logic   led2_P42,
    output  logic   led4_PA6,
    output	logic	led5_PA9,
	output	logic	led6_PA10,
    output  logic   laD5_P36,
    output  logic   laD6_P43,
    output  logic   laD7_P37
    );

	//10111101 - 189 hz - G3 Tuesday Night First Test, LCD no light up or do anything. Logic analyzer shows SPI is sending signals.

	logic busy_flag, flag_check;

	//logic e;
	//assign invert_e = ~e;

    lcd_controller_statetype state_con;
    lcd_fsm_statetype state_fsm;

    // Initialize High Frequency 48MHz Oscillator as clk signal, divide down to 24 MHz
    logic clk, int_osc;
	logic [17:0] clk_counter;
    HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));		//TERMED FOR REMOVAL
	always_ff @(posedge int_osc)
		if (clk_counter[9]) begin	// 1 clock cycle just over every 10 us.
			clk <= ~clk;
			clk_counter <= 0; end
		else
			clk_counter <= clk_counter + 1; 
	
	/*always_ff @(posedge int_osc)
		clk <= ~clk;*/
	
	///////////////////////////////////////  DEBUGGING LOGIC  //////////////////////////////////////////
	logic debug_clk;
	logic [23:0] debug_counter;
	always_ff @(posedge int_osc) begin
		if ( (debug_counter[23]) | (~reset) ) begin
			debug_counter <= 0;
			debug_clk <= !debug_clk; end
		else
			debug_counter <= debug_counter + 1;
	end
		
	//assign led0_P28 = new_SPI;
    assign led5_PA9 = debug_clk;
	assign led6_PA10 = (state_fsm==idle);

    assign laD5_P36 = d[3];
    assign laD6_P43 = d[4];
    assign laD7_P37 = d[5];

	///////////////////////////////////////  MAIN TOP MODULE CONNECTIONS  //////////////////////////////////////////
	
    logic new_SPI;
    logic [7:0] letter, number;
    logic [15:0] frequency;

    // Structure to call in lcdSPI controller
    lcdSPI lcdSPICall(clk,reset,sclk,sdi,cs,frequency,new_SPI);

    // Structure to call in the converter
    converter converterCall(frequency,letter,number);

    // Structure to call in lcdController
    lcdController lcdControllerCall(reset,clk,new_SPI,letter,number,d,e,rs,busy_flag,state_fsm,state_con,flag_check);

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////  CONTROLLER  ///////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module lcdController(
    input   logic   reset,
    input   logic   clk,
    input   logic   new_SPI,
    input   logic   [7:0]   letter,
    input   logic   [7:0]   number,
    output  logic   [7:0]   d,
    output  logic   e,
    output  logic   rs,
	output  logic   busy_flag,
    output  lcd_fsm_statetype   state_fsm,
    output  lcd_controller_statetype    state_con,
    output  logic   flag_check
    );

    // Create internal logic
    logic [7:0] d_in;
    logic rs_in;
    logic waiting;
    logic data_ready;
	logic [7:0] letter_reg, number_reg;
    logic [4:0] cont_count;
    logic cycle5;
    lcd_controller_statetype nextstate_con; //state_con is defined as an output

    // Call to create the lowest level control FSM
    lcdFSM lcdfsmCall(reset, clk, data_ready, d_in, rs_in, d, e, rs, busy_flag, state_fsm,flag_check);

    ////////////////////////  Controller Registers  ////////////////////////////
    always_ff @(posedge clk) begin
        // state_con Registers
        if (reset)      // If Not Reset... (active low reset)
            state_con <= nextstate_con;
        else            // Else, if reset...
            state_con <= wait_SPI;

        // Letter/Number Registers
        if (~reset) begin      // If Reset...  (active low reset)
            letter_reg <= 8'h00;
            number_reg <= 8'h00; end
        else if ( (new_SPI) && (waiting) ) begin // If new_SPI just went high, store new
            letter_reg <= letter;
            number_reg <= number; end
        else begin                              // Otherwise, retain old values
            letter_reg <= letter_reg;
            number_reg <= number_reg; end

        if (state_con !== nextstate_con) begin
            cont_count <= 0;
            cycle5 <= 0; end
        else if (cont_count==5)
            cycle5 <= 1;
        else
            cont_count <= cont_count + 1;
        
    end
    /* I NEED TO ACCOUNT FOR CYCLES OF DELAY!!! */
    /* I NEED TO ACCOUNT FOR PUTTING DATA_READY FLAG HIGH SO FSM STARTS */
    ////////////////////////  Controller Next State Logic  /////////////////////
    always_comb
        case (state_con)
            wait_SPI:       if ( (state_fsm==idle) & (new_SPI) )    nextstate_con = clear_display;     
                            else            nextstate_con = wait_SPI;
            clear_display:  if ((!busy_flag) & (cycle5)) nextstate_con = cursor_home;
                            else            nextstate_con = clear_display;
            cursor_home:    if ((!busy_flag) & (cycle5)) nextstate_con = write_letter;
                            else            nextstate_con = cursor_home;
            write_letter:   if ((!busy_flag) & (cycle5)) nextstate_con = write_number;
                            else            nextstate_con = write_letter;
            write_number:   if ((!busy_flag) & (cycle5)) nextstate_con = wait_SPI;
                            else            nextstate_con = write_number;
            default: nextstate_con = wait_SPI;
        endcase
    ////////////////////////  Controller Output Logic  /////////////////////
    always_comb
        case (state_con)
            wait_SPI:       begin rs_in=0; waiting=1; d_in=8'h00; data_ready=0; end
            clear_display:  begin rs_in=0; waiting=0; d_in=8'h01; data_ready=1; end
            cursor_home:    begin rs_in=0; waiting=0; d_in=8'h02; data_ready=1; end
            write_letter:   begin rs_in=1; waiting=0; d_in=letter_reg; data_ready=1; end
            write_number:   begin rs_in=1; waiting=0; d_in=number_reg; data_ready=1; end
            default:    begin rs_in=0; waiting=1; d_in=8'h00; data_ready=0; end
        endcase
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////  FSM  //////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module lcdFSM(
    input   logic   reset,
    input   logic   clk,
    input   logic   data_ready,
    input   logic   [7:0]   d_in,
    input   logic   rs_in,
    output  logic   [7:0]   d,
    output  logic   e,
    output  logic   rs,
    output  logic   busy_flag,
    output  lcd_fsm_statetype	state_fsm,
    output  logic   flag_check
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
  0. Power up	        No Instruction	100ms
  1. Function Set	    8'b00110000	    5ms
  2. Function Set	    8'b00110000	    200us
  3. Function Set	    8'b00110000	    200us
  4. Configure	    	8'b00111000	    60us
  5. Display Off	    8'b00001000	    60us
  6. Clear	        	8'b00000001	    5ms
  7. Entry Mode Set		8'b00000110	    60us
  8. Display On	    	8'b00001100	    60us
  */

  ////////////////////////  Parameters  ////////////////////////////////////////////////////

  /* Current divided clock frequency is 24 MHz. Flag Values are rounded up.*/
  parameter integer D_50ns  = 3;    // 30us
  parameter integer D_250ns = 5;    // 50us

  parameter integer D_40us  = 100;    // 1ms
  parameter integer D_60us  = 100;    // 1ms
  parameter integer D_200us = 100;    // 1ms

  parameter integer D_2ms   = 500;    // 5ms
  parameter integer D_5ms   = 500;    // 5 ms (after f1) (10us * 500
  parameter integer D_100ms = 10000;    // 100 ms powerup (10us*10000

  /* Simulation and FSM test values -- will not work with display! IT WORKED WITH THESE AND 13 as divisor 
  parameter integer D_50ns  = 30;    // 0.000000050 * CLK_FREQ
  parameter integer D_250ns = 30;    // 0.000000250 * CLK_FREQ

  parameter integer D_40us  = 30;    // 0.000040000 * CLK_FREQ
  parameter integer D_60us  = 30;    // 0.000060000 * CLK_FREQ
  parameter integer D_200us = 30;    // 0.000200000 * CLK_FREQ

  parameter integer D_2ms   = 30;    // 0.002000000 * CLK_FREQ
  parameter integer D_5ms   = 30;    // 0.005000000 * CLK_FREQ
  parameter integer D_100ms = 30;    // 0.100000000 * CLK_FREQ */

  ////////////////////////  Function Definitions  //////////////////////////////////////////

  `define DF1 8'h30
  `define DF2 8'h30
  `define DF3 8'h30
  `define DF4 8'h38
  `define DF5 8'h08
  `define DF6 8'h01
  `define DF7 8'h06
  `define DF8 8'h0C
  `define DF9 8'h7F


  ////////////////////////  Internal Logic  ////////////////////////////////////////////////

  lcd_fsm_statetype nextstate_fsm; //state_fsm is an output now

  logic [23:0] count;

  logic flag_50ns;
  logic flag_250ns;
  logic flag_40us;
  logic flag_60us;
  logic flag_200us;
  logic flag_2ms;
  logic flag_5ms;
  logic flag_100ms;

  assign flag_check = count[0];

  ////////////////////////  FSM Registers  /////////////////////////////////////////////////////
  always_ff @(posedge clk) begin

    // state_fsm Register
    if (reset) begin    // Active low reset, so if not reset...
      state_fsm <= nextstate_fsm;   // Update the state_fsm
    end
    else begin          // If yes system reset...
      state_fsm <= s0_powerup;  // Reset the state_fsm
    end

    // Counter Register
    if ( (nextstate_fsm!==state_fsm) | (~reset) ) begin    // Reset counter when switching states
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

  ////////////////////////  FSM NEXTSTATE LOGIC  //////////////////////////////////////////////
  always_comb begin
  case (state_fsm)
    // Power Up Sequence Begins
    s0_powerup:   if (flag_100ms) nextstate_fsm = s1_set_f1;    else nextstate_fsm = s0_powerup;
    s1_set_f1:    if (flag_50ns)  nextstate_fsm = s2_write_f1;  else nextstate_fsm = s1_set_f1;
    s2_write_f1:  if (flag_250ns) nextstate_fsm = s3_off_f1;    else nextstate_fsm = s2_write_f1;
    s3_off_f1:    if (flag_5ms)   nextstate_fsm = s4_write_f2;  else nextstate_fsm = s3_off_f1;
    s4_write_f2:  if (flag_250ns) nextstate_fsm = s5_off_f2;    else nextstate_fsm = s4_write_f2;
    s5_off_f2:    if (flag_200us) nextstate_fsm = s6_write_f3;  else nextstate_fsm = s5_off_f2;
    s6_write_f3:  if (flag_250ns) nextstate_fsm = s7_off_f3;    else nextstate_fsm = s6_write_f3;
    s7_off_f3:    if (flag_200us) nextstate_fsm = s8_set_f4;    else nextstate_fsm = s7_off_f3;
    s8_set_f4:    if (flag_50ns)  nextstate_fsm = s9_write_f4;  else nextstate_fsm = s8_set_f4;
    s9_write_f4:  if (flag_250ns) nextstate_fsm = s10_off_f4;   else nextstate_fsm = s9_write_f4;
    s10_off_f4:   if (flag_60us)  nextstate_fsm = s11_set_f5;   else nextstate_fsm = s10_off_f4;
    s11_set_f5:   if (flag_50ns)  nextstate_fsm = s12_write_f5; else nextstate_fsm = s11_set_f5;
    s12_write_f5: if (flag_250ns) nextstate_fsm = s13_off_f5;   else nextstate_fsm = s12_write_f5;
    s13_off_f5:   if (flag_60us)  nextstate_fsm = s14_set_f6;   else nextstate_fsm = s13_off_f5;
    s14_set_f6:   if (flag_50ns)  nextstate_fsm = s15_write_f6; else nextstate_fsm = s14_set_f6;
    s15_write_f6: if (flag_250ns) nextstate_fsm = s16_off_f6;   else nextstate_fsm = s15_write_f6;
    s16_off_f6:   if (flag_5ms)   nextstate_fsm = s17_set_f7;   else nextstate_fsm = s16_off_f6;
    s17_set_f7:   if (flag_50ns)  nextstate_fsm = s18_write_f7; else nextstate_fsm = s17_set_f7;
    s18_write_f7: if (flag_250ns) nextstate_fsm = s19_off_f7;   else nextstate_fsm = s18_write_f7;
    s19_off_f7:   if (flag_60us)  nextstate_fsm = s20_set_f8;   else nextstate_fsm = s19_off_f7;
    s20_set_f8:   if (flag_50ns)  nextstate_fsm = s21_write_f8; else nextstate_fsm = s20_set_f8;
    s21_write_f8: if (flag_250ns) nextstate_fsm = s22_off_f8;   else nextstate_fsm = s21_write_f8;
    s22_off_f8:   if (flag_60us)  nextstate_fsm = s23_set_f9;   else nextstate_fsm = s22_off_f8;
	s23_set_f9:   if (flag_60us)  nextstate_fsm = s24_write_f9; else nextstate_fsm = s23_set_f9;
	s24_write_f9: if (flag_60us)  nextstate_fsm = s25_off_f9;   else nextstate_fsm = s24_write_f9;
	s25_off_f9:   if (flag_60us)  nextstate_fsm = boot;         else nextstate_fsm = s25_off_f9;

    boot:   if (flag_50ns)  nextstate_fsm = idle;   else nextstate_fsm = boot;
    idle:   if (data_ready) nextstate_fsm = set;    else nextstate_fsm = idle;
    set:    if (flag_50ns)  nextstate_fsm = write;  else nextstate_fsm = set;
    write:  if (flag_250ns) nextstate_fsm = off;    else nextstate_fsm = write;
    off:    if (flag_60us)  nextstate_fsm = boot;   else nextstate_fsm = off;

    default: nextstate_fsm = s0_powerup;
  endcase
  end

  ////////////////////////  FSM Output Logic  //////////////////////////////////////////////////
  always_comb begin
  case (state_fsm)
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
	s23_set_f9:   begin e=0; rs=1; busy_flag=1; d=`DF9; end
	s24_write_f9: begin e=1; rs=1; busy_flag=1; d=`DF9; end
	s25_off_f9:   begin e=0; rs=1; busy_flag=1; d=`DF9; end

    boot:     begin e=0; rs=0; busy_flag=0; d=8'h00; end
    idle:     begin e=0; rs=0; busy_flag=0; d=8'h00; end
    set:      begin e=0; rs=rs_in; busy_flag=1; d=d_in; end
    write:    begin e=1; rs=rs_in; busy_flag=1; d=d_in; end
    off:      begin e=0; rs=rs_in; busy_flag=1; d=d_in; end

    default: begin e=0; rs=0; busy_flag=1; d=8'h00; end
  endcase
  end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////  SPI  /////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module lcdSPI(  input  logic clk,
                input  logic reset,
                input  logic sclk, 
                input  logic sdi,
                input  logic cs,
                output logic [15:0] frequency,
                output logic new_SPI);
    
    // Create Internal Variables
    logic [15:0] raw_freq;
    logic last_cs;
    logic [4:0] counter;

    // Register which takes in the SPI serial transaction
    always_ff @(posedge sclk)
        {raw_freq} <= {raw_freq[14:0], sdi}; 

    // Register which watches Chip Select and loads frequency when SPI is done
    always_ff @(posedge clk) begin
        last_cs <= cs;
        if ( (cs !== last_cs) & (cs) ) begin  // If this is a rising edge of cs...
            frequency <= raw_freq;      // Update frequency output with new value
            counter <= 0;
        end
        if (counter==4)
            new_SPI <= 1;
        if (counter<10)
            counter <= counter +1;
        else
            new_SPI <= 0;
    end


endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////  CONVERTER  //////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module converter(
    input  logic [15:0] frequency,
    output logic [7:0] letter,
    output logic [7:0] number);

    always_comb begin
        if (frequency >= 62 && frequency <= 69) begin
            letter = 8'b01000011; // 'C'
            number = 8'b00110010; // '2'
        end else if (frequency > 69 && frequency <= 78) begin
            letter = 8'b01000100; // 'D'
            number = 8'b00110010; // '2'
        end else if (frequency > 78 && frequency <= 85) begin
            letter = 8'b01000101; // 'E'
            number = 8'b00110010; // '2'
        end else if (frequency > 85 && frequency <= 93) begin
            letter = 8'b01000110; // 'F'
            number = 8'b00110010; // '2'
        end else if (frequency > 93 && frequency <= 104) begin
            letter = 8'b01000111; // 'G'
            number = 8'b00110010; // '2'
        end else if (frequency > 104 && frequency <= 117) begin
            letter = 8'b01000001; // 'A'
            number = 8'b00110010; // '2'
        end else if (frequency > 117 && frequency <= 127) begin
            letter = 8'b01000010; // 'B'
            number = 8'b00110010; // '2'
        end else if (frequency > 127 && frequency <= 139) begin
            letter = 8'b01000011; // 'C'
            number = 8'b00110011; // '3'
        end else if (frequency > 139 && frequency <= 156) begin
            letter = 8'b01000100; // 'D'
            number = 8'b00110011; // '3'
        end else if (frequency > 156 && frequency <= 170) begin
            letter = 8'b01000101; // 'E'
            number = 8'b00110011; // '3'
        end else if (frequency > 170 && frequency <= 186) begin
            letter = 8'b01000110; // 'F'
            number = 8'b00110011; // '3'
        end else if (frequency > 186 && frequency <= 208) begin
            letter = 8'b01000111; // 'G'
            number = 8'b00110011; // '3'
        end else if (frequency > 208 && frequency <= 234) begin
            letter = 8'b01000001; // 'A'
            number = 8'b00110011; // '3'
        end else if (frequency > 234 && frequency <= 255) begin
            letter = 8'b01000010; // 'B'
            number = 8'b00110011; // '3'
        end else if (frequency > 255 && frequency <= 278) begin
            letter = 8'b01000011; // 'C'
            number = 8'b00110100; // '4'
        end else if (frequency > 278 && frequency <= 312) begin
            letter = 8'b01000100; // 'D'
            number = 8'b00110100; // '4'
        end else if (frequency > 312 && frequency <= 340) begin
            letter = 8'b01000101; // 'E'
            number = 8'b00110100; // '4'
        end else if (frequency > 340 && frequency <= 371) begin
            letter = 8'b01000110; // 'F'
            number = 8'b00110100; // '4'
        end else if (frequency > 371 && frequency <= 416) begin
            letter = 8'b01000111; // 'G'
            number = 8'b00110100; // '4'
        end else if (frequency > 416 && frequency <= 467) begin
            letter = 8'b01000001; // 'A'
            number = 8'b00110100; // '4'
        end else if (frequency > 467 && frequency <= 509) begin
            letter = 8'b01000010; // 'B'
            number = 8'b00110100; // '4'
        end else if (frequency > 509 && frequency <= 555) begin
            letter = 8'b01000011; // 'C'
            number = 8'b00110101; // '5'
        end else if (frequency > 555 && frequency <= 623) begin
            letter = 8'b01000100; // 'D'
            number = 8'b00110101; // '5'
        end else if (frequency > 623 && frequency <= 679) begin
            letter = 8'b01000101; // 'E'
            number = 8'b00110101; // '5'
        end else if (frequency > 679 && frequency <= 741) begin
            letter = 8'b01000110; // 'F'
            number = 8'b00110101; // '5'
        end else if (frequency > 741 && frequency <= 832) begin
            letter = 8'b01000111; // 'G'
            number = 8'b00110101; // '5'
        end else if (frequency > 832 && frequency <= 934) begin
            letter = 8'b01000001; // 'A'
            number = 8'b00110101; // '5'
        end else if (frequency > 934 && frequency <= 1046) begin
            letter = 8'b01000010; // 'B'
            number = 8'b00110101; // '5'
        end else begin
            letter = 8'b00100000; // Space
            number = 8'b00100000; // Space
	    end
    end

endmodule