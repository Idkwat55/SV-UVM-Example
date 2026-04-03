`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// TC2: Directed test with interface + basic self-checking.
// New concept: interface centralizes DUT pins and common tasks.
// Benefit: cleaner top-level testbench and reusable pin-level API.
// -----------------------------------------------------------------------------

import alu_common_pkg::*;

module tb_tc2;
    logic clk;
    alu_if alu_bus(clk);

    alu16 dut (
        .a(alu_bus.a),
        .b(alu_bus.b),
        .op(alu_bus.op),
        .y(alu_bus.y),
        .carry(alu_bus.carry),
        .zero(alu_bus.zero),
        .overflow(alu_bus.overflow)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic apply_and_check(
        input logic [15:0] a_i,
        input logic [15:0] b_i,
        input alu_op_e     op_i,
        input string       name
    );
        alu_result_s exp;
        logic [15:0] y_got;
        logic        carry_got;
        logic        zero_got;
        logic        overflow_got;

        exp = alu_predict(a_i, b_i, op_i);

        alu_bus.drive(a_i, b_i, op_i);
        #1;
        alu_bus.sample(y_got, carry_got, zero_got, overflow_got);

        if ({y_got, carry_got, zero_got, overflow_got}
            !== {exp.y, exp.carry, exp.zero, exp.overflow}) begin
            $error("[%s] MISMATCH a=%h b=%h op=%0d exp(y,c,z,o)=%h,%0b,%0b,%0b got=%h,%0b,%0b,%0b",
                   name, a_i, b_i, op_i, exp.y, exp.carry, exp.zero, exp.overflow,
                   y_got, carry_got, zero_got, overflow_got);
        end else begin
            $display("[%s] PASS a=%h b=%h op=%0d y=%h", name, a_i, b_i, op_i, y_got);
        end
    endtask

    initial begin
        $dumpfile("tc2.vcd");
        $dumpvars(0, tb_tc2);

        apply_and_check(16'd3,     16'd4,    ALU_ADD,    "add_3_4");
        apply_and_check(16'd10,    16'd3,    ALU_SUB,    "sub_10_3");
        apply_and_check(16'h00F0,  16'h0FF0, ALU_AND_OP, "and_case");
        apply_and_check(16'h00F0,  16'h0FF0, ALU_OR_OP,  "or_case");
        apply_and_check(16'hAAAA,  16'h00FF, ALU_XOR_OP, "xor_case");

        $display("TC2 complete.");
        $finish;
    end
endmodule
