module idu(
input[31:0] instr,
output reg [31:0] imm,
output reg [4:0] rs1_out,
output reg [4:0] rs2_out,
output reg [4:0] rd_out,
output reg [2:0] funct,
output reg we_reg,
output reg we_mem,
output reg re_mem,
output reg pc_sel,
output reg alu_sel,
output reg[1:0] data_sel,
output reg store_size,
output is_ebreak
);

wire [6:0] opcode = instr[6:0];
wire[4:0] rd = instr[11:7], rs1 = instr[19:15], rs2 = instr[24:20];
assign funct = instr[14:12];
wire[11:0] imm_i = instr[31:20];
wire[11:0] imm_s = {instr[31:25], instr[11:7]};
wire[19:0] imm_u = instr[31:12];
wire is_addi = (opcode == 7'd19) && (funct == 3'd0);
wire is_jalr = (opcode == 7'd103) && (funct == 3'd0);
wire is_add = (opcode == 7'd51) && (funct == 3'd0);
wire is_lui = (opcode == 7'd55);
wire is_lw = (opcode == 7'd3) && (funct == 3'd2);
wire is_lbu = (opcode == 7'd3) && (funct == 3'd4);
wire is_sw = (opcode == 7'd35) && (funct == 3'd2);
wire is_sb = (opcode == 7'd35) && (funct == 3'd0);
assign is_ebreak = (instr == 32'h00100073);

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
	store_size = 1'b0;
	re_mem = 1'b0;
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
		data_sel = 2'b01;
	end else if(is_add) begin
		rd_out = rd;
		rs1_out = rs1;
		rs2_out = rs2;
		we_reg = 1'b1;
	end else if(is_lui) begin
		rd_out = rd;
		imm = {imm_u, 12'b0};
		alu_sel = 1'b1;
		we_reg = 1'b1;
	end else if(is_lw || is_lbu) begin
		rd_out = rd;
		rs1_out = rs1;
		imm = {{20{imm_i[11]}}, imm_i};
		alu_sel = 1'b1;
		we_reg = 1'b1;
		data_sel = 2'b10;
		re_mem = 1'b1;
	end else if(is_sw || is_sb) begin
		rs1_out = rs1;
		rs2_out = rs2;
		imm = {{20{imm_s[11]}}, imm_s};
		alu_sel = 1'b1;
		we_mem = 1'b1;
		store_size = is_sb ? 1'b1 : 1'b0;
	end
end

endmodule
