module minirv (
    input clk,
    input rst,
		input[31:0] imem_data,
		input[31:0] dmem_rdata,
		
		output[31:0] imem_addr,
		output[31:0] dmem_addr,
		output[31:0] dmem_wdata,
		output[3:0] dmem_wmask,
		output dmem_we,
		output dmem_re,

		output [31:0] pc,
		output [31:0] ra,
		output [31:0] a0,
		output ebreak,
		output is_valid
	);

		wire [31:0] current_pc, next_pc, imm, rs1_data, rs2_data,
 alu_result, wb_data, data_mem, instr;
    wire [4:0] rs1, rs2, rd;
    wire we_reg, we_mem, re_mem, pc_sel, alu_sel, is_ebreak, store_size, mem_req;
		wire[1:0] data_sel;
		wire[2:0] funct;
    reg [31:0] rf [31:0] /* verilator public_flat_rd */;

    assign pc = current_pc;
    assign rs1_data = (rs1 == 5'd0) ? 32'd0 : rf[rs1];
    assign rs2_data = (rs2 == 5'd0) ? 32'd0 : rf[rs2];

	  always @(posedge clk) begin
			if(rst) begin
				for(int i = 0; i < 32; i++) begin
					rf[i] <= 32'd0;
				end
			end else begin
				 	if (we_reg && is_valid  && (rd != 5'd0)) rf[rd] <= wb_data;
				end
		end

		ifu obj_ifu (
        .clk(clk), .rst(rst),
        .next_pc(next_pc), .imem_data(imem_data),
        .curr_pc(current_pc), .is_valid(is_valid),
        .imem_addr(imem_addr), .instr(instr), .re_mem(re_mem), .mem_req(mem_req)
    );
 
    idu obj_idu (
        .instr(instr),
        .imm(imm), .rs1_out(rs1), .rs2_out(rs2), .rd_out(rd), .funct(funct),
        .we_reg(we_reg), .we_mem(we_mem), .re_mem(re_mem),
        .pc_sel(pc_sel), .alu_sel(alu_sel), .data_sel(data_sel),
        .store_size(store_size), .is_ebreak(is_ebreak)
    );
 
    exu obj_exu (
        .src1(rs1_data), .src2(rs2_data), .imm(imm),
        .alu_sel(alu_sel), .result(alu_result)
    );
 
    lsu obj_lsu (
        .we_mem(we_mem), .re_mem(re_mem), .mem_req(mem_req),
        .addr(alu_result), .data_write(rs2_data),
        .store_size(store_size), .funct(funct), .dmem_rdata(dmem_rdata),
        .dmem_addr(dmem_addr), .dmem_wdata(dmem_wdata),
        .dmem_wmask(dmem_wmask), .dmem_we(dmem_we), .dmem_re(dmem_re),
        .data_mem(data_mem)
    );
 
    wbu obj_wbu (
        .pc(current_pc), .data_alu(alu_result), .data_mem(data_mem),
        .data_sel(data_sel), .pc_sel(pc_sel),
        .pc_out(next_pc), .data_out(wb_data)
    );
	

	
		assign ra = rf[1];
		assign a0 = rf[10];
		assign ebreak = is_ebreak && is_valid;		
endmodule
