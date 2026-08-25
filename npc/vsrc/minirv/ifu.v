module ifu(
input clk,
input rst,
input[31:0] pc,
output reg [31:0] pc_out
);

always @(posedge clk) begin
	if(rst) begin
		pc_out <= 0;
	end else begin
		pc_out <= pc;
	end
end

endmodule
