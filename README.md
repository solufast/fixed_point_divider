# fixed_point_divider
Verilog Implementation of Robust and Efficient Fixed Point Format Divider.

# Sample Test Run Outputs

===== Test Case 1: 2.500000 / 1.500000 =====
Output Quotient:     1747626 (1.666666)
Current State: 0
Step Count: 53
Scaled Dividend: 2748779069440
Scaled Divisor: 1572864
Lead Zero Count Reg: 10
Remainder: 1048576
Quotient: 1747626
Quotient Sign: 0
Error Flag: 0
===============================
Test Case 1 Passed!
===== Test Case 2: -2.500000 / 1.500000 =====
Output Quotient:    -1747626 (-1.666666)
Current State: 0
Step Count: 53
Scaled Dividend: 2748779069440
Scaled Divisor: 1572864
Lead Zero Count Reg: 10
Remainder: 1048576
Quotient: 1747626
Quotient Sign: 1
Error Flag: 0
===============================
Test Case 2 Passed!
===== Test Case 3: 2.500000 / -1.500000 =====
Output Quotient:    -1747626 (-1.666666)
Current State: 0
Step Count: 53
Scaled Dividend: 2748779069440
Scaled Divisor: 1572864
Lead Zero Count Reg: 10
Remainder: 1048576
Quotient: 1747626
Quotient Sign: 1
Error Flag: 0
===============================
Test Case 3 Passed!
===== Test Case 4: -2.500000 / -1.500000 =====
Output Quotient:     1747626 (1.666666)
Current State: 0
Step Count: 53
Scaled Dividend: 2748779069440
Scaled Divisor: 1572864
Lead Zero Count Reg: 10
Remainder: 1048576
Quotient: 1747626
Quotient Sign: 0
Error Flag: 0
===============================
Test Case 4 Passed!
===== Test Case 5: 0.000000 / 1.500000 =====
Output Quotient:           0 (0.000000)
Current State: 0
Step Count: 53
Scaled Dividend: 2748779069440
Scaled Divisor: 1572864
Lead Zero Count Reg: 10
Remainder: 0
Quotient: 0
Quotient Sign: 0
Error Flag: 0
===============================
Test Case 5 Passed!
===== Test Case 6: 1.000000 / 1.000000 =====
Output Quotient:     1048576 (1.000000)
Current State: 0
Step Count: 53
Scaled Dividend: 1099511627776
Scaled Divisor: 1048576
Lead Zero Count Reg: 11
Remainder: 0
Quotient: 1048576
Quotient Sign: 0
Error Flag: 0
===============================
Test Case 6 Passed!
===== Test Case 7: 0.500000 / 1.000000 =====
Output Quotient:      524288 (0.500000)
Current State: 0
Step Count: 53
Scaled Dividend: 549755813888
Scaled Divisor: 1048576
Lead Zero Count Reg: 12
Remainder: 0
Quotient: 524288
Quotient Sign: 0
Error Flag: 0
===============================
Test Case 7 Passed!
===== Test Case 8: 1.000000 / 0.000000 =====
Output Quotient:           0 (0.000000)
Current State: 0
Step Count: 53
Scaled Dividend: 549755813888
Scaled Divisor: 1048576
Lead Zero Count Reg: 12
Remainder: 0
Quotient: 0
Quotient Sign: 0
Error Flag: 1
===============================
Test Case 8 Passed (Handled Division by Zero)!
All 8 Test Cases Passed!
