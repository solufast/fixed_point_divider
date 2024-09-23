`timescale 1ns / 1ps

module LZD_64bit (
    input  wire [63:0] in,
    output wire [6:0]  leading_zeros // 7 bits to represent 0-64
);
    wire [5:0] lz_high;
    wire [5:0] lz_low;
    wire high_zero;

    // Instantiate two 32-bit LZDs
    LZD_32bit lzd_high (
        .in(in[63:32]),
        .leading_zeros(lz_high)
    );

    LZD_32bit lzd_low (
        .in(in[31:0]),
        .leading_zeros(lz_low)
    );

    // Determine if the high half is all zeros
    assign high_zero = (lz_high == 32);

    // Calculate the total leading zeros
    assign leading_zeros = high_zero ? (32 + lz_low) : lz_high;
endmodule
