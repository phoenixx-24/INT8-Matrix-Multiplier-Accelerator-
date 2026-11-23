
`timescale 1ns/1ps

module tb_mac_unit;

    reg clk;
    reg reset;
    reg clear;
    reg enable;

    reg signed [7:0] a;
    reg signed [7:0] b;

    wire signed [31:0] accumulator;

    mac_unit uut (
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .enable(enable),
        .a(a),
        .b(b),
        .accumulator(accumulator)
    );

    // Generate clock
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        clear = 0;
        enable = 0;
        a = 0;
        b = 0;

        // Reset
        #10;
        reset = 0;

        // Test 1: 10 * 20
        enable = 1;
        a = 10; b = 20;
        #10;

        // Test 2: 5 * 4
        a = 5; b = 4;
        #10;

        // Test 3: -2 * 10
        a = -2; b = 10;
        #10;

        // Test 4: 3 * 5
        a = 3; b = 5;
        #10;

        // Disable MAC
        enable = 0;
        #10;

        // Clear accumulator
        clear = 1;
        #10;
        clear = 0;

        // Test after clear: 7 * 6
        enable = 1;
        a = 7; b = 6;
        #10;

        $finish;
    end

    initial begin
        $monitor(
            "Time=%0t | A=%d | B=%d | ENABLE=%b | CLEAR=%b | ACC=%d",
            $time, a, b, enable, clear, accumulator
        );
    end

endmodule
