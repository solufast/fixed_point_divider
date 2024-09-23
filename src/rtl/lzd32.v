`timescale 1ns / 1ps

module LZD_32bit (
    input  wire [31:0] in,
    output wire [5:0]  leading_zeros
);
    wire [4:0] lz_high;
    wire [4:0] lz_low;
    wire high_zero;

    // Instantiate two 16-bit LZDs
    LZD_16bit lzd_high (
        .in(in[31:16]),
        .leading_zeros(lz_high)
    );

    LZD_16bit lzd_low (
        .in(in[15:0]),
        .leading_zeros(lz_low)
    );

    // Determine if the high half is all zeros
    assign high_zero = (lz_high == 16);

    // Calculate the total leading zeros
    assign leading_zeros = high_zero ? (16 + lz_low) : lz_high;
endmodule
