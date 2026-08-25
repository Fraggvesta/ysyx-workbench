module idu(
input[31:0] instr,
output reg [31:0] imm,
output reg [4:0] rs1_out,
output reg [4:0] rs2_out,
output reg [4:0] rd_out,
output reg we_reg,
output reg we_mem,
output reg pc_sel,
output reg alu_sel,
output reg [1:0] data_sel
);

wire [6:0] opcode = instr[6:0];
wire[4:0] rd = instr[11:7], rs1 = instr[19:15], rs2 = instr[24:20];
wire[2:0] func = instr[14:12];
wire[11:0] imm_i = instr[31:20];
wire[11:0] imm_s = {instr[31:25], instr[11:7]};
wire[19:0] imm_u = instr[31:12];
wire is_addi = (opcode == 7'd19) && (func == 3'd0);
wire is_jalr = (opcode == 7'd103) && (func == 3'd0);
always @(*) begin
	rs1_out = 5'd0;
	rs2_out = 5'd0;
	rd_out = 5'd0;
	imm = 32'd0;
	alu_sel = 1'b0;
	we_reg = 1'b0;
	we_mem = 1'b0;
	data_sel = 2'b00;
	pc_sel = 1'b0;
	if(is_addi) begin
		rd_out = rd;
		rs1_out = rs1;
		imm = {{20{imm_i[11]}}, imm_i};
		alu_sel = 1'b1;
		we_reg = 1'b1;
	end else if(is_jalr) begin
		rd_out = rd;
		rs1_out = rs1;
		alu_sel = 1'b1;
		imm = {{20{imm_i[11]}}, imm_i};
		we_reg = 1'b1;
		pc_sel = 1'b1;
		data_sel = 2'b10;
	end
end

endmodule
