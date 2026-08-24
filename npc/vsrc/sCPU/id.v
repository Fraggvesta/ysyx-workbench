module id (
    input  [7:0] inst,
    output reg [1:0] rd,
    output reg [1:0] rs1,
    output reg [1:0] rs2,
    output reg [3:0] imm,
    output reg [3:0] addr,
    output reg we,
    output reg use_imm,
    output reg branch
);

    wire [1:0] opcode = inst[7:6];

    always @(*) begin
        rd = 2'b00;
        rs1 = 2'b00;
        rs2 = 2'b00;
        imm = 4'b0000;
        addr = 4'b0000;
        we = 1'b0;
        use_imm = 1'b0;
        branch = 1'b0;

        case (opcode)
            2'b00: begin
                rd = inst[5:4];
                rs1 = inst[3:2];
                rs2 = inst[1:0];
                we = 1'b1;
            end

            2'b10: begin
                rd = inst[5:4];
                imm = inst[3:0];
                we = 1'b1;
                use_imm = 1'b1;
            end

            2'b11: begin
                addr = inst[5:2];
                rs2 = inst[1:0];
                rs1 = 2'b00;
                branch = 1'b1;
            end

            default: ;
        endcase
    end

endmodule
