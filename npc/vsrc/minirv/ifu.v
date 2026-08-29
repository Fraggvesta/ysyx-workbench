module ifu(
input clk,
input rst,
input re_mem,
input[31:0] next_pc,
input[31:0] imem_data,
output reg [31:0] curr_pc,
output reg is_valid,
output reg mem_req,
output [31:0] imem_addr,
output reg [31:0] instr
);

localparam IDLE = 2'b00, WAIT = 2'b01, WAIT_L = 2'b10;
reg[1:0] state;
assign imem_addr = curr_pc;

always @(posedge clk) begin
	if(rst) begin
		state <= IDLE;
		curr_pc <= 32'h80000000;
	end else begin
	if(is_valid) curr_pc <= next_pc;
	case(state)
	IDLE:	state <= WAIT;
	WAIT:	state <= re_mem ? WAIT_L : IDLE;
	WAIT_L:	state <= IDLE;
	default: state <= IDLE;
	endcase	
	end
end


always @(*) begin
	case(state)
	IDLE: begin
		instr = 32'b0;
		is_valid = 1'b0;
		mem_req = 1'b0;
	end
	WAIT: begin
	 	instr = imem_data;
		is_valid = ~(re_mem);
		mem_req = 1'b1;
		end
	WAIT_L: begin
		instr = imem_data;
		is_valid = 1'b1;
		mem_req = 1'b0;
	end
	default: begin
		instr = 32'b0;
		is_valid = 1'b0;
		mem_req = 1'b0;
	end
	endcase
end

endmodule
