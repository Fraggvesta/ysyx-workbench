module id(
input  [7:0] instr,
output [1:0] rd,
output [1:0] rs1,
output [1:0] rs2,
output [3:0] imm,
output [3:0 ]addr,
output reg we,
output reg use_imm,
output reg branch
);
	assign rd  = instr[5:4];
	assign rs1 = instr[3:2];
  assign rs2 = instr[1:0];
  assign imm = instr[3:0];
	assign addr = instr[5:2];

  always @(*) begin
      we = 1'b0;
      use_imm = 1'b0;
      branch = 1'b0;

      case (instr[7:6]) 
          2'b00: begin
              we = 1'b1;
          end
          2'b01: begin
              we = 1'b1;
              use_imm = 1'b1;
          end
          2'b10: begin
              branch = 1'b1;
          end
          default: ;
      endcase
		end
	endmodule
