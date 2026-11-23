
`timescale 1ns/1ps

module tb_matrix_memory_system;

    reg clk;

    reg a_we, b_we, c_we;
    reg [3:0] a_addr, b_addr, c_addr;

    reg signed [7:0] a_din, b_din;
    reg signed [31:0] c_din;

    wire signed [7:0] a_dout, b_dout;
    wire signed [31:0] c_dout;

    integer i;
    integer errors;

    matrix_memory_system dut (
        .clk(clk),

        .a_we(a_we),
        .a_addr(a_addr),
        .a_din(a_din),
        .a_dout(a_dout),

        .b_we(b_we),
        .b_addr(b_addr),
        .b_din(b_din),
        .b_dout(b_dout),

        .c_we(c_we),
        .c_addr(c_addr),
        .c_din(c_din),
        .c_dout(c_dout)
    );

    always #5 clk = ~clk;

    reg signed [7:0] expected_A [0:15];
    reg signed [7:0] expected_B [0:15];
    reg signed [31:0] expected_C [0:15];

    initial begin
        clk = 0;
        errors = 0;

        a_we = 0;
        b_we = 0;
        c_we = 0;

        a_addr = 0;
        b_addr = 0;
        c_addr = 0;

        a_din = 0;
        b_din = 0;
        c_din = 0;

        // Matrix A: 1 to 16
        for (i = 0; i < 16; i = i + 1)
            expected_A[i] = i + 1;

        // Matrix B: Identity matrix
        for (i = 0; i < 16; i = i + 1)
            expected_B[i] = 0;

        expected_B[0]  = 1;
        expected_B[5]  = 1;
        expected_B[10] = 1;
        expected_B[15] = 1;

        // C memory test values
        for (i = 0; i < 16; i = i + 1)
            expected_C[i] = (i + 1) * 100;

        // -------------------------
        // WRITE A, B AND C MEMORY
        // -------------------------
        $display("--------------------------------");
        $display(" MATRIX MEMORY SYSTEM TEST");
        $display("--------------------------------");

        $display("Writing A, B and C memories...");

        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk);

            a_we = 1;
            b_we = 1;
            c_we = 1;

            a_addr = i;
            b_addr = i;
            c_addr = i;

            a_din = expected_A[i];
            b_din = expected_B[i];
            c_din = expected_C[i];
        end

        @(negedge clk);
        a_we = 0;
        b_we = 0;
        c_we = 0;

        // -------------------------
        // READ AND VERIFY A MEMORY
        // -------------------------
        $display("Reading A memory...");

        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk);
            a_addr = i;

            @(posedge clk);
            #1;

            if (a_dout !== expected_A[i]) begin
                $display("FAIL A[%0d]: Expected %0d, Got %0d",
                         i, expected_A[i], a_dout);
                errors = errors + 1;
            end
            else
                $display("PASS A[%0d] = %0d", i, a_dout);
        end

        // -------------------------
        // READ AND VERIFY B MEMORY
        // -------------------------
        $display("Reading B memory...");

        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk);
            b_addr = i;

            @(posedge clk);
            #1;

            if (b_dout !== expected_B[i]) begin
                $display("FAIL B[%0d]: Expected %0d, Got %0d",
                         i, expected_B[i], b_dout);
                errors = errors + 1;
            end
            else
                $display("PASS B[%0d] = %0d", i, b_dout);
        end

        // -------------------------
        // READ AND VERIFY C MEMORY
        // -------------------------
        $display("Reading C memory...");

        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk);
            c_addr = i;

            @(posedge clk);
            #1;

            if (c_dout !== expected_C[i]) begin
                $display("FAIL C[%0d]: Expected %0d, Got %0d",
                         i, expected_C[i], c_dout);
                errors = errors + 1;
            end
            else
                $display("PASS C[%0d] = %0d", i, c_dout);
        end

        // -------------------------
        // FINAL RESULT
        // -------------------------
        $display("--------------------------------");

        if (errors == 0)
            $display("ALL 48 MEMORY CHECKS PASSED!");
        else
            $display("TEST FAILED: %0d ERRORS", errors);

        $display("--------------------------------");

        $finish;
    end

endmodule
