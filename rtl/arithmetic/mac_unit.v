
module mac_unit (
    input clk,
    input reset,
    input clear,
    input enable,

    input signed [7:0] a,
    input signed [7:0] b,

    output reg signed [31:0] accumulator
);

    wire signed [15:0] product;

    // Instantiate the INT8 multiplier
    int8_multiplier multiplier_inst (
        .a(a),
        .b(b),
        .product(product)
    );

    // MAC operation
    always @(posedge clk) begin

        if (reset) begin
            accumulator <= 32'sd0;
        end

        else if (clear) begin
            accumulator <= 32'sd0;
        end

        else if (enable) begin
            accumulator <= accumulator +
                {{16{product[15]}}, product};
        end

    end

endmodule
