`timescale 1ns / 1ps

module fixed_point_divider #(
    parameter QM = 12,                                 // Number of integer bits
    parameter QN = 20,                                 // Number of fractional bits
    parameter DATA_WIDTH = QM + QN                     // Total data width
)(
    input wire clk,                                    // 200MHz system clock
    input wire arst_n,                                 // Asynchronous active low reset
    input wire signed [DATA_WIDTH-1:0] in_numerator,   // Q12.20 format numerator
    input wire signed [DATA_WIDTH-1:0] in_denominator, // Q12.20 format denominator
    input wire in_valid,                               // Input valid signal
    output reg out_valid,                              // Output valid signal
    output reg signed [DATA_WIDTH-1:0] out_quotient,   // Q12.20 format quotient
    output reg error_flag
);

   function integer ceil_log2
    (
        input integer x
    );

        integer i;
        begin
            ceil_log2 = 1;
            i = 2;
            while (ceil_log2 < 32 && i < x) begin
                ceil_log2 = ceil_log2 + 1;
                i = i * 2;
            end
        end
    endfunction

    // FSM States
    localparam IDLE              = 3'd0;
    localparam NORMALIZE         = 3'd1;
    localparam SHIFT             = 3'd2;
    localparam DIVIDE            = 3'd3;
    localparam NEXT_ITER         = 3'd4;
    localparam DONE              = 3'd5;

    // FSM State Registers
    reg [2:0] state;

    // Registers for division
    reg [2*DATA_WIDTH:0] dividend;             // Extended width for shifted numerator
    reg [2*DATA_WIDTH:0] divisor;              // Extended width for denominator
    reg signed [DATA_WIDTH-1:0] quotient;      // Intermediate quotient
    reg signed [2*DATA_WIDTH-1:0] remainder;   // Remainder for division steps
    reg quotient_sign;                         // Sign of the quotient
    
    reg [ceil_log2(2*QN + QM + 1)-1:0] MAX_STEPS = 2*QN + QM + 1;  // Maximum number of iterations
    reg [ceil_log2(2*QN + QM + 1)-1:0] step_count;                 // Step counter (0 to MAX_STEPS)
    
    // Include LZD module
    wire [ceil_log2(DATA_WIDTH):0] lead_zero_count;
    LZD_32bit lzd_inst (
        .in(in_numerator[DATA_WIDTH-1] ? -in_numerator : in_numerator),
        .leading_zeros(lead_zero_count)
    );
    // Registered lead_zero_count
    reg [ceil_log2(DATA_WIDTH):0] lead_zero_count_reg;
    
    always @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            state               <= IDLE;
            out_valid           <= 1'b0;
            out_quotient        <= {DATA_WIDTH{1'b0}};
            dividend            <= {2*DATA_WIDTH{1'b0}};
            divisor             <= {2*DATA_WIDTH{1'b0}};
            quotient            <= {DATA_WIDTH{1'b0}};
            remainder           <= {2*DATA_WIDTH{1'b0}};
            step_count          <= 0;
            lead_zero_count_reg <= 0;
            quotient_sign       <= 1'b0;
            error_flag          <= 1'b0;
            
        end else begin
            case (state)
                IDLE: begin
                    out_valid         <= 1'b0;
                    if (in_valid) begin
                        if(in_numerator == 0) begin
                            quotient_sign <= 0;
                            quotient      <= 0;
                            remainder     <= 0;
                            error_flag    <= 1'b0;
                            state         <= DONE;
                        end else if (in_denominator == 0) begin
                            quotient_sign <= 0;
                            quotient      <= 0;
                            remainder     <= 0;
                            error_flag    <= 1'b1;
                            state         <= DONE;
                        end else begin
                            // Determine the sign of the quotient
                            quotient_sign <= in_numerator[DATA_WIDTH-1] ^ in_denominator[DATA_WIDTH-1];
                            
                            // Take absolute values and scale numerator
                            dividend <= ((in_numerator[DATA_WIDTH-1] ? -in_numerator : in_numerator)) << QN;  // Scaled numerator
                            divisor  <= in_denominator[DATA_WIDTH-1] ? -in_denominator : in_denominator;      // Absolute denominator
    
                            quotient   <= {DATA_WIDTH{1'b0}};
                            remainder  <= {2*DATA_WIDTH{1'b0}};
                            step_count <= 0;
                            state      <= NORMALIZE;
                        end
                    end
                end               

                NORMALIZE: begin
                    // Register the lead_zero_count from combinational LZD
                    lead_zero_count_reg <= lead_zero_count;
                    state               <= SHIFT;
                end

                SHIFT: begin
                    // Start step_count from lead_zero_count_reg, since the first lead_zero_count_reg bits in in_denumerator are zero
                    if (lead_zero_count_reg > 0) begin
                        step_count      <= step_count + lead_zero_count_reg;
                    end
                    state <= DIVIDE;
                end
          
                DIVIDE: begin
                    if (step_count < MAX_STEPS) begin
                        // Perform Non-Restoring Division Step
                        remainder  <= (remainder << 1) | ((dividend >> (MAX_STEPS - 1 - step_count)) & 1);
                        step_count <= step_count + 1;
                        state      <= NEXT_ITER;
                    end else begin
                        state      <= DONE;
                    end
                end
                
                NEXT_ITER: begin
                    if (remainder >= divisor) begin
                        remainder <= remainder - divisor;
                        quotient  <= (quotient << 1) | 1'b1;
                    end else begin
                        quotient  <= quotient << 1;
                    end
                    state <= DIVIDE;
                end

                DONE: begin                    
                    if (quotient_sign)
                        out_quotient <= -quotient;
                    else
                        out_quotient <= quotient;

                    out_valid <= 1'b1;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule