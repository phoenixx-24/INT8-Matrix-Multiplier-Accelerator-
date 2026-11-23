
module systolic_array_4x4 (
    input clk,
    input reset,
    input clear,
    input enable,

    // A inputs: one input stream per row
    input signed [7:0] a_row0,
    input signed [7:0] a_row1,
    input signed [7:0] a_row2,
    input signed [7:0] a_row3,

    // B inputs: one input stream per column
    input signed [7:0] b_col0,
    input signed [7:0] b_col1,
    input signed [7:0] b_col2,
    input signed [7:0] b_col3,

    // Independent valid signals
    input [3:0] valid_row,
    input [3:0] valid_col,

    // 16 accumulated outputs
    output signed [31:0] c00, c01, c02, c03,
    output signed [31:0] c10, c11, c12, c13,
    output signed [31:0] c20, c21, c22, c23,
    output signed [31:0] c30, c31, c32, c33
);

    // Horizontal A data paths
    wire signed [7:0] a_bus [0:3][0:4];

    // Vertical B data paths
    wire signed [7:0] b_bus [0:4][0:3];

    // A valid paths
    wire a_valid_bus [0:3][0:4];

    // B valid paths
    wire b_valid_bus [0:4][0:3];

    // Accumulator connections
    wire signed [31:0] acc [0:3][0:3];

    // Inject A data into the left side
    assign a_bus[0][0] = a_row0;
    assign a_bus[1][0] = a_row1;
    assign a_bus[2][0] = a_row2;
    assign a_bus[3][0] = a_row3;

    // Inject B data into the top side
    assign b_bus[0][0] = b_col0;
    assign b_bus[0][1] = b_col1;
    assign b_bus[0][2] = b_col2;
    assign b_bus[0][3] = b_col3;

    // Inject valid signals
    assign a_valid_bus[0][0] = valid_row[0];
    assign a_valid_bus[1][0] = valid_row[1];
    assign a_valid_bus[2][0] = valid_row[2];
    assign a_valid_bus[3][0] = valid_row[3];

    assign b_valid_bus[0][0] = valid_col[0];
    assign b_valid_bus[0][1] = valid_col[1];
    assign b_valid_bus[0][2] = valid_col[2];
    assign b_valid_bus[0][3] = valid_col[3];

    // Generate the 4x4 Processing Element array
    genvar i, j;

    generate
        for (i = 0; i < 4; i = i + 1) begin : ROW
            for (j = 0; j < 4; j = j + 1) begin : COL

                processing_element pe (
                    .clk(clk),
                    .reset(reset),
                    .clear(clear),
                    .enable(enable),

                    .a_valid_in(a_valid_bus[i][j]),
                    .b_valid_in(b_valid_bus[i][j]),

                    .a_in(a_bus[i][j]),
                    .b_in(b_bus[i][j]),

                    .a_out(a_bus[i][j+1]),
                    .b_out(b_bus[i+1][j]),

                    .a_valid_out(a_valid_bus[i][j+1]),
                    .b_valid_out(b_valid_bus[i+1][j]),

                    .accumulator(acc[i][j])
                );

            end
        end
    endgenerate

    // Connect internal accumulators to external outputs
    assign c00 = acc[0][0];
    assign c01 = acc[0][1];
    assign c02 = acc[0][2];
    assign c03 = acc[0][3];

    assign c10 = acc[1][0];
    assign c11 = acc[1][1];
    assign c12 = acc[1][2];
    assign c13 = acc[1][3];

    assign c20 = acc[2][0];
    assign c21 = acc[2][1];
    assign c22 = acc[2][2];
    assign c23 = acc[2][3];

    assign c30 = acc[3][0];
    assign c31 = acc[3][1];
    assign c32 = acc[3][2];
    assign c33 = acc[3][3];

endmodule
