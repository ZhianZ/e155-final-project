

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