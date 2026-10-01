module sim_top(
input clock,
input reset
);

wire ifu_reqValid, ifu_respValid;
wire [31:0] ifu_addr, ifu_rdata;
wire lsu_reqValid, lsu_respValid, lsu_wen;
wire [31:0] lsu_addr, lsu_wdata, lsu_rdata;
wire [3:0] lsu_wmask;
/* verilator lint_off UNUSEDSIGNAL */
wire[1:0] lsu_size;
/* verilator lint_on UNUSEDSIGNAL */

ysyx_20237522 cpu (
    .clock(clock), .reset(reset),
    .io_ifu_reqValid(ifu_reqValid),
    .io_ifu_addr(ifu_addr),
    .io_ifu_respValid(ifu_respValid), 
    .io_ifu_rdata(ifu_rdata),
    .io_lsu_reqValid(lsu_reqValid),
    .io_lsu_addr(lsu_addr),
    .io_lsu_wen(lsu_wen),
    .io_lsu_wdata(lsu_wdata),
    .io_lsu_wmask(lsu_wmask),
    .io_lsu_respValid(lsu_respValid),
    .io_lsu_rdata(lsu_rdata),   
    .io_lsu_size(lsu_size)
);

mem pmem (
    .clk(clock), .rst(reset),
    .ifu_reqValid(ifu_reqValid),
    .ifu_addr(ifu_addr),
    .ifu_respValid(ifu_respValid),
    .ifu_rdata(ifu_rdata),
    .lsu_reqValid(lsu_reqValid),
    .lsu_addr(lsu_addr),
    .lsu_wen(lsu_wen),
    .lsu_wdata(lsu_wdata),
    .lsu_wmask(lsu_wmask),
    .lsu_respValid(lsu_respValid),
    .lsu_rdata(lsu_rdata)
);
endmodule