module ysyx_20237522_csr(
    input clock,
    input reset,
    input[11:0] csr_address,
    input[31:0] csr_wdata,
    input we,
    output reg[31:0] csr_rdata
);
    reg [63:0] mcycle;

    always @(*) begin
        case(csr_address)
            12'hF11: csr_rdata = 32'h79737978;
            12'hF12: csr_rdata = 32'd20237522;
            12'hB00: csr_rdata = mcycle[31:0];
            12'hB80: csr_rdata = mcycle[63:32];
            default: csr_rdata = 32'd0;
        endcase
    end

    always @(posedge clock) begin
        if(reset) begin
            mcycle <= 64'd0;
        end else if(we && csr_address == 12'hB00) begin
            mcycle <= {mcycle[63:32], csr_wdata};
        end else if(we && csr_address == 12'hB80) begin
            mcycle <= {csr_wdata, mcycle[31:0]};
        end else begin
            mcycle <= mcycle + 64'd1;
        end
    end

endmodule
