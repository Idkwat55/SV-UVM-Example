package alu_common_pkg;

    typedef enum logic [2:0] {
        ALU_ADD    = 3'b000,
        ALU_SUB    = 3'b001,
        ALU_AND_OP = 3'b010,
        ALU_OR_OP  = 3'b011,
        ALU_XOR_OP = 3'b100,
        ALU_SLL    = 3'b101,
        ALU_SRL    = 3'b110,
        ALU_PASS_A = 3'b111
    } alu_op_e;

    typedef struct packed {
        logic [15:0] y;
        logic        carry;
        logic        zero;
        logic        overflow;
    } alu_result_s;

    // Reference model reused by advanced testcases.
    function automatic alu_result_s alu_predict(
        input logic [15:0] a,
        input logic [15:0] b,
        input alu_op_e     op
    );
        alu_result_s r;
        logic [16:0] tmp;

        r.y        = 16'h0000;
        r.carry    = 1'b0;
        r.zero     = 1'b1;
        r.overflow = 1'b0;
        tmp        = 17'h0;

        unique case (op)
            ALU_ADD: begin
                tmp        = {1'b0, a} + {1'b0, b};
                r.y        = tmp[15:0];
                r.carry    = tmp[16];
                r.overflow = (~(a[15] ^ b[15])) & (r.y[15] ^ a[15]);
            end

            ALU_SUB: begin
                tmp        = {1'b0, a} - {1'b0, b};
                r.y        = tmp[15:0];
                r.carry    = tmp[16];
                r.overflow = (a[15] ^ b[15]) & (r.y[15] ^ a[15]);
            end

            ALU_AND_OP: r.y = a & b;
            ALU_OR_OP : r.y = a | b;
            ALU_XOR_OP: r.y = a ^ b;
            ALU_SLL   : r.y = a << b[3:0];
            ALU_SRL   : r.y = a >> b[3:0];
            ALU_PASS_A: r.y = a;
            default:    r.y = 16'h0000;
        endcase

        r.zero = (r.y == 16'h0000);
        return r;
    endfunction

endpackage
