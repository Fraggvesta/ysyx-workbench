module sim_top(
input clk,
input rst,

output [31:0] pc,
output [31:0] ra,
output [31:0] a0,
output ebreak,
output is_valid
);

wire ifu_reqValid, ifu_respValid;
wire [31:0] ifu_addr, ifu_rdata;
wire lsu_reqValid, lsu_respValid, lsu_wen;
wire [31:0] lsu_addr, lsu_wdata, lsu_rdata;
wire [3:0] lsu_wmask;

minirv cpu (
	.clk(clk), .rst(rst),
	.ifu_reqValid(ifu_reqValid),
 	.ifu_addr(ifu_addr),
	.ifu_respValid(ifu_respValid), 
	.ifu_rdata(ifu_rdata),
	.lsu_reqValid(lsu_reqValid),
 	.lsu_addr(lsu_addr),
	.lsu_wen(lsu_wen),
 	.lsu_wdata(lsu_wdata),
 	.lsu_wmask(lsu_wmask),
	.lsu_respValid(lsu_respValid),
 	.lsu_rdata(lsu_rdata),	
	.pc(pc), .ra(ra), .a0(a0),
	.ebreak(ebreak), .is_valid(is_valid)
);

mem pmem (
	.clk(clk), .rst(rst),
	.ifu_reqValid(ifu_reqValid),
 	.ifu_addr(ifu_addr),
	.ifu_respValid(ifu_respValid),
 	.ifu_rdata(ifu_rdata),
	.lsu_reqValid(lsu_reqValid),
 	.lsu_addr(lsu_addr),
	.lsu_wen(lsu_wen),
 	.lsu_wdata(lsu_wdata),
 	.lsu_wmask(lsu_wmask),
	.lsu_respValid(lsu_respValid),
 	.lsu_rdata(lsu_rdata)
);
endmodule
