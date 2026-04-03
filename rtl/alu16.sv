module alu16 (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic [2:0]  op,
    output logic [15:0] y,
    output logic        carry,
    output logic        zero,
    output logic        overflow
);

    logic [16:0] tmp;

    always_comb begin
        y        = 16'h0000;
        carry    = 1'b0;
        overflow = 1'b0;
        tmp      = 17'h0;

        unique case (op)
            3'b000: begin // ADD
                tmp      = {1'b0, a} + {1'b0, b};
                y        = tmp[15:0];
                carry    = tmp[16];
                overflow = (~(a[15] ^ b[15])) & (y[15] ^ a[15]);
            end

            3'b001: begin // SUB
                tmp      = {1'b0, a} - {1'b0, b};
                y        = tmp[15:0];
                carry    = tmp[16];
                overflow = (a[15] ^ b[15]) & (y[15] ^ a[15]);
            end

            3'b010: y = a & b;                 // AND
            3'b011: y = a | b;                 // OR
            3'b100: y = a ^ b;                 // XOR
            3'b101: y = a << b[3:0];           // SLL
            3'b110: y = a >> b[3:0];           // SRL
            3'b111: y = a;                     // PASS A
            default: y = 16'h0000;
        endcase

        zero = (y == 16'h0000);
    end

endmodule
