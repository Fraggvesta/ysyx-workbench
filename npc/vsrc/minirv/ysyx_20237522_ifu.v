module ysyx_20237522_ifu(
input clk,
input rst,
input we_mem,
input re_mem,
input[31:0] next_pc,
input ifu_respValid,
input[31:0] ifu_rdata,
input lsu_respValid,

output ifu_reqValid,
output[31:0] ifu_addr,
output reg [31:0] curr_pc,
output reg is_valid,
output reg mem_req,
output reg [31:0] instr
);

localparam IDLE = 2'b00, WAIT = 2'b01, WAIT_L = 2'b10;
reg[1:0] state;
assign ifu_addr = curr_pc;
assign ifu_reqValid = state == IDLE;

reg[31:0] instr_reg;
wire mem_op = re_mem ||	we_mem;

always @(posedge clk) begin
	if(rst) begin
		state <= IDLE;
		`ifdef SOC
			curr_pc <= 32'h30000000;
		`else
			curr_pc <= 32'h80000000;
		`endif
		instr_reg <= 32'b0;
	end else begin
	if(is_valid) curr_pc <= next_pc;
	case(state)
	IDLE:	state <= WAIT;
	WAIT:	begin
		if(ifu_respValid) begin
			instr_reg <= ifu_rdata;
			state <= mem_op ? WAIT_L : IDLE;
		end
	end
	WAIT_L: state <= lsu_respValid ? IDLE : WAIT_L;
	default: state <= IDLE;
	endcase	
	end
end


always @(*) begin
	instr = 32'b0;
	is_valid = 1'b0;
	mem_req = 1'b0;

	case(state)
	IDLE: ;
	WAIT: begin
	 	instr = ifu_respValid ? ifu_rdata : 32'b0;
		is_valid = ~mem_op && ifu_respValid;
		mem_req = ifu_respValid;
		end
	WAIT_L: begin
		instr = instr_reg;
		is_valid = lsu_respValid;
		mem_req = 1'b0;
	end
	default: ;
	endcase
end

endmodule
