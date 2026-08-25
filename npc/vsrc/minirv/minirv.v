module minirv (
    input clk,
    input rst,
    input [31:0] inst,
    output [31:0] pc,
		output [31:0] ra,
		output [31:0] a0
);

    wire [31:0] current_pc, next_pc, imm, rs1_data, rs2_data, alu_result, wb_data;
    wire [4:0] rs1, rs2, rd;
    wire we_reg, we_mem, pc_sel, alu_sel;
		wire data_sel;
    reg [31:0] rf [31:0];

    assign pc = current_pc;
    assign rs1_data = (rs1 == 5'd0) ? 32'd0 : rf[rs1];
    assign rs2_data = (rs2 == 5'd0) ? 32'd0 : rf[rs2];

    always @(posedge clk) begin
        if (we_reg && (rd != 5'd0)) rf[rd] <= wb_data;
    end

    ifu obj_ifu (clk, rst, next_pc, current_pc);
    idu obj_idu (inst, imm, rs1, rs2, rd, we_reg, we_mem, pc_sel, alu_sel, data_sel);
    exu obj_exu (rs1_data, rs2_data, imm, alu_sel, alu_result);
    wbu obj_wbu (current_pc, alu_result, data_sel, pc_sel, next_pc, wb_data);

		assign ra = rf[1];
		assign a0 = rf[10];
endmodule
