// Unified file list for EDA Playground + Cadence Xcelium
// Compile all files, then select one top module to run:
//   tb_tc1, tb_tc2, tb_tc3, or tb_tc4

// Shared/common first
rtl/alu16.sv
tb/common/alu_common_pkg.sv
tb/common/alu_if.sv

// Testcases (each has its own top module)
tb/tc1_stimulus_waveform/tb_tc1.sv
tb/tc2_interface_directed/tb_tc2.sv
tb/tc3_class_virtual_if/tb_tc3.sv
tb/tc4_constrained_random_reusable/tb_tc4.sv
