`timescale 1ns / 1ps

module tb_fixed_point_divider;

    // Parameters
    localparam CLK_PERIOD = 5; // 200MHz clock => 5ns period
    localparam QM = 12;
    localparam QN = 20;
    localparam DATA_WIDTH = QM + QN;

    // Inputs
    reg clk;
    reg arst_n;
    reg signed [DATA_WIDTH-1:0] in_numerator;
    reg signed [DATA_WIDTH-1:0] in_denominator;
    reg in_valid;

    // Outputs
    wire out_valid;
    wire signed [DATA_WIDTH-1:0] out_quotient;
    wire error_flag;

    // Instantiate the divider
    fixed_point_divider #(
        .QM(QM),
        .QN(QN),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .arst_n(arst_n),
        .in_numerator(in_numerator),
        .in_denominator(in_denominator),
        .in_valid(in_valid),
        .out_valid(out_valid),
        .out_quotient(out_quotient),
        .error_flag(error_flag)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Helper function to convert floating-point to fixed-point
    function [DATA_WIDTH-1:0] float_to_fixed;
        input real value;
        begin
            float_to_fixed = $rtoi(value * (2.0**QN));
        end
    endfunction


    // Test Vector Definitions
    reg [7:0] test_case;
    integer passed_tests;
    initial begin
        // Initialize Inputs
        arst_n = 0;
        in_numerator = {DATA_WIDTH{1'b0}};
        in_denominator = {DATA_WIDTH{1'b0}};
        in_valid = 1'b0;
        passed_tests = 0;

        // Apply Reset
        #(CLK_PERIOD * 2);
        arst_n = 1;

        // Wait for a few cycles
        #(CLK_PERIOD * 2);

        // Define a series of test cases
        // Each test case includes:
        // - Test case number
        // - Numerator and denominator in fixed-point format
        // - Expected quotient in fixed-point format
        // - Description
        
        // Test Case 1: Positive / Positive (2.5 / 1.5 = 1.666666)
        test_case = 1;
        in_numerator = float_to_fixed(2.5);      // 2.5 in Q24.40
        in_denominator = float_to_fixed(1.5);    // 1.5 in Q24.40
        in_valid = 1'b1;
        #(CLK_PERIOD);
        in_valid = 1'b0;

        // Monitor internal signals
        $display("===== Test Case %0d: %f / %f =====", test_case, 2.5, 1.5);
        // Wait for division to complete
        wait(out_valid);
        #(CLK_PERIOD);
        // Display outputs
        $display("Output Quotient: %d (%f)", out_quotient, $itor(out_quotient)/ (2.0**QN));
        // Display internal signals
        $display("Current State: %0d", uut.state);
        $display("Step Count: %0d", uut.step_count);
        $display("Scaled Dividend: %0d", uut.dividend);
        $display("Scaled Divisor: %0d", uut.divisor);
        $display("Lead Zero Count Reg: %0d", uut.lead_zero_count_reg);
        $display("Remainder: %0d", uut.remainder);
        $display("Quotient: %0d", uut.quotient);
        $display("Quotient Sign: %0b", uut.quotient_sign);
        $display("Error Flag: %0b", error_flag);
        $display("===============================");

        // Check the result and early exit
        if ((out_quotient - float_to_fixed(1.666666) < 10)) begin
            $display("Test Case %0d Passed!", test_case);
            passed_tests = passed_tests + 1;
        end else begin
            $fatal("Test Case %0d Failed! Expected: %d, Got: %d, Step Count: %d", 
                   test_case, float_to_fixed(1.666666), out_quotient, uut.step_count);
        end

        // Test Case 2: Negative / Positive (-2.5 / 1.5 = -1.666666)
        test_case = 2;
        in_numerator = float_to_fixed(-2.5);     // -2.5 in Q24.40
        in_denominator = float_to_fixed(1.5);     // 1.5 in Q24.40
        in_valid = 1'b1;
        #(CLK_PERIOD);
        in_valid = 1'b0;

        $display("===== Test Case %0d: %f / %f =====", test_case, -2.5, 1.5);
        wait(out_valid);
        #(CLK_PERIOD);
        $display("Output Quotient: %d (%f)", out_quotient, $itor(out_quotient)/ (2.0**QN));
        // Display internal signals
        $display("Current State: %0d", uut.state);
        $display("Step Count: %0d", uut.step_count);
        $display("Scaled Dividend: %0d", uut.dividend);
        $display("Scaled Divisor: %0d", uut.divisor);
        $display("Lead Zero Count Reg: %0d", uut.lead_zero_count_reg);
        $display("Remainder: %0d", uut.remainder);
        $display("Quotient: %0d", uut.quotient);
        $display("Quotient Sign: %0b", uut.quotient_sign);
        $display("Error Flag: %0b", error_flag);
        $display("===============================");

        if ((out_quotient - float_to_fixed(-1.666666) < 10)) begin
            $display("Test Case %0d Passed!", test_case);
            passed_tests = passed_tests + 1;
        end else begin
            $fatal("Test Case %0d Failed! Expected: %d, Got: %d, Step Count: %d", 
                   test_case, float_to_fixed(-1.666666), out_quotient, uut.step_count);
        end

        // Test Case 3: Positive / Negative (2.5 / -1.5 = -1.666666)
        test_case = 3;
        in_numerator = float_to_fixed(2.5);      // 2.5 in Q12.20
        in_denominator = float_to_fixed(-1.5);    // -1.5 in Q12.20
        in_valid = 1'b1;
        #(CLK_PERIOD);
        in_valid = 1'b0;

        $display("===== Test Case %0d: %f / %f =====", test_case, 2.5, -1.5);
        wait(out_valid);
        #(CLK_PERIOD);
        $display("Output Quotient: %d (%f)", out_quotient, $itor(out_quotient)/ (2.0**QN));
        // Display internal signals
        $display("Current State: %0d", uut.state);
        $display("Step Count: %0d", uut.step_count);
        $display("Scaled Dividend: %0d", uut.dividend);
        $display("Scaled Divisor: %0d", uut.divisor);
        $display("Lead Zero Count Reg: %0d", uut.lead_zero_count_reg);
        $display("Remainder: %0d", uut.remainder);
        $display("Quotient: %0d", uut.quotient);
        $display("Quotient Sign: %0b", uut.quotient_sign);
        $display("Error Flag: %0b", error_flag);
        $display("===============================");

        if ((out_quotient - float_to_fixed(-1.666666) < 10)) begin
            $display("Test Case %0d Passed!", test_case);
            passed_tests = passed_tests + 1;
        end else begin
            $fatal("Test Case %0d Failed! Expected: %d, Got: %d, Step Count: %d", 
                   test_case, float_to_fixed(-1.666666), out_quotient, uut.step_count);
        end

        // Test Case 4: Negative / Negative (-2.5 / -1.5 = 1.666666)
        test_case = 4;
        in_numerator = float_to_fixed(-2.5);     // -2.5 in Q12.20
        in_denominator = float_to_fixed(-1.5);    // -1.5 in Q12.20
        in_valid = 1'b1;
        #(CLK_PERIOD);
        in_valid = 1'b0;

        $display("===== Test Case %0d: %f / %f =====", test_case, -2.5, -1.5);
        wait(out_valid);
        #(CLK_PERIOD);
        $display("Output Quotient: %d (%f)", out_quotient, $itor(out_quotient)/ (2.0**QN));
        // Display internal signals
        $display("Current State: %0d", uut.state);
        $display("Step Count: %0d", uut.step_count);
        $display("Scaled Dividend: %0d", uut.dividend);
        $display("Scaled Divisor: %0d", uut.divisor);
        $display("Lead Zero Count Reg: %0d", uut.lead_zero_count_reg);
        $display("Remainder: %0d", uut.remainder);
        $display("Quotient: %0d", uut.quotient);
        $display("Quotient Sign: %0b", uut.quotient_sign);
        $display("Error Flag: %0b", error_flag);
        $display("===============================");

        if (out_quotient - float_to_fixed(1.666666) < 10) begin
            $display("Test Case %0d Passed!", test_case);
            passed_tests = passed_tests + 1;
        end else begin
            $fatal("Test Case %0d Failed! Expected: %d, Got: %d, Step Count: %d", 
                   test_case, float_to_fixed(1.666666), out_quotient, uut.step_count);
        end

        // Test Case 5: Zero Dividend (0.0 / 1.5 = 0.0)
        test_case = 5;
        in_numerator = float_to_fixed(0.0);      // 0.0 in Q12.20
        in_denominator = float_to_fixed(1.5);    // 1.5 in Q12.20
        in_valid = 1'b1;
        #(CLK_PERIOD);
        in_valid = 1'b0;

        $display("===== Test Case %0d: %f / %f =====", test_case, 0.0, 1.5);
        wait(out_valid);
        #(CLK_PERIOD);
        // Display outputs
        $display("Output Quotient: %d (%f)", out_quotient, $itor(out_quotient)/ (2.0**QN));
        // Display internal signals
        $display("Current State: %0d", uut.state);
        $display("Step Count: %0d", uut.step_count);
        $display("Scaled Dividend: %0d", uut.dividend);
        $display("Scaled Divisor: %0d", uut.divisor);
        $display("Lead Zero Count Reg: %0d", uut.lead_zero_count_reg);
        $display("Remainder: %0d", uut.remainder);
        $display("Quotient: %0d", uut.quotient);
        $display("Quotient Sign: %0b", uut.quotient_sign);
        $display("Error Flag: %0b", error_flag);
        $display("===============================");

        if ((out_quotient - float_to_fixed(0.0) < 10) && !error_flag) begin
            $display("Test Case %0d Passed!", test_case);
            passed_tests = passed_tests + 1;
        end else begin
            $fatal("Test Case %0d Failed! Expected: %d, Got: %d", 
                   test_case, float_to_fixed(0.0), out_quotient);
        end

        // Test Case 6: Division by One (1.0 / 1.0 = 1.0)
        test_case = 6;
        in_numerator = float_to_fixed(1.0);      // 1.0 in Q12.20
        in_denominator = float_to_fixed(1.0);    // 1.0 in Q12.20
        in_valid = 1'b1;
        #(CLK_PERIOD);
        in_valid = 1'b0;

        $display("===== Test Case %0d: %f / %f =====", test_case, 1.0, 1.0);
        wait(out_valid);
        #(CLK_PERIOD);
        // Display outputs
        $display("Output Quotient: %d (%f)", out_quotient, $itor(out_quotient)/ (2.0**QN));
        // Display internal signals
        $display("Current State: %0d", uut.state);
        $display("Step Count: %0d", uut.step_count);
        $display("Scaled Dividend: %0d", uut.dividend);
        $display("Scaled Divisor: %0d", uut.divisor);
        $display("Lead Zero Count Reg: %0d", uut.lead_zero_count_reg);
        $display("Remainder: %0d", uut.remainder);
        $display("Quotient: %0d", uut.quotient);
        $display("Quotient Sign: %0b", uut.quotient_sign);
        $display("Error Flag: %0b", error_flag);
        $display("===============================");

        if ((out_quotient - float_to_fixed(1.0) < 10) && !error_flag) begin
            $display("Test Case %0d Passed!", test_case);
            passed_tests = passed_tests + 1;
        end else begin
            $fatal("Test Case %0d Failed! Expected: %d, Got: %d", 
                   test_case, float_to_fixed(1.0), out_quotient);
        end

        // Test Case 7: Divisor Greater Than Dividend (0.5 / 1.0 = 0.5)
        test_case = 7;
        in_numerator = float_to_fixed(0.5);      // 0.5 in Q12.20
        in_denominator = float_to_fixed(1.0);    // 1.0 in Q12.20
        in_valid = 1'b1;
        #(CLK_PERIOD);
        in_valid = 1'b0;

        $display("===== Test Case %0d: %f / %f =====", test_case, 0.5, 1.0);
        wait(out_valid);
        #(CLK_PERIOD);
        // Display outputs
        $display("Output Quotient: %d (%f)", out_quotient, $itor(out_quotient)/ (2.0**QN));
        // Display internal signals
        $display("Current State: %0d", uut.state);
        $display("Step Count: %0d", uut.step_count);
        $display("Scaled Dividend: %0d", uut.dividend);
        $display("Scaled Divisor: %0d", uut.divisor);
        $display("Lead Zero Count Reg: %0d", uut.lead_zero_count_reg);
        $display("Remainder: %0d", uut.remainder);
        $display("Quotient: %0d", uut.quotient);
        $display("Quotient Sign: %0b", uut.quotient_sign);
        $display("Error Flag: %0b", error_flag);
        $display("===============================");

        if (out_quotient - float_to_fixed(0.5) <10) begin
            $display("Test Case %0d Passed!", test_case);
            passed_tests = passed_tests + 1;
        end else begin
            $fatal("Test Case %0d Failed! Expected: %d, Got: %d, Step Count: %d", 
                   test_case, float_to_fixed(0.5), out_quotient, uut.step_count);
        end

        // Test Case 8: Division by Zero (1.0 / 0.0 = Undefined)
        test_case = 8;
        in_numerator = float_to_fixed(1.0);      // 1.0 in Q12.20
        in_denominator = float_to_fixed(0.0);    // 0.0 in Q12.20
        in_valid = 1'b1;
        #(CLK_PERIOD);
        in_valid = 1'b0;

        $display("===== Test Case %0d: %f / %f =====", test_case, 1.0, 0.0);
        wait(out_valid);
        #(CLK_PERIOD);
        // Display outputs
        $display("Output Quotient: %d (%f)", out_quotient, $itor(out_quotient)/ (2.0**QN));
        // Display internal signals
        $display("Current State: %0d", uut.state);
        $display("Step Count: %0d", uut.step_count);
        $display("Scaled Dividend: %0d", uut.dividend);
        $display("Scaled Divisor: %0d", uut.divisor);
        $display("Lead Zero Count Reg: %0d", uut.lead_zero_count_reg);
        $display("Remainder: %0d", uut.remainder);
        $display("Quotient: %0d", uut.quotient);
        $display("Quotient Sign: %0b", uut.quotient_sign);
        $display("Error Flag: %0b", error_flag);
        $display("===============================");

        if ((out_quotient - float_to_fixed(0.0) <10)&& error_flag) begin
            $display("Test Case %0d Passed (Handled Division by Zero)!", test_case);
            passed_tests = passed_tests + 1;
        end else begin
            $fatal("Test Case %0d Failed! Expected: %d with Error Flag, Got: %d with Error Flag %b", 
                   test_case, float_to_fixed(0.0), out_quotient, error_flag);
        end

        // Finish Simulation
        #(CLK_PERIOD * 20);
        $display("All %0d Test Cases Passed!", passed_tests);
        $finish;
    end

endmodule
