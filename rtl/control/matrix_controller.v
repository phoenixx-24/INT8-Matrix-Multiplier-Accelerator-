
module matrix_controller (
    input wire clk,
    input wire reset,
    input wire start,

    // BRAM read data
    input wire signed [7:0] a_dout,
    input wire signed [7:0] b_dout,

    // BRAM addresses
    output reg [3:0] a_addr,
    output reg [3:0] b_addr,

    // Systolic array data inputs
    output wire signed [7:0] a_row0,
    output wire signed [7:0] a_row1,
    output wire signed [7:0] a_row2,
    output wire signed [7:0] a_row3,

    output wire signed [7:0] b_col0,
    output wire signed [7:0] b_col1,
    output wire signed [7:0] b_col2,
    output wire signed [7:0] b_col3,

    // Systolic array control
    output reg [3:0] valid_row,
    output reg [3:0] valid_col,
    output reg array_enable,
    output reg array_clear,

    // Systolic array results
    input wire signed [31:0] c00,
    input wire signed [31:0] c01,
    input wire signed [31:0] c02,
    input wire signed [31:0] c03,
    input wire signed [31:0] c10,
    input wire signed [31:0] c11,
    input wire signed [31:0] c12,
    input wire signed [31:0] c13,
    input wire signed [31:0] c20,
    input wire signed [31:0] c21,
    input wire signed [31:0] c22,
    input wire signed [31:0] c23,
    input wire signed [31:0] c30,
    input wire signed [31:0] c31,
    input wire signed [31:0] c32,
    input wire signed [31:0] c33,

    // C memory write interface
    output reg c_we,
    output reg [3:0] c_addr,
    output reg signed [31:0] c_din,

    output reg busy,
    output reg done
);

    localparam IDLE  = 3'd0;
    localparam LOAD  = 3'd1;
    localparam CLEAR = 3'd2;
    localparam FEED  = 3'd3;
    localparam DRAIN = 3'd4;
    localparam STORE = 3'd5;
    localparam DONE  = 3'd6;

    reg [2:0] state;
    reg [2:0] next_state;

    reg [4:0] load_count;
    reg load_valid;

    reg [3:0] feed_count;
    reg [1:0] drain_count;
    reg [3:0] store_count;

    reg signed [7:0] matrix_A [0:15];
    reg signed [7:0] matrix_B [0:15];

    reg signed [7:0] a_feed [0:3];
    reg signed [7:0] b_feed [0:3];

    integer r;
    integer c;

    assign a_row0 = a_feed[0];
    assign a_row1 = a_feed[1];
    assign a_row2 = a_feed[2];
    assign a_row3 = a_feed[3];

    assign b_col0 = b_feed[0];
    assign b_col1 = b_feed[1];
    assign b_col2 = b_feed[2];
    assign b_col3 = b_feed[3];

    // Sequential counters and memory loading
    always @(posedge clk) begin
        if (reset) begin
            state       <= IDLE;
            load_count  <= 0;
            load_valid  <= 0;
            feed_count  <= 0;
            drain_count <= 0;
            store_count <= 0;
        end
        else begin
            state <= next_state;

            if (state == IDLE && start) begin
                load_count <= 0;
                load_valid <= 0;
            end
            else if (state == LOAD) begin
                if (load_count < 16) begin
                    if (load_valid) begin
                        matrix_A[load_count - 1] <= a_dout;
                        matrix_B[load_count - 1] <= b_dout;
                    end
                    load_count <= load_count + 1'b1;
                    load_valid <= 1'b1;
                end
                else if (load_valid) begin
                    matrix_A[15] <= a_dout;
                    matrix_B[15] <= b_dout;
                end
            end
            else if (state == CLEAR) begin
                feed_count  <= 0;
                drain_count <= 0;
            end
            else if (state == FEED) begin
                if (feed_count == 6) begin
                    feed_count  <= 0;
                    drain_count <= 0;
                end
                else begin
                    feed_count <= feed_count + 1'b1;
                end
            end
            else if (state == DRAIN) begin
                if (drain_count == 2) begin
                    drain_count <= 0;
                    store_count <= 0;
                end
                else begin
                    drain_count <= drain_count + 1'b1;
                end
            end
            else if (state == STORE) begin
                if (store_count < 15)
                    store_count <= store_count + 1'b1;
            end
        end
    end

    // FSM next-state logic
    always @(*) begin
        next_state = state;

        case (state)
            IDLE:
                if (start)
                    next_state = LOAD;

            LOAD:
                if (load_count == 16 && load_valid)
                    next_state = CLEAR;

            CLEAR:
                next_state = FEED;

            FEED:
                if (feed_count == 6)
                    next_state = DRAIN;

            DRAIN:
                if (drain_count == 2)
                    next_state = STORE;

            STORE:
                if (store_count == 15)
                    next_state = DONE;

            DONE:
                next_state = IDLE;

            default:
                next_state = IDLE;
        endcase
    end

    // A and B BRAM read addresses
    always @(*) begin
        a_addr = 0;
        b_addr = 0;

        if (state == LOAD) begin
            if (load_count < 16) begin
                a_addr = load_count[3:0];
                b_addr = load_count[3:0];
            end
            else begin
                a_addr = 15;
                b_addr = 15;
            end
        end
    end

    // Input scheduler
    always @(*) begin
        for (r = 0; r < 4; r = r + 1)
            a_feed[r] = 0;

        for (c = 0; c < 4; c = c + 1)
            b_feed[c] = 0;

        valid_row = 0;
        valid_col = 0;

        if (state == FEED) begin
            for (r = 0; r < 4; r = r + 1) begin
                if ((feed_count >= r) && (feed_count <= r + 3)) begin
                    a_feed[r] =
                        matrix_A[r*4 + (feed_count-r)];
                    valid_row[r] = 1'b1;
                end
            end

            for (c = 0; c < 4; c = c + 1) begin
                if ((feed_count >= c) && (feed_count <= c + 3)) begin
                    b_feed[c] =
                        matrix_B[(feed_count-c)*4 + c];
                    valid_col[c] = 1'b1;
                end
            end
        end
    end

    // Systolic array controls
    always @(*) begin
        array_enable = 0;
        array_clear  = 0;

        if (state == CLEAR)
            array_clear = 1;

        if ((state == FEED) || (state == DRAIN))
            array_enable = 1;
    end

    // C memory writeback
    always @(*) begin
        c_we   = 0;
        c_addr = 0;
        c_din  = 0;

        if (state == STORE) begin
            c_we   = 1;
            c_addr = store_count;

            case (store_count)
                0:  c_din = c00;
                1:  c_din = c01;
                2:  c_din = c02;
                3:  c_din = c03;

                4:  c_din = c10;
                5:  c_din = c11;
                6:  c_din = c12;
                7:  c_din = c13;

                8:  c_din = c20;
                9:  c_din = c21;
                10: c_din = c22;
                11: c_din = c23;

                12: c_din = c30;
                13: c_din = c31;
                14: c_din = c32;
                15: c_din = c33;

                default: c_din = 0;
            endcase
        end
    end

    // Busy and done status
    always @(*) begin
        busy = 1;
        done = 0;

        if (state == IDLE)
            busy = 0;

        if (state == DONE) begin
            busy = 0;
            done = 1;
        end
    end

endmodule
