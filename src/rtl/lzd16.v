`timescale 1ns / 1ps

module LZD_16bit (
    input  wire [15:0] in,
    output reg [4:0]  leading_zeros
);
    always @(*) begin
        if (in[15]) begin
            leading_zeros = 0;
        end else if (in[14]) begin
            leading_zeros = 1;
        end else if (in[13]) begin
            leading_zeros = 2;
        end else if (in[12]) begin
            leading_zeros = 3;
        end else if (in[11]) begin
            leading_zeros = 4;
        end else if (in[10]) begin
            leading_zeros = 5;
        end else if (in[9]) begin
            leading_zeros = 6;
        end else if (in[8]) begin
            leading_zeros = 7;
        end else if (in[7]) begin
            leading_zeros = 8;
        end else if (in[6]) begin
            leading_zeros = 9;
        end else if (in[5]) begin
            leading_zeros = 10;
        end else if (in[4]) begin
            leading_zeros = 11;
        end else if (in[3]) begin
            leading_zeros = 12;
        end else if (in[2]) begin
            leading_zeros = 13;
        end else if (in[1]) begin
            leading_zeros = 14;
        end else if (in[0]) begin
            leading_zeros = 15;
        end else begin
            leading_zeros = 16; // All zeros
        end
    end
endmodule
