module minirv (
    input clk,
    input rst,
    output [31:0] pc,
		output [31:0] ra,
		output [31:0] a0
);

		wire [31:0] current_pc, next_pc, imm, rs1_data, rs2_data, alu_result, wb_data, data_mem, instr;
    wire [4:0] rs1, rs2, rd;
    wire we_reg, we_mem, re_mem, pc_sel, alu_sel, is_ebreak, store_size;
		wire[1:0] data_sel;
		wire[2:0] funct;
    reg [31:0] rf [31:0];

    assign pc = current_pc;
    assign rs1_data = (rs1 == 5'd0) ? 32'd0 : rf[rs1];
    assign rs2_data = (rs2 == 5'd0) ? 32'd0 : rf[rs2];
		import "DPI-C" function void terminate();
		
	  always @(posedge clk) begin
			if(rst) begin
				for(int i = 0; i < 32; i++) begin
					rf[i] <= 32'd0;
				end
			end else begin
				 	if (we_reg && (rd != 5'd0)) rf[rd] <= wb_data;
					
					if(is_ebreak) begin
					terminate();
				end
			end
		end


    
	
		ifu obj_ifu (clk, rst, next_pc, current_pc, instr);
    idu obj_idu (instr, imm, rs1, rs2, rd, funct, we_reg, we_mem, re_mem, pc_sel, alu_sel, data_sel, store_size, is_ebreak);
    exu obj_exu (rs1_data, rs2_data, imm, alu_sel, alu_result);
    wbu obj_wbu (current_pc, alu_result, data_mem, data_sel, pc_sel, next_pc, wb_data);
		lsu obj_lsu (clk, we_mem, re_mem, alu_result, rs2_data, store_size, funct, data_mem);	
		assign ra = rf[1];
		assign a0 = rf[10];
endmodule
