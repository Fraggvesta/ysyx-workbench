module mem(
  input clk,
  input rst,
  input ifu_reqValid,
  input [31:0]ifu_addr,
  output reg ifu_respValid,
  output reg [31:0]ifu_rdata,
  input lsu_reqValid,
  input [31:0]lsu_addr,
  input lsu_wen,
  input [31:0]lsu_wdata,
  input [3:0]lsu_wmask,
  output reg lsu_respValid,
  output reg [31:0]lsu_rdata
);

  import "DPI-C" function int  pmem_read(input int addr);
  import "DPI-C" function void pmem_write(input int addr, input int data, input byte mask);

  always @(posedge clk) begin
    if (rst) begin
      ifu_respValid <= 1'b0;
      lsu_respValid <= 1'b0;
    end else begin
      ifu_rdata <= ifu_reqValid ? pmem_read(ifu_addr) : 32'b0;
      ifu_respValid <= ifu_reqValid;

      lsu_rdata <= (lsu_reqValid && !lsu_wen) ? pmem_read(lsu_addr) : 32'b0;
      if (lsu_reqValid && lsu_wen)
        pmem_write(lsu_addr, lsu_wdata, {4'b0, lsu_wmask});
      lsu_respValid <= lsu_reqValid;
    end
  end

endmodule