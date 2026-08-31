module mem(
input	clk,
input rst,
input[31:0] lsu_addr,
input lsu_wen,
input [31:0] lsu_wdata,
input[3:0] lsu_wmask,
input[31:0] ifu_addr,
input lsu_reqValid,
input ifu_reqValid,

output reg ifu_respValid,
output reg lsu_respValid,
output reg[31:0] ifu_rdata,
output reg[31:0] lsu_rdata
);

import "DPI-C" function int pmem_read(input int addr);
import "DPI-C" function void pmem_write(input int addr, input int wdata, input byte wmask);

reg ifu_pending, lsu_pending, lsu_wen_q;
reg[31:0] ifu_addr_q, lsu_addr_q, lsu_wdata_q;
reg[3:0] ifu_cnt, lsu_cnt, lsu_wmask_q;

always @(posedge clk) begin
	if(rst) begin
		ifu_respValid <= 1'b0;
		lsu_respValid <= 1'b0;
		ifu_rdata <=32'b0;
		lsu_rdata <= 32'b0;
		ifu_pending <= 1'b0;
	end else begin
	ifu_respValid <= 1'b0;
	lsu_respValid <= 1'b0;
	if(!ifu_pending && ifu_reqValid) begin
		ifu_addr_q <= ifu_addr;
		ifu_cnt <= 4'd2;
		ifu_pending <= 1'b1;
	end else if(ifu_pending) begin
		if(ifu_cnt == 4'd0) begin
			ifu_rdata <= pmem_read(ifu_addr_q);
			ifu_respValid <= 1'b1;
		ifu_pending <= 1'b0;
		end else begin
			ifu_cnt <= ifu_cnt - 4'd1;
		end
	end

	if(!lsu_pending && lsu_reqValid) begin
		lsu_addr_q <= lsu_addr;
		lsu_wdata_q <= lsu_wdata;
		lsu_wmask_q <= lsu_wmask;
		lsu_wen_q <= lsu_wen;
		lsu_cnt <= 4'd2;
		lsu_pending <= 1'b1;
	end else if(lsu_pending) begin
		if(lsu_cnt == 4'd0) begin
			lsu_rdata <= !lsu_wen_q ? pmem_read(lsu_addr_q) : 32'b0;
			if(lsu_wen_q) pmem_write(lsu_addr_q, lsu_wdata_q, {4'b0, lsu_wmask_q});
			lsu_respValid <= 1'b1;
			lsu_pending <= 1'b0;
		end else begin
			lsu_cnt <= lsu_cnt - 4'd1;
		end
	end
end
end



endmodule
