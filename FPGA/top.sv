module top(
    input   logic   reset,
    input   logic   sclk,
    input   logic   cs,
    input   logic   sdi,
    output  logic   [7:0]   d,
    output  logic   e,
    output  logic   rs,
	output	logic	ledCLK,
	output	logic	ledIDLE
    );

	//10111101 - 189 hz - G3 Tuesday Night First Test, LCD no light up or do anything. Logic analyzer shows SPI is sending signals.

	logic busy_flag;

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
			ledCLK <= !ledCLK; end
		else
			debug_counter <= debug_counter + 1;
	end
	
	assign ledIDLE = ~busy_flag;
	
	///////////////////////////////////////  MAIN TOP MODULE CONNECTIONS  //////////////////////////////////////////
	
    logic new_SPI;
    logic [7:0] letter, number;
    logic [15:0] frequency;

    // Structure to call in lcdSPI controller
    lcdSPI lcdSPICall(clk,reset,sclk,sdi,cs,frequency,new_SPI);

    // Structure to call in the converter
    converter converterCall(frequency,letter,number);

    // Structure to call in lcdController
    lcdController lcdControllerCall(reset,clk,new_SPI,letter,number,d,e,rs,busy_flag);

endmodule