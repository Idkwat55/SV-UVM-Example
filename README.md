# 16-bit ALU Course Example (SystemVerilog)

This repository demonstrates a progressive verification journey using 4 testcases.

## Primary Flow: Interactive Codespaces + Make + GTKWave

Goal: users click the repo, open Codespace, run tests in terminal, and open waveforms interactively.

### 1) Open in Codespaces
- Link format: `https://github.com/<owner>/<repo>/codespaces/new`
- For your repo: `https://github.com/Idkwat55/SV-UVM-Example/codespaces/new`

The devcontainer installs:
- Verilator
- Icarus Verilog (used to run class/constraint-heavy testcases)
- GTKWave
- desktop-lite GUI support (port 6080)

### 2) Run testcases from terminal

```bash
make run tc1
make run tc2
make run tc3
make run tc4
```

### 3) Open waveform in GUI

```bash
make view tc1
```

If GUI does not appear directly in your browser VS Code window, open forwarded port `6080` (Codespaces Desktop).

### 4) Other useful targets

```bash
make run-all
make lint tc1
make clean
```

## DUT
- `rtl/alu16.sv`: 16-bit combinational ALU
- Operations: ADD, SUB, AND, OR, XOR, SLL, SRL, PASS A
- Flags: carry, zero, overflow

## Shared Verification Components
- `tb/common/alu_common_pkg.sv`:
  - ALU op enum
  - Result struct
  - `alu_predict(...)` reference model
- `tb/common/alu_if.sv`:
  - interface for DUT pins
  - reusable `drive(...)` and `sample(...)` tasks

## Testcases (Progressive)
1. `tb/tc1_stimulus_waveform/tb_tc1.sv`
   - stimulus only
   - no self-checking
   - inspect outputs in waveform (`tc1.vcd`)

2. `tb/tc2_interface_directed/tb_tc2.sv`
   - introduces interface
   - directed vectors with basic self-checking

3. `tb/tc3_class_virtual_if/tb_tc3.sv`
   - introduces classes + virtual interface
   - transaction, driver, monitor, scoreboard
   - randomized tests with automated checking

4. `tb/tc4_constrained_random_reusable/tb_tc4.sv`
   - constrained-random transaction generation
   - functional coverage
   - reusable environment class with run/report
   - automated pass/fail flow

## Manual compile/run (Icarus Verilog)
From repo root:

```powershell
iverilog -g2012 -o sim/tc1.out -c sim/filelists/tc1.f
vvp sim/tc1.out

iverilog -g2012 -o sim/tc2.out -c sim/filelists/tc2.f
vvp sim/tc2.out

iverilog -g2012 -o sim/tc3.out -c sim/filelists/tc3.f
vvp sim/tc3.out

iverilog -g2012 -o sim/tc4.out -c sim/filelists/tc4.f
vvp sim/tc4.out
```

If you use another simulator (Questa/VCS/Xcelium), keep compile order the same as filelists.
