module alu(
	input[7:0] src1,
	input[7:0] src2,
	output[7:0] result,
	output not_equals
);

assign result = src1 + src2;
assign not_equals = ~(src1 == src2); 
endmodule
