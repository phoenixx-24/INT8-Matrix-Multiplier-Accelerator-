
`timescale 1ns/1ps

module tb_systolic_array_4x4;

    reg clk;
    reg reset;
    reg clear;
    reg enable;

    reg signed [7:0] a_row0, a_row1, a_row2, a_row3;
    reg signed [7:0] b_col0, b_col1, b_col2, b_col3;

    reg [3:0] valid_row;
    reg [3:0] valid_col;

    wire signed [31:0] c00, c01, c02, c03;
    wire signed [31:0] c10, c11, c12, c13;
    wire signed [31:0] c20, c21, c22, c23;
    wire signed [31:0] c30, c31, c32, c33;

    // Input matrices
    reg signed [7:0] A [0:3][0:3];
    reg signed [7:0] B [0:3][0:3];

    // Expected output matrix
    reg signed [31:0] expected [0:3][0:3];

    integer i, j, k, t;
    integer errors;
    integer sum, av, bv;

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    // Device Under Test
    systolic_array_4x4 dut (
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .enable(enable),

        .a_row0(a_row0),
        .a_row1(a_row1),
        .a_row2(a_row2),
        .a_row3(a_row3),

        .b_col0(b_col0),
        .b_col1(b_col1),
        .b_col2(b_col2),
        .b_col3(b_col3),

        .valid_row(valid_row),
        .valid_col(valid_col),

        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33)
    );

    // Drive skewed inputs for a particular cycle
    task drive_cycle;
        input integer cycle_number;

        integer r, col;
        integer index;

        begin
            valid_row = 4'b0000;
            valid_col = 4'b0000;

            a_row0 = 0;
            a_row1 = 0;
            a_row2 = 0;
            a_row3 = 0;

            b_col0 = 0;
            b_col1 = 0;
            b_col2 = 0;
            b_col3 = 0;

            // Inject A data with row-wise skew
            for (r = 0; r < 4; r = r + 1) begin

                index = cycle_number - r;

                if (index >= 0 && index < 4) begin

                    valid_row[r] = 1'b1;

                    case (r)
                        0: a_row0 = A[r][index];
                        1: a_row1 = A[r][index];
                        2: a_row2 = A[r][index];
                        3: a_row3 = A[r][index];
                    endcase

                end
            end

            // Inject B data with column-wise skew
            for (col = 0; col < 4; col = col + 1) begin

                index = cycle_number - col;

                if (index >= 0 && index < 4) begin

                    valid_col[col] = 1'b1;

                    case (col)
                        0: b_col0 = B[index][col];
                        1: b_col1 = B[index][col];
                        2: b_col2 = B[index][col];
                        3: b_col3 = B[index][col];
                    endcase

                end
            end
        end
    endtask

    // Compare actual and expected output
    task check_cell;

        input integer row;
        input integer col;
        input signed [31:0] actual;
        input signed [31:0] expected_value;

        begin

            if (actual !== expected_value) begin

                $display(
                    "FAIL: C[%0d][%0d] Expected=%0d Actual=%0d",
                    row, col, expected_value, actual
                );

                errors = errors + 1;

            end
            else begin

                $display(
                    "PASS: C[%0d][%0d] = %0d",
                    row, col, actual
                );

            end

        end

    endtask

    // Main test
    initial begin

        clk = 0;
        reset = 1;
        clear = 0;
        enable = 1;

        valid_row = 0;
        valid_col = 0;

        errors = 0;

        // --------------------------------
        // INITIALIZE MATRIX A
        // --------------------------------
                A[0][0]=127; A[0][1]=127; A[0][2]=127; A[0][3]=127;
A[1][0]=127; A[1][1]=127; A[1][2]=127; A[1][3]=127;
A[2][0]=127; A[2][1]=127; A[2][2]=127; A[2][3]=127;
A[3][0]=127; A[3][1]=127; A[3][2]=127; A[3][3]=127;
        // --------------------------------
        // INITIALIZE MATRIX B
        // --------------------------------
       // --------------------------------
// INITIALIZE MATRIX B
// --------------------------------
B[0][0] = 127; B[0][1] = 127; B[0][2] = 127; B[0][3] = 127;
B[1][0] = 127; B[1][1] = 127; B[1][2] = 127; B[1][3] = 127;
B[2][0] = 127; B[2][1] = 127; B[2][2] = 127; B[2][3] = 127;
B[3][0] = 127; B[3][1] = 127; B[3][2] = 127; B[3][3] = 127;                // --------------------------------
        // CALCULATE EXPECTED MATRIX C = A x B
        // --------------------------------

        for (i = 0; i < 4; i = i + 1) begin

            for (j = 0; j < 4; j = j + 1) begin

                sum = 0;

                for (k = 0; k < 4; k = k + 1) begin

                    av = A[i][k];
                    bv = B[k][j];

                    sum = sum + (av * bv);

                end

                expected[i][j] = sum;

            end

        end

        // Display expected matrix
        $display("------------------------------------");
        $display("       SIGNED INT8 TEST");
        $display("------------------------------------");

        $display("Expected Matrix C:");

        for (i = 0; i < 4; i = i + 1) begin

            $display(
                "%0d  %0d  %0d  %0d",
                expected[i][0],
                expected[i][1],
                expected[i][2],
                expected[i][3]
            );

        end

        // --------------------------------
        // RESET PROCESSING ELEMENTS
        // --------------------------------

        repeat (2) @(posedge clk);

        @(negedge clk);
        reset = 0;

        // --------------------------------
        // INPUT DATA WITH SKEWING
        // --------------------------------

        for (t = 0; t <= 6; t = t + 1) begin

            drive_cycle(t);

            $display(
                "Input cycle=%0d A_valid=%b B_valid=%b",
                t, valid_row, valid_col
            );

            @(negedge clk);

        end

        // Stop input injection
        valid_row = 0;
        valid_col = 0;

        a_row0 = 0;
        a_row1 = 0;
        a_row2 = 0;
        a_row3 = 0;

        b_col0 = 0;
        b_col1 = 0;
        b_col2 = 0;
        b_col3 = 0;

        // Allow remaining data to propagate
        repeat (3) @(negedge clk);

        // --------------------------------
        // VERIFY ALL 16 OUTPUTS
        // --------------------------------

        $display("------------------------------------");
        $display("       OUTPUT VERIFICATION");
        $display("------------------------------------");

        check_cell(0,0,c00,expected[0][0]);
        check_cell(0,1,c01,expected[0][1]);
        check_cell(0,2,c02,expected[0][2]);
        check_cell(0,3,c03,expected[0][3]);

        check_cell(1,0,c10,expected[1][0]);
        check_cell(1,1,c11,expected[1][1]);
        check_cell(1,2,c12,expected[1][2]);
        check_cell(1,3,c13,expected[1][3]);

        check_cell(2,0,c20,expected[2][0]);
        check_cell(2,1,c21,expected[2][1]);
        check_cell(2,2,c22,expected[2][2]);
        check_cell(2,3,c23,expected[2][3]);

        check_cell(3,0,c30,expected[3][0]);
        check_cell(3,1,c31,expected[3][1]);
        check_cell(3,2,c32,expected[3][2]);
        check_cell(3,3,c33,expected[3][3]);

        // --------------------------------
        // FINAL RESULT
        // --------------------------------

        $display("------------------------------------");

        if (errors == 0) begin

            $display("ALL 16 OUTPUTS PASSED!");
            $display("SIGNED INT8 TEST SUCCESSFUL!");

        end
        else begin

            $display("TEST FAILED: %0d errors", errors);

        end

        $display("------------------------------------");

        $finish;

    end

endmodule
