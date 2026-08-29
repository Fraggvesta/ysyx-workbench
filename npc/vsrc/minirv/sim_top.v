module sim_top(
input clk,
input rst,

output [31:0] dmem_addr,
output [31:0] dmem_wdata,
output [3:0]  dmem_wmask,
output dmem_we,
output dmem_re,
input  [31:0] dmem_rdata,

output [31:0] pc,
output [31:0] ra,
output [31:0] a0,
output ebreak,
output is_valid
);

wire [31:0] ifu_raddr, ifu_rdata;

minirv cpu (
	.clk(clk), .rst(rst),
	.imem_data(ifu_rdata),
	.dmem_rdata(dmem_rdata),
	.imem_addr(ifu_raddr),
	.dmem_addr(dmem_addr),
	.dmem_wdata(dmem_wdata),
	.dmem_wmask(dmem_wmask),
	.dmem_we(dmem_we),
	.dmem_re(dmem_re),
	.pc(pc), .ra(ra), .a0(a0),
	.ebreak(ebreak), .is_valid(is_valid)
);

mem imem (
	.clk(clk),
	.raddr(ifu_raddr),
	.rdata(ifu_rdata)
);

endmodule
