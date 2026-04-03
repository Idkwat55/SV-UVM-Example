`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// TC3: Class-based test with virtual interface.
// New concepts:
// 1) transaction class
// 2) driver class
// 3) monitor + scoreboard classes
// 4) virtual interface for connecting classes to DUT pins
// Benefit: moves verification logic from module-level code to reusable OO code.
// -----------------------------------------------------------------------------

import alu_common_pkg::*;

class alu_txn;
    rand logic [15:0] a;
    rand logic [15:0] b;
    rand alu_op_e     op;

    function string sprint();
        return $sformatf("a=%h b=%h op=%0d", a, b, op);
    endfunction
endclass

class alu_driver;
    virtual alu_if.tb_mp vif;

    function new(virtual alu_if.tb_mp vif);
        this.vif = vif;
    endfunction

    task drive(alu_txn t);
        vif.drive(t.a, t.b, t.op);
        #1;
    endtask
endclass

class alu_monitor;
    virtual alu_if.tb_mp vif;

    function new(virtual alu_if.tb_mp vif);
        this.vif = vif;
    endfunction

    task sample(output alu_result_s r);
        vif.sample(r.y, r.carry, r.zero, r.overflow);
    endtask
endclass

class alu_scoreboard;
    int total;
    int errors;

    task check(alu_txn t, alu_result_s got);
        alu_result_s exp;
        exp = alu_predict(t.a, t.b, t.op);
        total++;

        if (got !== exp) begin
            errors++;
            $error("SB mismatch: %s exp(y,c,z,o)=%h,%0b,%0b,%0b got=%h,%0b,%0b,%0b",
                   t.sprint(), exp.y, exp.carry, exp.zero, exp.overflow,
                   got.y, got.carry, got.zero, got.overflow);
        end
    endtask

    task report();
        $display("TC3 scoreboard summary: total=%0d errors=%0d", total, errors);
    endtask
endclass

module tb_tc3;
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

    alu_driver     drv;
    alu_monitor    mon;
    alu_scoreboard sb;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        alu_txn      t;
        alu_result_s got;
        int          i;

        $dumpfile("tc3.vcd");
        $dumpvars(0, tb_tc3);

        // virtual interface is passed to classes.
        drv = new(alu_bus);
        mon = new(alu_bus);
        sb  = new();

        for (i = 0; i < 20; i++) begin
            t = new();
            if (!t.randomize()) begin
                $fatal(1, "Randomization failed in TC3");
            end

            drv.drive(t);
            mon.sample(got);
            sb.check(t, got);
        end

        sb.report();
        if (sb.errors != 0) begin
            $fatal(1, "TC3 FAILED");
        end

        $display("TC3 PASSED");
        $finish;
    end
endmodule
