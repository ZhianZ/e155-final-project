module top(
    input   logic   reset,
    input   logic   sclk,
    input   logic   cs,
    input   logic   sdi,
    output  logic   [7:0]   d,
    output  logic   e,
    output  logic   rs
    );

    // Initialize High Frequency 48MHz Oscillator as clk signal
    logic clk;
    HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
	
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