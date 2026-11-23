
`timescale 1ns/1ps

module tb_systolic_reset_clear;

    reg clk, reset, clear, enable;
    reg a_valid_in, b_valid_in;
    reg signed [7:0] a_in, b_in;

    wire signed [7:0] a_out, b_out;
    wire a_valid_out, b_valid_out;
    wire signed [31:0] accumulator;

    integer errors;

    always #5 clk = ~clk;

    processing_element dut (
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .enable(enable),
        .a_valid_in(a_valid_in),
        .b_valid_in(b_valid_in),
        .a_in(a_in),
        .b_in(b_in),
        .a_out(a_out),
        .b_out(b_out),
        .a_valid_out(a_valid_out),
        .b_valid_out(b_valid_out),
        .accumulator(accumulator)
    );

    initial begin

        clk = 0;
        reset = 1;
        clear = 0;
        enable = 1;

        a_valid_in = 0;
        b_valid_in = 0;
        a_in = 0;
        b_in = 0;

        errors = 0;

        $display("--------------------------------");
        $display(" RESET AND CLEAR TEST");
        $display("--------------------------------");

        // TEST 1: Reset
        @(negedge clk);
        #1;

        if (accumulator == 0 &&
            a_out == 0 && b_out == 0 &&
            a_valid_out == 0 && b_valid_out == 0)
            $display("PASS: Initial reset");
        else begin
            $display("FAIL: Initial reset");
            errors = errors + 1;
        end

        reset = 0;

        // TEST 2: Accumulate 10*20 = 200
        a_in = 10;
        b_in = 20;
        a_valid_in = 1;
        b_valid_in = 1;

        @(negedge clk);
        #1;

        if (accumulator == 200)
            $display("PASS: MAC accumulation = 200");
        else begin
            $display("FAIL: MAC accumulation, got %0d", accumulator);
            errors = errors + 1;
        end

        // TEST 3: Clear accumulator
        a_valid_in = 0;
        b_valid_in = 0;
        clear = 1;

        @(negedge clk);
        #1;

        if (accumulator == 0)
            $display("PASS: Clear accumulator");
        else begin
            $display("FAIL: Clear, got %0d", accumulator);
            errors = errors + 1;
        end

        // TEST 4: Verify forwarding still works after clear
        clear = 0;
        a_in = 7;
        b_in = 6;
        a_valid_in = 1;
        b_valid_in = 1;

        @(negedge clk);
        #1;

        if (accumulator == 42 &&
            a_out == 7 && b_out == 6 &&
            a_valid_out == 1 && b_valid_out == 1)
            $display("PASS: Forwarding and MAC after clear");
        else begin
            $display("FAIL: Forwarding after clear");
            errors = errors + 1;
        end

        // TEST 5: Full reset
        reset = 1;
        a_valid_in = 0;
        b_valid_in = 0;

        @(negedge clk);
        #1;

        if (accumulator == 0 &&
            a_out == 0 && b_out == 0 &&
            a_valid_out == 0 && b_valid_out == 0)
            $display("PASS: Full reset");
        else begin
            $display("FAIL: Full reset");
            errors = errors + 1;
        end

        $display("--------------------------------");

        if (errors == 0)
            $display("ALL RESET/CLEAR TESTS PASSED!");
        else
            $display("TEST FAILED: %0d errors", errors);

        $display("--------------------------------");

        $finish;
    end

endmodule
