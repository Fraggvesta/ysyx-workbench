module lsu(
input we_mem,
input[31:0] addr,
input[31:0] data_write,
input store_size,
input[2:0] funct,
output reg [31:0] data_mem
);
wire[1:0] offset = addr[1:0];
wire[7:0] wmask;
reg[7:0] data_byte;
wire[31:0] data;
import "DPI-C" function int pmem_read(input int raddr);
import "DPI-C" function void pmem_write(input int waddr, input int data, input byte mask);

assign wmask = store_size ? (8'h01 << offset) : 8'h0f;
assign data = pmem_read(addr);

always @(*) begin
	if(we_mem) begin 
	pmem_write(addr, data_write, wmask );
	end
	
	case(offset)
	2'b00: data_byte = data[7:0]; 
	2'b01: data_byte = data[15:8];
	2'b10: data_byte = data[23:16];
	2'b11: data_byte = data[31:24];
	endcase

	case(funct)
	3'b010: data_mem = data;
	3'b100:	data_mem = {{24{1'b0}}, data_byte};
	default: data_mem = 32'b0;
	
	endcase
end

endmodule
