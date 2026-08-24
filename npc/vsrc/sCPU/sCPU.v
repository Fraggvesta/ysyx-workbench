
module sCPU (
	input clk,
	input rst,
	output[7:0] pc_out,
	output[7:0] alu_out,
	output[7:0] inst_out
);

	wire [7:0] instruction;
	wire [1:0] rd, rs1, rs2;
	wire [3:0] imm, addr;
	wire we, use_imm, branch;
	wire [7:0] rs1d, rs2d;
	wire [7:0] alu_src1, alu_src2;
	wire [7:0] alu_result;
	wire not_equals;
	wire take_branch;

	assign alu_src1 = use_imm ? 8'h00 : rs1d;
	assign alu_src2 = use_imm ? {4'b0, imm} : rs2d;
	assign take_branch = branch && not_equals;
	assign alu_out = alu_result;
	assign inst_out = instruction;
	assign pc_out = obj_rom.pc;

	rom obj_rom(clk, take_branch, rst, {4'b0, addr}, instruction);
	id obj_id(instruction, rd, rs1, rs2, imm, addr, we, use_imm, branch);
	regf obj_regf(rd, we, clk, rst, alu_result, rs1, rs2, rs1d, rs2d);
	alu obj_alu(alu_src1, alu_src2, alu_result, not_equals);

endmodule
