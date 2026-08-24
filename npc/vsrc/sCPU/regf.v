module regf(
	input[1:0] rd,
	input we,
	input clk,
	input res,
	input[7:0] data,
	input[1:0] rs1,
	input[1:0] rs2,
	output[7:0] rs1d,
	output[7:0] rs2d,
	output[7:0] r2
);

reg[7:0] rf [0:3];

always @(posedge clk) begin
	if(res) begin
		rf[0] <= 0;
		rf[1] <= 0;
		rf[2] <= 0;
		rf[3] <= 0;
	end else if(we) begin
		rf[rd] <= data;
	end
end

assign r2 = rf[2];
assign rs1d = rf[rs1];
assign rs2d = rf[rs2];
endmodule
