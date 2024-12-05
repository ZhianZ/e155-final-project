module top_artificial(
    input   logic   clk,
    input   logic   reset,
    input   logic   sclk,
    input   logic   cs,
    input   logic   sdi,
    output  logic   [7:0]   d,
    output  logic   e,
    output  logic   rs
    );
	
    logic new_SPI, busy_flag;
    logic [7:0] letter, number;
    logic [15:0] frequency;

    // Structure to call in lcdSPI controller
    lcdSPI lcdSPICall(clk,reset,sclk,sdi,cs,frequency,new_SPI);

    // Structure to call in the converter
    converter converterCall(frequency,letter,number);

    // Structure to call in lcdController
    lcdController lcdControllerCall(reset,clk,new_SPI,letter,number,d,e,rs,busy_flag);

endmodule

module top_testbench();

    // Create necessary variables
  logic   clk;
  logic   reset;
  logic   sclk;
  logic   cs;
  logic   sdi;
  logic   [7:0]   d;
  logic   e;
  logic   rs;
  logic   busy_flag;

  // Call DUT module
  top_artificial dut(clk,reset,sclk,cs,sdi,d,e,rs);

  // Clock cycle and pulse reset (recall active low)
  always begin clk = 1; #5; clk=0; #5; end
  initial begin reset=1; end

  // Feed in the desired signals. 
  // run 240 550 to get to the change
  initial begin 
  cs = 1; sclk = 0; sdi = 0; #7800;
  // Transmit 0000 0000 1111 1101 (253 in dec)
  cs = 0; #10;
  sdi = 0; #1; sclk=1; #5; sclk=0; #4;
  sdi = 0; #1; sclk=1; #5; sclk=0; #4;
  sdi = 0; #1; sclk=1; #5; sclk=0; #4;
  sdi = 0; #1; sclk=1; #5; sclk=0; #4;

  sdi = 0; #1; sclk=1; #5; sclk=0; #4;
  sdi = 0; #1; sclk=1; #5; sclk=0; #4;
  sdi = 0; #1; sclk=1; #5; sclk=0; #4;
  sdi = 0; #1; sclk=1; #5; sclk=0; #4;

  sdi = 1; #1; sclk=1; #5; sclk=0; #4;
  sdi = 1; #1; sclk=1; #5; sclk=0; #4;
  sdi = 1; #1; sclk=1; #5; sclk=0; #4;
  sdi = 1; #1; sclk=1; #5; sclk=0; #4;

  sdi = 1; #1; sclk=1; #5; sclk=0; #4;
  sdi = 1; #1; sclk=1; #5; sclk=0; #4;
  sdi = 0; #1; sclk=1; #5; sclk=0; #4;
  sdi = 1; #1; sclk=1; #5; sclk=0; #4;
  #10; cs=1;
  end

endmodule