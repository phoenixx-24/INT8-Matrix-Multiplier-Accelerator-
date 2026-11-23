
`timescale 1ns/1ps

module tb_controller_load;

    reg clk;
    reg reset;
    reg start;

    reg a_we, b_we, c_we;
    reg [3:0] write_addr;
    reg signed [7:0] a_din, b_din;

    wire [3:0] a_addr, b_addr;

    wire signed [7:0] a_dout, b_dout;
    wire signed [31:0] c_dout;

    wire busy, done;

    reg signed [7:0] expected_A [0:15];
    reg signed [7:0] expected_B [0:15];

    integer i;
    integer errors;

    // Memory system
    matrix_memory_system memory_inst (
        .clk(clk),

        .a_we(a_we),
        .a_addr(a_we ? write_addr : a_addr),
        .a_din(a_din),
        .a_dout(a_dout),

        .b_we(b_we),
        .b_addr(b_we ? write_addr : b_addr),
        .b_din(b_din),
        .b_dout(b_dout),

        .c_we(c_we),
        .c_addr(4'd0),
        .c_din(32'd0),
        .c_dout(c_dout)
    );

    // Controller
    matrix_controller controller_inst (
        .clk(clk),
        .reset(reset),
        .start(start),

        .a_dout(a_dout),
        .b_dout(b_dout),

        .a_addr(a_addr),
        .b_addr(b_addr),

        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        start = 0;

        a_we = 0;
        b_we = 0;
        c_we = 0;

        write_addr = 0;
        a_din = 0;
        b_din = 0;

        errors = 0;

        // Prepare expected matrix values
        for (i = 0; i < 16; i = i + 1) begin
            expected_A[i] = i - 8;
            expected_B[i] = 15 - i;
        end

        $display("--------------------------------");
        $display(" CONTROLLER BRAM LOAD TEST");
        $display("--------------------------------");

        // Reset controller
        @(posedge clk);
        #1;

        @(negedge clk);
        reset = 0;

        // --------------------------------
        // WRITE A AND B MEMORIES
        // --------------------------------

        $display("Writing A and B memories...");

        for (i = 0; i < 16; i = i + 1) begin

            @(negedge clk);

            a_we = 1;
            b_we = 1;

            write_addr = i;

            a_din = expected_A[i];
            b_din = expected_B[i];

        end

        @(negedge clk);

        a_we = 0;
        b_we = 0;

        $display("Memory initialization completed.");

        // --------------------------------
        // START CONTROLLER
        // --------------------------------

        $display("Starting controller...");

        start = 1;

        @(negedge clk);
        start = 0;

        // Wait for controller to finish loading
        wait (done == 1'b1);

        #1;

        $display("Controller completed loading.");
        $display("Checking internal matrix registers...");

        // --------------------------------
        // VERIFY MATRIX A
        // --------------------------------

        for (i = 0; i < 16; i = i + 1) begin

            if (controller_inst.matrix_A[i] !== expected_A[i]) begin

                $display(
                    "FAIL A[%0d]: Expected %0d, Got %0d",
                    i,
                    expected_A[i],
                    controller_inst.matrix_A[i]
                );

                errors = errors + 1;

            end
            else begin

                $display(
                    "PASS A[%0d] = %0d",
                    i,
                    controller_inst.matrix_A[i]
                );

            end

        end

        // --------------------------------
        // VERIFY MATRIX B
        // --------------------------------

        for (i = 0; i < 16; i = i + 1) begin

            if (controller_inst.matrix_B[i] !== expected_B[i]) begin

                $display(
                    "FAIL B[%0d]: Expected %0d, Got %0d",
                    i,
                    expected_B[i],
                    controller_inst.matrix_B[i]
                );

                errors = errors + 1;

            end
            else begin

                $display(
                    "PASS B[%0d] = %0d",
                    i,
                    controller_inst.matrix_B[i]
                );

            end

        end

        // --------------------------------
        // FINAL RESULT
        // --------------------------------

        $display("--------------------------------");

        if (errors == 0)
            $display("ALL 32 BRAM LOAD CHECKS PASSED!");
        else
            $display("TEST FAILED: %0d ERRORS", errors);

        $display("--------------------------------");

        $finish;

    end

    // Timeout protection
    initial begin
        #5000;
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
