interface alu_if(input logic clk);
    logic [15:0] a;
    logic [15:0] b;
    logic [2:0]  op;
    logic [15:0] y;
    logic        carry;
    logic        zero;
    logic        overflow;

    // Driver writes requests into DUT inputs.
    task automatic drive(input logic [15:0] a_i,
                         input logic [15:0] b_i,
                         input logic [2:0]  op_i);
        a  <= a_i;
        b  <= b_i;
        op <= op_i;
    endtask

    // Monitor samples DUT outputs in one place.
    task automatic sample(output logic [15:0] y_o,
                          output logic        carry_o,
                          output logic        zero_o,
                          output logic        overflow_o);
        y_o        = y;
        carry_o    = carry;
        zero_o     = zero;
        overflow_o = overflow;
    endtask

    modport dut_mp (
        input  a, b, op,
        output y, carry, zero, overflow
    );

    modport tb_mp (
        output a, b, op,
        input  y, carry, zero, overflow,
        import drive, sample
    );

endinterface
