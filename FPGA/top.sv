module top(
    input   logic   reset,
    input   logic   sclk,
    input   logic   cs,
    input   logic   sdi,
    output  logic   [7:0]   d,
    output  logic   e,
    output  logic   rs
    );

	//10111101 - 189 hz - G3 Tuesday Night First Test, LCD no light up or do anything. Logic analyzer shows SPI is sending signals.

    // Initialize High Frequency 48MHz Oscillator as clk signal
    logic clk, int_osc;
    HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	
	always_ff @(posedge int_osc)
		clk <= int_osc;
	
    logic new_SPI;
    logic [7:0] letter, number;
    logic [15:0] frequency;

    // Structure to call in lcdSPI controller
    lcdSPI lcdSPICall(clk,reset,sclk,sdi,cs,frequency,new_SPI);

    // Structure to call in the converter
    converter converterCall(frequency,letter,number);

    // Structure to call in lcdController
    lcdController lcdControllerCall(reset,clk,new_SPI,letter,number,d,e,rs);

endmodule