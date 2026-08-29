module ifu(
input clk,
input rst,
input[31:0] next_pc,
input[31:0] imem_data,
output reg [31:0] curr_pc,
output reg is_valid,
output [31:0] imem_addr,
output reg [31:0] instr
);

localparam IDLE = 1'b0, WAIT = 1'b1;
reg state;
assign imem_addr = curr_pc;

always @(posedge clk) begin
	if(rst) begin
		state <= IDLE;
		curr_pc <= 32'h80000000;
	end else begin
		if (state == WAIT) curr_pc <= next_pc;
		state <= (state == IDLE) ? WAIT : IDLE;
	end
end


always @(*) begin
	case(state)
	IDLE: begin
		instr = 32'b0;
		is_valid = 1'b0;
	end
	WAIT: begin
	 	instr = imem_data;
		is_valid = 1'b1;
		end	
	endcase
end

endmodule
