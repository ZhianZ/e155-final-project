`timescale 1ns/1ns
`default_nettype none

module converter_tb();
    // Test signals
    logic clk, reset;
    logic [15:0] frequency; // Input frequency
    logic [7:0] letter, number; // Outputs: letter and number
    logic [15:0] expected_letter, expected_number; // Expected outputs
    logic [31:0] vectornum, errors;

    // Instantiate the device under test
    converter dut(
        .frequency(frequency),
        .letter(letter),
        .number(number)
    );

    // Generate clock signal with a period of 10 time units
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Initialize testbench
    initial begin
        vectornum = 0; errors = 0;
        reset = 1; #15; reset = 0;

        // Test vectors: {frequency, expected_letter, expected_number}
        testvectors[0] = {16'd440, 8'b01000001, 8'b00110100}; // "A4"
        testvectors[1] = {16'd261, 8'b01000011, 8'b00110100}; // "C4"
        testvectors[2] = {16'd880, 8'b01000001, 8'b00110101}; // "A5"

        $display("Starting Test...");
    end

    // Apply test vectors on the rising edge of the clock
    always @(posedge clk) begin
        if (~reset) begin
            {frequency, expected_letter, expected_number} = testvectors[vectornum];
        end
    end

    // Check results on the falling edge of the clock
    always @(negedge clk) begin
        if (~reset) begin
            if (letter !== expected_letter || number !== expected_number) begin
                $display("Error: Frequency: %d, Expected Letter: %h, Got: %h, Expected Number: %h, Got: %h", 
                    frequency, expected_letter, letter, expected_number, number);
                errors = errors + 1;
            end

            vectornum = vectornum + 1;

            if (vectornum == 3) begin
                $display("%d tests completed with %d errors.", vectornum, errors);
                $finish;
            end
        end
    end
endmodule
