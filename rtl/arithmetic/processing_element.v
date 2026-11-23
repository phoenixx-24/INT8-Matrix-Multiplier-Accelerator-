
module processing_element (

    input clk,
    input reset,
    input clear,
    input enable,

    // Independent input validity
    input a_valid_in,
    input b_valid_in,

    // Data inputs
    input signed [7:0] a_in,
    input signed [7:0] b_in,

    // Data forwarding
    output reg signed [7:0] a_out,
    output reg signed [7:0] b_out,

    // Independent validity forwarding
    output reg a_valid_out,
    output reg b_valid_out,

    // Accumulated result
    output signed [31:0] accumulator

);

    wire mac_enable;

    // MAC runs only when both inputs are valid
    assign mac_enable =
        enable & a_valid_in & b_valid_in;

    // MAC unit
    mac_unit mac_inst (

        .clk(clk),
        .reset(reset),
        .clear(clear),
        .enable(mac_enable),

        .a(a_in),
        .b(b_in),

        .accumulator(accumulator)

    );

    // Forward A and B independently
    always @(posedge clk) begin

        if (reset) begin

            a_out <= 8'sd0;
            b_out <= 8'sd0;

            a_valid_out <= 1'b0;
            b_valid_out <= 1'b0;

        end

        else if (enable) begin

            a_out <= a_in;
            b_out <= b_in;

            a_valid_out <= a_valid_in;
            b_valid_out <= b_valid_in;

        end

        else begin

            a_valid_out <= 1'b0;
            b_valid_out <= 1'b0;

        end

    end

endmodule
