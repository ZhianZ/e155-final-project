

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
    output  logic   laD7_P34
    );

	//10111101 - 189 hz - G3 Tuesday Night First Test, LCD no light up or do anything. Logic analyzer shows SPI is sending signals.

	logic busy_flag, flag_check;

    lcd_controller_statetype state_con;
    lcd_fsm_statetype state_fsm;

    // Initialize High Frequency 48MHz Oscillator as clk signal, divide down to 24 MHz
    logic clk, int_osc;
    HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	always_ff @(posedge int_osc)
		clk <= int_osc;
	
	// Debug Logic
	logic debug_clk;
	logic [23:0] debug_counter;
	always_ff @(posedge int_osc) begin
		if ( (debug_counter[23]) | (~reset) ) begin
			debug_counter <= 0;
			debug_clk <= !debug_clk; end
		else
			debug_counter <= debug_counter + 1;
	end
		
    //assign led_PA10 = ;
    //assign led0_P28 = ;
    //assign led1_P38 = ;
    //assign led2_P42 = ;
    //assign led4_PA6 = ;
    assign led5_PA9 = debug_clk;
	assign led6_PA10 = (state_fsm==idle);

    assign laD5_P36 = (state_fsm==s0_powerup);
    assign laD6_P43 = flag_check;
    assign laD7_P34 = reset;

	///////////////////////////////////////  MAIN TOP MODULE CONNECTIONS  //////////////////////////////////////////
	
    logic new_SPI;
    logic [7:0] letter, number;
    logic [15:0] frequency;

    // Structure to call in lcdSPI controller
    lcdSPI lcdSPICall(clk,reset,sclk,sdi,cs,frequency,new_SPI);

    // Structure to call in the converter
    converter converterCall(frequency,letter,number);

    // Structure to call in lcdController
    lcdController lcdControllerCall(reset,clk,new_SPI,letter,number,d,e,rs,busy_flag,state_fsm,state_con);

endmodule