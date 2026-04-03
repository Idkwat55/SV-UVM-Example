`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// TC1: Pure stimulus-only testbench.
// Goal: Show the most basic way to verify a DUT.
// Method: Apply hand-written vectors and inspect outputs in waveform.
// No interface, no class, no self-checking yet.
// -----------------------------------------------------------------------------
module tb_tc1;
    logic [15:0] a;
    logic [15:0] b;
    logic [2:0]  op;
    logic [15:0] y;
    logic        carry;
    logic        zero;
    logic        overflow;

    alu16 dut (
        .a(a),
        .b(b),
        .op(op),
        .y(y),
        .carry(carry),
        .zero(zero),
        .overflow(overflow)
    );

    initial begin
        $dumpfile("tc1.vcd");
        $dumpvars(0, tb_tc1);

        // ADD: 3 + 4 = 7
        a = 16'd3;
        b = 16'd4;
        op = 3'b000;
        #10;

        // SUB: 10 - 3 = 7
        a = 16'd10;
        b = 16'd3;
        op = 3'b001;
        #10;

        // AND
        a = 16'h00F0;
        b = 16'h0FF0;
        op = 3'b010;
        #10;

        // OR
        a = 16'h00F0;
        b = 16'h0FF0;
        op = 3'b011;
        #10;

        // XOR
        a = 16'hAAAA;
        b = 16'h00FF;
        op = 3'b100;
        #10;

        // SLL by 4
        a = 16'h0003;
        b = 16'd4;
        op = 3'b101;
        #10;

        // SRL by 3
        a = 16'h0080;
        b = 16'd3;
        op = 3'b110;
        #10;

        // PASS A
        a = 16'h1234;
        b = 16'hFFFF;
        op = 3'b111;
        #10;

        $display("TC1 complete. Open tc1.vcd and inspect signals manually.");
        $finish;
    end
endmodule
