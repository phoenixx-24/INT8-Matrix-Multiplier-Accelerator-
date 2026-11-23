
module matrix_memory_system (

    input clk,

    // Matrix A memory interface
    input a_we,
    input [3:0] a_addr,
    input signed [7:0] a_din,
    output wire signed [7:0] a_dout,

    // Matrix B memory interface
    input b_we,
    input [3:0] b_addr,
    input signed [7:0] b_din,
    output wire signed [7:0] b_dout,

    // Matrix C memory interface
    input c_we,
    input [3:0] c_addr,
    input signed [31:0] c_din,
    output wire signed [31:0] c_dout

);

    // Matrix A: 16 x 8-bit
    matrix_bram #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(4)
    ) memory_A (
        .clk(clk),
        .we(a_we),
        .addr(a_addr),
        .din(a_din),
        .dout(a_dout)
    );

    // Matrix B: 16 x 8-bit
    matrix_bram #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(4)
    ) memory_B (
        .clk(clk),
        .we(b_we),
        .addr(b_addr),
        .din(b_din),
        .dout(b_dout)
    );

    // Matrix C: 16 x 32-bit
    matrix_bram #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(4)
    ) memory_C (
        .clk(clk),
        .we(c_we),
        .addr(c_addr),
        .din(c_din),
        .dout(c_dout)
    );

endmodule
