`timescale 1ns/1ps
module iverilog_top;
reg clock = 0;
reg reset = 1;
integer cycles = 0;
always #1 clock = ~clock;
sim_top top(.clock(clock), .reset(reset));
initial begin
  $load_program;
  if ($test$plusargs("dump")) begin
    $dumpfile("sim.vcd");
    $dumpvars(0, iverilog_top);
  end
  repeat (10) @(posedge clock);
  reset = 0;
end
always @(posedge clock) begin
  if (!reset) begin
    cycles = cycles + 1;
    if (top.cpu.ebreak) begin
      if (top.cpu.a0 == 0) $display("HIT GOOD TRAP");
      else $display("HIT BAD TRAP (code = %0d)", top.cpu.a0);
      $display("cycles = %0d", cycles);
      $finish;
    end
    if (cycles == 100000000) begin
      $display("TIMEOUT");
      $finish;
    end
  end
end
endmodule