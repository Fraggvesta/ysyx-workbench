module lsu(
input we_mem,
input re_mem,
input mem_req,
input[31:0] addr,
input[31:0] data_write,
input store_size,
input[2:0] funct,
input[31:0] dmem_rdata,

output [31:0] dmem_addr,
output[31:0] dmem_wdata,
output[3:0] dmem_wmask,
output dmem_we,
output dmem_re,
output reg [31:0] data_mem
);

wire[1:0] offset = addr[1:0];
reg[7:0] data_byte;

assign dmem_addr = addr;
assign dmem_we = mem_req && we_mem;
assign dmem_re = mem_req && re_mem;
assign dmem_wmask = store_size ? (4'h1 << offset) : 4'hf;
assign dmem_wdata = store_size ? {4{data_write[7:0]}} : data_write;

always @(*) begin
	
	case(offset)
	2'b00: data_byte = dmem_rdata[7:0]; 
	2'b01: data_byte = dmem_rdata[15:8];
	2'b10: data_byte = dmem_rdata[23:16];
	2'b11: data_byte = dmem_rdata[31:24];
	endcase

	case(funct)
	3'b010: data_mem = dmem_rdata;
	3'b100:	data_mem = {{24{1'b0}}, data_byte};
	default: data_mem = 32'b0;
	
	endcase
end

endmodule

