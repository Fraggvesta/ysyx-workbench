module sim_top(
input clk,
input rst,

output [31:0] pc,
output [31:0] ra,
output [31:0] a0,
output ebreak,
output is_valid
);

wire [31:0] ifu_raddr, ifu_rdata, dmem_addr, dmem_wdata, dmem_rdata;
wire [3:0] dmem_wmask;
wire dmem_we, dmem_re;

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

mem pmem (
	.clk(clk),
	.lsu_addr(dmem_addr),
	.lsu_ren(dmem_re),
	.lsu_wen(dmem_we),
	.lsu_wdata(dmem_wdata),
	.lsu_wmask(dmem_wmask),
	.lsu_rdata(dmem_rdata),
	.ifu_rdata(ifu_rdata),
	.ifu_addr(ifu_raddr)
);

endmodule
