
`timescale 1ns/1ps

module tb_int8_accelerator_top;

    reg clk;
    reg reset;
    reg start;

    reg load_we;
    reg [3:0] load_addr;

    reg signed [7:0] a_load_data;
    reg signed [7:0] b_load_data;

    reg [3:0] c_read_addr;
    wire signed [31:0] c_read_data;

    wire busy;
    wire done;

    reg signed [7:0] expected_A [0:15];
    reg signed [7:0] expected_B [0:15];

    integer expected_C [0:15];

    integer i, j, k;
    integer sum;
    integer errors;

    // --------------------------------
    // TOP LEVEL DUT
    // --------------------------------

    int8_accelerator_top dut (

        .clk(clk),
        .reset(reset),
        .start(start),

        .load_we(load_we),
        .load_addr(load_addr),

        .a_load_data(a_load_data),
        .b_load_data(b_load_data),

        .c_read_addr(c_read_addr),
        .c_read_data(c_read_data),

        .busy(busy),
        .done(done)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // --------------------------------
    // MAIN TEST
    // --------------------------------

    initial begin

        clk = 0;
        reset = 1;
        start = 0;

        load_we = 0;
        load_addr = 0;

        a_load_data = 0;
        b_load_data = 0;

        c_read_addr = 0;

        errors = 0;

        $display("------------------------------------");
        $display(" INT8 ACCELERATOR TOP-LEVEL TEST");
        $display("------------------------------------");

        // Prepare matrices
        for (i = 0; i < 16; i = i + 1) begin
            expected_A[i] = i - 8;
            expected_B[i] = 15 - i;
        end

        // Calculate expected C = A x B
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin

                sum = 0;

                for (k = 0; k < 4; k = k + 1) begin
                    sum = sum +
                        expected_A[i*4+k] *
                        expected_B[k*4+j];
                end

                expected_C[i*4+j] = sum;

            end
        end

        // --------------------------------
        // RESET
        // --------------------------------

        repeat (3) @(negedge clk);

        reset = 0;

        $display("PASS: Reset released");

        // --------------------------------
        // LOAD INPUT MATRICES
        // --------------------------------

        $display("Loading A and B matrices...");

        for (i = 0; i < 16; i = i + 1) begin

            @(negedge clk);

            load_we = 1;
            load_addr = i;

            a_load_data = expected_A[i];
            b_load_data = expected_B[i];

        end

        @(negedge clk);

        load_we = 0;

        $display("PASS: Input matrices loaded");

        // --------------------------------
        // START ACCELERATOR
        // --------------------------------

        $display("Starting accelerator...");

        start = 1;

        @(negedge clk);

        start = 0;

        // --------------------------------
        // WAIT FOR COMPLETION
        // --------------------------------

        wait (done == 1'b1);

        @(negedge clk);

        $display("PASS: Accelerator completed");
        $display("Reading result matrix...");
        $display("------------------------------------");

        // --------------------------------
        // READ AND VERIFY C MEMORY
        // --------------------------------

        for (i = 0; i < 16; i = i + 1) begin

            @(negedge clk);

            c_read_addr = i;

            // Synchronous BRAM read
            @(posedge clk);
            #1;

            if (c_read_data !== expected_C[i]) begin

                $display(
                    "FAIL C[%0d]: Expected %0d, Got %0d",
                    i,
                    expected_C[i],
                    c_read_data
                );

                errors = errors + 1;

            end
            else begin

                $display(
                    "PASS C[%0d] = %0d",
                    i,
                    c_read_data
                );

            end

        end

        // --------------------------------
        // FINAL RESULT
        // --------------------------------

        $display("------------------------------------");

        if (errors == 0)
            $display("ALL 16 TOP-LEVEL RESULTS PASSED!");
        else
            $display("TEST FAILED: %0d ERRORS", errors);

        $display("------------------------------------");

        $finish;

    end

    // Simulation timeout
    initial begin

        #5000;

        $display("ERROR: SIMULATION TIMEOUT!");
        $finish;

    end

endmodule
