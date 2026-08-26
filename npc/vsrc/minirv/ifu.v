module ifu(
input clk,
input rst,
input[31:0] next_pc,
output reg [31:0] curr_pc,
output reg [31:0] instr
);

import "DPI-C" function int pmem_read(input int raddr);

always @(posedge clk) begin
	if(rst) begin
		curr_pc <= 32'h80000000;
	end else begin
		curr_pc <= next_pc;
	end
end

assign instr = pmem_read(curr_pc);
endmodule
