
`timescale 1ns/1ps

module tb_int8_multiplier;

    reg signed [7:0] a;
    reg signed [7:0] b;
    wire signed [15:0] product;

    int8_multiplier uut (
        .a(a),
        .b(b),
        .product(product)
    );

    initial begin

        $monitor("A=%d B=%d PRODUCT=%d",
                  a, b, product);

        a = 10;  b = 20;
        #10;

        a = -10; b = 20;
        #10;

        a = -5;  b = -6;
        #10;

        a = 127; b = 127;
        #10;

        a = -128; b = 127;
        #10;

        $finish;
    end

endmodule
