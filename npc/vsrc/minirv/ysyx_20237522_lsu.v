module ysyx_20237522_lsu(
input we_mem,
input re_mem,
input mem_req,
input[31:0] addr,
input[31:0] data_write,
input[2:0] funct,
input[31:0] lsu_rdata,

output[1:0] lsu_size,
output lsu_reqValid,
output[31:0] lsu_addr,
output lsu_wen,
output[31:0] lsu_wdata,
output[3:0] lsu_wmask,
output reg [31:0] data_mem
);

wire[1:0] offset = addr[1:0];
reg[7:0] data_byte;
assign lsu_size = funct[1:0];
assign lsu_reqValid = mem_req && (we_mem || re_mem);
assign lsu_addr = addr;
assign lsu_wen = we_mem;
assign lsu_wmask = (lsu_size ==	2'b00) ? (4'h1 << offset) : 4'hf;
assign lsu_wdata = (lsu_size == 2'b00) ? {4{data_write[7:0]}} : data_write;

always @(*) begin
	
	case(offset)
	2'b00: data_byte = lsu_rdata[7:0]; 
	2'b01: data_byte = lsu_rdata[15:8];
	2'b10: data_byte = lsu_rdata[23:16];
	2'b11: data_byte = lsu_rdata[31:24];
	endcase

	case(funct)
		3'b010: begin
		 	data_mem = lsu_rdata;
		end
		3'b100: begin
			data_mem = {{24{1'b0}}, data_byte};
		end

		default: data_mem = 32'b0;
	
	endcase
end

endmodule

