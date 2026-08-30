module minirv (
    input clk,
    input rst,
		input ifu_respValid,
		input[31:0] ifu_rdata,
		input lsu_respValid,
		input[31:0] lsu_rdata,

		output ifu_reqValid,
		output[31:0] ifu_addr,
		output lsu_reqValid,
		output[31:0] lsu_addr,
		output lsu_wen,
		output[31:0] lsu_wdata,
		output[3:0] lsu_wmask,

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
        .re_mem(re_mem), .we_mem(we_mem),
        .next_pc(next_pc),
        .ifu_reqValid(ifu_reqValid), .ifu_addr(ifu_addr),
        .ifu_respValid(ifu_respValid), .ifu_rdata(ifu_rdata),
        .mem_req(mem_req), .lsu_respValid(lsu_respValid),
        .curr_pc(current_pc), .is_valid(is_valid), .instr(instr)
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
        .store_size(store_size), .funct(funct),
        .lsu_reqValid(lsu_reqValid), .lsu_addr(lsu_addr),
        .lsu_wen(lsu_wen), .lsu_wdata(lsu_wdata), .lsu_wmask(lsu_wmask),
        .lsu_rdata(lsu_rdata),
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
