
`timescale 1ns/1ps

module tb_matrix_controller;

    reg clk;
    reg reset;
    reg start;

    wire busy;
    wire done;

    matrix_controller dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin

        $display("--------------------------------");
        $display(" MATRIX CONTROLLER FSM TEST");
        $display("--------------------------------");

        clk = 0;
        reset = 1;
        start = 0;

        // Apply reset
        @(posedge clk);
        #1;

        if (busy == 0 && done == 0)
            $display("PASS: Initial IDLE state");
        else
            $display("FAIL: Initial IDLE state");

        // Release reset
        @(negedge clk);
        reset = 0;

        // Start operation
        start = 1;

        @(posedge clk);
        #1;

        if (busy == 1)
            $display("PASS: IDLE -> LOAD");
        else
            $display("FAIL: LOAD state");

        @(negedge clk);
        start = 0;

        // LOAD -> CLEAR
        @(posedge clk);
        #1;
        if (busy)
            $display("PASS: LOAD -> CLEAR");

        // CLEAR -> FEED
        @(posedge clk);
        #1;
        if (busy)
            $display("PASS: CLEAR -> FEED");

        // FEED -> DRAIN
        @(posedge clk);
        #1;
        if (busy)
            $display("PASS: FEED -> DRAIN");

        // DRAIN -> STORE
        @(posedge clk);
        #1;
        if (busy)
            $display("PASS: DRAIN -> STORE");

        // STORE -> DONE
        @(posedge clk);
        #1;

        if (done == 1 && busy == 0)
            $display("PASS: STORE -> DONE");
        else
            $display("FAIL: DONE signal");

        // DONE -> IDLE
        @(posedge clk);
        #1;

        if (done == 0 && busy == 0)
            $display("PASS: DONE -> IDLE");
        else
            $display("FAIL: Return to IDLE");

        $display("--------------------------------");
        $display("FSM TEST COMPLETED");
        $display("--------------------------------");

        $finish;

    end

endmodule
