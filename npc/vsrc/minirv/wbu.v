module wbu(
input [31:0] pc,
input [31:0] data_alu,
input [31:0] data_imm,
input[1:0] data_sel,
input pc_sel,
output reg [31:0] pc_out,
output reg [31:0] data_out
);

always @(*) begin

	if(pc_sel) pc_out = {data_alu[31:1], 1'b0};	
	else pc_out = pc + 4;

	case(data_sel)
		2'b00: data_out = data_alu;
		2'b01: data_out = data_imm;
		2'b10: data_out = pc + 4;
		default: data_out = 32'd0;
	endcase
end


endmodule
