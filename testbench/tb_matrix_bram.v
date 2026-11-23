
`timescale 1ns/1ps

module tb_matrix_bram;

    reg clk;
    reg we;
    reg [3:0] addr;
    reg [7:0] din;

    wire [7:0] dout;

    integer errors;

    matrix_bram #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(4)
    ) dut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        we = 0;
        addr = 0;
        din = 0;
        errors = 0;

        $display("--------------------------------");
        $display("       BRAM MEMORY TEST");
        $display("--------------------------------");

        // Write values into memory
        $display("Writing memory...");

        @(negedge clk);

        we = 1;

        for (integer i = 0; i < 16; i = i + 1) begin

            addr = i;
            din = i + 10;

            @(negedge clk);

        end

        // Stop writing
        we = 0;

        // Read and verify memory
        $display("Reading memory...");

        for (integer i = 0; i < 16; i = i + 1) begin

            addr = i;

            @(posedge clk);
            #1;

            if (dout == i + 10) begin

                $display(
                    "PASS: Address %0d = %0d",
                    i, dout
                );

            end
            else begin

                $display(
                    "FAIL: Address %0d Expected=%0d Actual=%0d",
                    i, i+10, dout
                );

                errors = errors + 1;

            end

            @(negedge clk);

        end

        $display("--------------------------------");

        if (errors == 0)
            $display("ALL 16 MEMORY LOCATIONS PASSED!");
        else
            $display("MEMORY TEST FAILED: %0d errors", errors);

        $display("--------------------------------");

        $finish;

    end

endmodule
