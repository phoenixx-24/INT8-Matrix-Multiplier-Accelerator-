
`timescale 1ns/1ps

module tb_controller_writeback;

    reg clk, reset, start;

    reg a_we, b_we;
    reg [3:0] write_addr;
    reg signed [7:0] a_din, b_din;

    wire [3:0] ctrl_a_addr, ctrl_b_addr;
    wire signed [7:0] a_dout, b_dout;

    // C memory interface
    wire ctrl_c_we;
    wire [3:0] ctrl_c_addr;
    wire signed [31:0] ctrl_c_din;

    reg [3:0] c_read_addr;
    wire signed [31:0] c_dout;

    wire [3:0] actual_c_addr;

    assign actual_c_addr =
        ctrl_c_we ? ctrl_c_addr : c_read_addr;

    wire signed [7:0] a_row0, a_row1, a_row2, a_row3;
    wire signed [7:0] b_col0, b_col1, b_col2, b_col3;

    wire [3:0] valid_row, valid_col;
    wire array_enable, array_clear;

    wire busy, done;

    wire signed [31:0] c00, c01, c02, c03;
    wire signed [31:0] c10, c11, c12, c13;
    wire signed [31:0] c20, c21, c22, c23;
    wire signed [31:0] c30, c31, c32, c33;

    wire signed [31:0] result [0:3][0:3];

    reg signed [7:0] expected_A [0:15];
    reg signed [7:0] expected_B [0:15];

    integer expected_C [0:15];

    integer i, j, k;
    integer errors;
    integer sum;

    assign result[0][0] = c00;
    assign result[0][1] = c01;
    assign result[0][2] = c02;
    assign result[0][3] = c03;

    assign result[1][0] = c10;
    assign result[1][1] = c11;
    assign result[1][2] = c12;
    assign result[1][3] = c13;

    assign result[2][0] = c20;
    assign result[2][1] = c21;
    assign result[2][2] = c22;
    assign result[2][3] = c23;

    assign result[3][0] = c30;
    assign result[3][1] = c31;
    assign result[3][2] = c32;
    assign result[3][3] = c33;

    // --------------------------------
    // MEMORY SYSTEM
    // --------------------------------

    matrix_memory_system memory_inst (
        .clk(clk),

        .a_we(a_we),
        .a_addr(a_we ? write_addr : ctrl_a_addr),
        .a_din(a_din),
        .a_dout(a_dout),

        .b_we(b_we),
        .b_addr(b_we ? write_addr : ctrl_b_addr),
        .b_din(b_din),
        .b_dout(b_dout),

        .c_we(ctrl_c_we),
        .c_addr(actual_c_addr),
        .c_din(ctrl_c_din),
        .c_dout(c_dout)
    );

    // --------------------------------
    // MATRIX CONTROLLER
    // --------------------------------

    matrix_controller controller_inst (
        .clk(clk),
        .reset(reset),
        .start(start),

        .a_dout(a_dout),
        .b_dout(b_dout),

        .a_addr(ctrl_a_addr),
        .b_addr(ctrl_b_addr),

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

        .array_enable(array_enable),
        .array_clear(array_clear),

        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33),

        .c_we(ctrl_c_we),
        .c_addr(ctrl_c_addr),
        .c_din(ctrl_c_din),

        .busy(busy),
        .done(done)
    );

    // --------------------------------
    // 4x4 SYSTOLIC ARRAY
    // --------------------------------

    systolic_array_4x4 array_inst (
        .clk(clk),
        .reset(reset),
        .clear(array_clear),
        .enable(array_enable),

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

    always #5 clk = ~clk;

    // --------------------------------
    // MAIN TEST
    // --------------------------------

    initial begin

        clk = 0;
        reset = 1;
        start = 0;

        a_we = 0;
        b_we = 0;

        write_addr = 0;
        a_din = 0;
        b_din = 0;

        c_read_addr = 0;
        errors = 0;

        $display("--------------------------------");
        $display(" CONTROLLER WRITEBACK TEST");
        $display("--------------------------------");

        // Prepare input matrices
        for (i = 0; i < 16; i = i + 1) begin
            expected_A[i] = i - 8;
            expected_B[i] = 15 - i;
        end

        // Calculate expected C = A x B
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin

                sum = 0;

                for (k = 0; k < 4; k = k + 1) begin
                    sum = sum +
                        expected_A[i*4+k] *
                        expected_B[k*4+j];
                end

                expected_C[i*4+j] = sum;

            end
        end

        // Reset
        repeat (2) @(negedge clk);
        reset = 0;

        // Write matrices into BRAM
        $display("Loading input matrices...");

        for (i = 0; i < 16; i = i + 1) begin

            @(negedge clk);

            a_we = 1;
            b_we = 1;

            write_addr = i;

            a_din = expected_A[i];
            b_din = expected_B[i];

        end

        @(negedge clk);

        a_we = 0;
        b_we = 0;

        // Start accelerator
        $display("Starting matrix multiplication...");

        start = 1;

        @(negedge clk);
        start = 0;

        // Wait for completion
        wait (done == 1'b1);

        $display("Computation completed!");
        $display("C memory writeback completed!");
        $display("--------------------------------");
        $display("Reading C memory...");
        $display("--------------------------------");

        // Read and verify all 16 C memory locations
        for (i = 0; i < 16; i = i + 1) begin

            @(negedge clk);
            c_read_addr = i;

            // BRAM synchronous read
            @(posedge clk);
            #1;

            if (c_dout !== expected_C[i]) begin

                $display(
                    "FAIL C[%0d]: Expected %0d, Got %0d",
                    i,
                    expected_C[i],
                    c_dout
                );

                errors = errors + 1;

            end
            else begin

                $display(
                    "PASS C[%0d] = %0d",
                    i,
                    c_dout
                );

            end

        end

        $display("--------------------------------");

        if (errors == 0)
            $display("ALL 16 C MEMORY WRITEBACK CHECKS PASSED!");
        else
            $display("TEST FAILED: %0d ERRORS", errors);

        $display("--------------------------------");

        $finish;

    end

    // Simulation timeout
    initial begin
        #5000;
        $display("ERROR: SIMULATION TIMEOUT!");
        $finish;
    end

endmodule
