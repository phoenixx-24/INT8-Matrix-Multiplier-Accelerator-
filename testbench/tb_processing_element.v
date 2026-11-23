
`timescale 1ns/1ps

module tb_processing_element;

    reg clk, reset, clear, enable;
    reg a_valid_in, b_valid_in;

    reg signed [7:0] a_in, b_in;

    wire signed [7:0] a_out, b_out;
    wire a_valid_out, b_valid_out;

    wire signed [31:0] accumulator;

    processing_element uut (
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

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        clear = 0;
        enable = 0;

        a_valid_in = 0;
        b_valid_in = 0;

        a_in = 0;
        b_in = 0;

        @(negedge clk);
        reset = 0;
        enable = 1;

        // Test 1
        a_in = 10;
        b_in = 20;
        a_valid_in = 1;
        b_valid_in = 1;

        @(negedge clk);

        // Test 2
        a_in = 5;
        b_in = 4;

        @(negedge clk);

        // Invalid B
        a_in = 100;
        b_in = 100;
        b_valid_in = 0;

        @(negedge clk);

        // Both valid again
        a_in = -2;
        b_in = 10;
        b_valid_in = 1;

        @(negedge clk);

        // Clear
        clear = 1;

        @(negedge clk);
        clear = 0;

        // Test after clear
        a_in = 7;
        b_in = 6;

        @(negedge clk);

        $finish;

    end

    initial begin

        $monitor(
        "TIME=%0t A=%d B=%d AV=%b BV=%b | AO=%d BO=%d AOV=%b BOV=%b | ACC=%d",
        $time, a_in, b_in, a_valid_in, b_valid_in,
        a_out, b_out, a_valid_out, b_valid_out,
        accumulator
        );

    end

endmodule
