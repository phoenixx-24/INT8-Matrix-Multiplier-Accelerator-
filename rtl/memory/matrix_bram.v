
module matrix_bram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input clk,

    input we,
    input [ADDR_WIDTH-1:0] addr,

    input [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
);

    // Memory storage
    reg [DATA_WIDTH-1:0] mem [0:15];

    // Synchronous read and write
    always @(posedge clk) begin

        if (we)
            mem[addr] <= din;

        dout <= mem[addr];

    end

endmodule
