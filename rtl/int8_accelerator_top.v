
module int8_accelerator_top (

    input wire clk,
    input wire reset,
    input wire start,

    // External input matrix loading
    input wire load_we,
    input wire [3:0] load_addr,
    input wire signed [7:0] a_load_data,
    input wire signed [7:0] b_load_data,

    // C memory read interface
    input wire [3:0] c_read_addr,
    output wire signed [31:0] c_read_data,

    // Accelerator status
    output wire busy,
    output wire done
);

    // --------------------------------
    // INTERNAL MEMORY SIGNALS
    // --------------------------------

    wire [3:0] ctrl_a_addr;
    wire [3:0] ctrl_b_addr;

    wire signed [7:0] a_dout;
    wire signed [7:0] b_dout;

    wire ctrl_c_we;
    wire [3:0] ctrl_c_addr;
    wire signed [31:0] ctrl_c_din;

    wire [3:0] memory_c_addr;

    assign memory_c_addr =
        ctrl_c_we ? ctrl_c_addr : c_read_addr;

    // --------------------------------
    // CONTROLLER SIGNALS
    // --------------------------------

    wire signed [7:0] a_row0, a_row1;
    wire signed [7:0] a_row2, a_row3;

    wire signed [7:0] b_col0, b_col1;
    wire signed [7:0] b_col2, b_col3;

    wire [3:0] valid_row;
    wire [3:0] valid_col;

    wire array_enable;
    wire array_clear;

    // --------------------------------
    // SYSTOLIC ARRAY RESULTS
    // --------------------------------

    wire signed [31:0] c00, c01, c02, c03;
    wire signed [31:0] c10, c11, c12, c13;
    wire signed [31:0] c20, c21, c22, c23;
    wire signed [31:0] c30, c31, c32, c33;

    // --------------------------------
    // MEMORY SYSTEM
    // --------------------------------

    matrix_memory_system memory_inst (

        .clk(clk),

        // Matrix A
        .a_we(load_we),
        .a_addr(load_we ? load_addr : ctrl_a_addr),
        .a_din(a_load_data),
        .a_dout(a_dout),

        // Matrix B
        .b_we(load_we),
        .b_addr(load_we ? load_addr : ctrl_b_addr),
        .b_din(b_load_data),
        .b_dout(b_dout),

        // Result matrix C
        .c_we(ctrl_c_we),
        .c_addr(memory_c_addr),
        .c_din(ctrl_c_din),
        .c_dout(c_read_data)
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

        // Systolic array results
        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33),

        // C memory writeback
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

endmodule
