module mem(
input	clk,
input[31:0] lsu_addr,
input lsu_ren,
input lsu_wen,
input [31:0] lsu_wdata,
input[3:0] lsu_wmask,
input[31:0] ifu_addr,

output reg[31:0] ifu_rdata,
output reg[31:0] lsu_rdata
);

import "DPI-C" function int pmem_read(input int addr);
import "DPI-C" function void pmem_write(input int addr, input int wdata, input byte wmask);

always @(posedge clk) begin
	ifu_rdata <= pmem_read(ifu_addr);
	
	if(lsu_ren) begin
		lsu_rdata <= pmem_read(lsu_addr);
	end

	if(lsu_wen) begin
		pmem_write(lsu_addr, lsu_wdata, {4'b0, lsu_wmask});
	end
end



endmodule
