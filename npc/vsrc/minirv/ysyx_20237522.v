module ysyx_20237522 (
    input clock,
    input reset,
		input io_ifu_respValid,
		input[31:0] io_ifu_rdata,
		input io_lsu_respValid,
		input[31:0] io_lsu_rdata,
		
		output[1:0] io_lsu_size,
		output io_ifu_reqValid,
		output[31:0] io_ifu_addr,
		output io_lsu_reqValid,
		output[31:0] io_lsu_addr,
		output io_lsu_wen,
		output[31:0] io_lsu_wdata,
		output[3:0] io_lsu_wmask
	);

		wire [31:0] current_pc, next_pc, imm, rs1_data, rs2_data,
 alu_result, wb_data, data_mem, instr, csr_rdata, csr_wdata;
    wire [4:0] rs1, rs2, rd;
    wire we_reg, we_mem, re_mem, pc_sel, alu_sel, is_ebreak, mem_req, csr_we, csr_we_valid;
	wire[1:0] data_sel;
	wire[2:0] funct;
    wire[11:0] csr_address;
    reg [31:0] rf [31:0] /* verilator public_flat_rd */;
    

		wire [31:0] pc /* verilator public_flat_rd */;
		wire [31:0] ra /* verilator public_flat_rd */;
		wire [31:0] a0 /* verilator public_flat_rd */;
		wire ebreak /* verilator public_flat_rd */;
		wire is_valid /* verilator public_flat_rd */;


    assign rs1_data = (rs1 == 5'd0) ? 32'd0 : rf[rs1];
    assign rs2_data = (rs2 == 5'd0) ? 32'd0 : rf[rs2];

	  always @(posedge clock) begin
			if(reset) begin
				for(int i = 0; i < 32; i++) begin
					rf[i] <= 32'd0;
				end
			end else begin
				 	if (we_reg && is_valid  && (rd != 5'd0)) rf[rd] <= wb_data;
				end
		end

		ysyx_20237522_ifu obj_ifu (
        .clk(clock), .rst(reset),
        .re_mem(re_mem), .we_mem(we_mem),
        .next_pc(next_pc),
        .ifu_reqValid(io_ifu_reqValid), .ifu_addr(io_ifu_addr),
        .ifu_respValid(io_ifu_respValid), .ifu_rdata(io_ifu_rdata),
        .mem_req(mem_req), .lsu_respValid(io_lsu_respValid),
        .curr_pc(current_pc), .is_valid(is_valid), .instr(instr)
    );

 
    ysyx_20237522_idu obj_idu (
        .instr(instr),
        .imm(imm), .rs1_out(rs1), .rs2_out(rs2), .rd_out(rd), .funct(funct),
        .we_reg(we_reg), .we_mem(we_mem), .re_mem(re_mem),
        .pc_sel(pc_sel), .alu_sel(alu_sel), .data_sel(data_sel),
         .is_ebreak(is_ebreak), .csr_address(csr_address), .csr_we(csr_we)
    );
 
    ysyx_20237522_exu obj_exu (
        .src1(rs1_data), .src2(rs2_data), .imm(imm),
        .alu_sel(alu_sel), .result(alu_result)
    );
 
		ysyx_20237522_lsu obj_lsu (
        .we_mem(we_mem), .re_mem(re_mem), .mem_req(mem_req),
        .addr(alu_result), .data_write(rs2_data),
        .funct(funct), .lsu_size(io_lsu_size),
        .lsu_reqValid(io_lsu_reqValid), .lsu_addr(io_lsu_addr),
        .lsu_wen(io_lsu_wen), .lsu_wdata(io_lsu_wdata), .lsu_wmask(io_lsu_wmask),
        .lsu_rdata(io_lsu_rdata),
        .data_mem(data_mem)
    );
 
    ysyx_20237522_wbu obj_wbu (
        .pc(current_pc), .data_alu(alu_result), .data_mem(data_mem),
        .data_sel(data_sel), .pc_sel(pc_sel),
        .pc_out(next_pc), .data_out(wb_data),
        .data_csr(csr_rdata)
    );
	
    assign csr_we_valid = csr_we && is_valid;
    assign csr_wdata = csr_rdata | rs1_data;
    ysyx_20237522_csr obj_csr (
        .clock(clock), .reset(reset), .csr_address(csr_address),
        .csr_rdata(csr_rdata), .we(csr_we_valid),
        .csr_wdata(csr_wdata)
    );  
	
		assign ra = rf[1];
		assign a0 = rf[10];
		assign ebreak = is_ebreak && is_valid;		
endmodule
