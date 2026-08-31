module ysyx_20237522_exu(
input[31:0] src1,
input[31:0] src2,
input[31:0] imm,
input alu_sel,
output reg [31:0] result
);

always @(*) begin
	if(alu_sel) result = src1 + imm;
	else result = src1 + src2;
end

endmodule
