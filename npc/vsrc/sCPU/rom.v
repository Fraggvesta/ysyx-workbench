module rom(	
	input clk,
	input sel,
	input rst,
	input[7:0] address,
	output reg[7:0] instruction
);

reg[7:0] pc;

always @(*) begin
	case(pc)
		8'd0: instruction = 8'h8a;
		8'd1:	instruction = 8'h90;
		8'd2: instruction =	8'ha0;
		8'd3: instruction = 8'hb1;
		8'd4: instruction = 8'h17;
		8'd5: instruction = 8'h29;
		8'd6: instruction = 8'hd1;
		8'd7: instruction = 8'hdf;
		default: instruction = 8'h00;
	endcase
end

always @(posedge clk) begin
	if(rst) begin
		pc <= 0;
	end else if(sel) begin
		pc <= address;
	end else begin
		pc <= pc + 1'b1;
	end
end
endmodule
