`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// TC4: Integrated constrained-random, coverage-driven, reusable environment.
// New concepts:
// 1) constraints to shape traffic
// 2) coverage for closure visibility
// 3) small reusable environment class (gen/drive/check/report)
// 4) automated pass/fail with self-checking scoreboard
// This is still lightweight (not full UVM), but UVM-like in structure.
// -----------------------------------------------------------------------------

import alu_common_pkg::*;

class alu_txn_c;
    rand logic [15:0] a;
    rand logic [15:0] b;
    rand alu_op_e     op;

    // Keep data biased toward corner cases while still random.
    constraint c_op_dist {
        op dist {
            ALU_ADD    := 2,
            ALU_SUB    := 2,
            ALU_AND_OP := 1,
            ALU_OR_OP  := 1,
            ALU_XOR_OP := 1,
            ALU_SLL    := 1,
            ALU_SRL    := 1,
            ALU_PASS_A := 1
        };
    }

    // Limit shift amount in shift operations to keep debug readable.
    constraint c_shift {
        if (op inside {ALU_SLL, ALU_SRL}) b[15:4] == 12'h000;
    }

    // Encourage boundary values on ADD/SUB to trigger overflow/carry cases.
    constraint c_arith_corners {
        if (op inside {ALU_ADD, ALU_SUB}) {
            a dist {16'h0000 := 2, 16'h0001 := 2, 16'h7FFF := 2, 16'h8000 := 2, 16'hFFFF := 2, [16'h0002:16'hFFFE] := 1};
            b dist {16'h0000 := 2, 16'h0001 := 2, 16'h7FFF := 2, 16'h8000 := 2, 16'hFFFF := 2, [16'h0002:16'hFFFE] := 1};
        }
    }

    function string sprint();
        return $sformatf("a=%h b=%h op=%0d", a, b, op);
    endfunction
endclass

class alu_env;
    virtual alu_if.tb_mp vif;
    int num_tests;
    int total;
    int errors;

    covergroup cg_alu;
        option.per_instance = 1;

        cp_op: coverpoint vif.op {
            bins all_ops[] = {[0:7]};
        }

        cp_zero: coverpoint vif.zero {
            bins z0 = {0};
            bins z1 = {1};
        }

        cp_carry: coverpoint vif.carry {
            bins c0 = {0};
            bins c1 = {1};
        }

        cp_overflow: coverpoint vif.overflow {
            bins o0 = {0};
            bins o1 = {1};
        }

        // Shows interactions between operation type and result flags.
        x_op_flags: cross cp_op, cp_zero, cp_carry, cp_overflow;
    endgroup

    function new(virtual alu_if.tb_mp vif, int num_tests = 200);
        this.vif      = vif;
        this.num_tests = num_tests;
        this.total    = 0;
        this.errors   = 0;
        cg_alu = new();
    endfunction

    task run();
        alu_txn_c    t;
        alu_result_s exp;
        alu_result_s got;
        int          i;

        for (i = 0; i < num_tests; i++) begin
            t = new();
            if (!t.randomize()) begin
                $fatal(1, "Randomization failed at iter=%0d", i);
            end

            // Drive inputs through interface abstraction.
            vif.drive(t.a, t.b, t.op);
            #1;

            // Sample outputs through interface API.
            vif.sample(got.y, got.carry, got.zero, got.overflow);
            cg_alu.sample();

            // Scoreboard check against reference model.
            exp = alu_predict(t.a, t.b, t.op);
            total++;
            if (got !== exp) begin
                errors++;
                $error("TC4 mismatch iter=%0d %s exp(y,c,z,o)=%h,%0b,%0b,%0b got=%h,%0b,%0b,%0b",
                       i, t.sprint(), exp.y, exp.carry, exp.zero, exp.overflow,
                       got.y, got.carry, got.zero, got.overflow);
            end
        end
    endtask

    task report();
        real cov;
        cov = cg_alu.get_inst_coverage();

        $display("TC4 summary: total=%0d errors=%0d coverage=%0.2f%%", total, errors, cov);
        if (errors != 0) begin
            $fatal(1, "TC4 FAILED with %0d mismatches", errors);
        end

        if (cov < 90.0) begin
            $warning("Coverage below target: %0.2f%%", cov);
        end

        $display("TC4 PASSED");
    endtask
endclass

module tb_tc4;
    logic clk;
    alu_if alu_bus(clk);
    alu_env env;

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

    initial begin
        $dumpfile("tc4.vcd");
        $dumpvars(0, tb_tc4);

        env = new(alu_bus, 400);
        env.run();
        env.report();

        $finish;
    end
endmodule
