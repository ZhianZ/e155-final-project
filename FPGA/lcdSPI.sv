

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