module mem(
input	clk,
input[31:0] raddr,

output reg[31:0] rdata
);

import "DPI-C" function int pmem_read(input int raddr);

always @(posedge clk) begin
		rdata <= pmem_read(raddr);
end



endmodule
