SHELL := /bin/bash

SUPPORTED_TCS := tc1 tc2 tc3 tc4
TC_FROM_GOALS := $(firstword $(filter $(SUPPORTED_TCS),$(MAKECMDGOALS)))
TC ?= $(if $(TC_FROM_GOALS),$(TC_FROM_GOALS),tc1)

FILELIST_tc1 := sim/filelists/tc1.f
FILELIST_tc2 := sim/filelists/tc2.f
FILELIST_tc3 := sim/filelists/tc3.f
FILELIST_tc4 := sim/filelists/tc4.f

WAVE_DIR := sim/waves
OUT_DIR := sim/out
OUT_BIN := $(OUT_DIR)/$(TC).out
WAVE_FILE := $(WAVE_DIR)/$(TC).vcd

.PHONY: help run view clean run-all lint tc1 tc2 tc3 tc4

help:
	@echo "Usage:"
	@echo "  make run tc1      # compile + run testcase tc1"
	@echo "  make view tc1     # open waveform for tc1 in VS Code (WaveTrace extension)"
	@echo "  make run-all      # run all testcases"
	@echo "  make clean        # remove generated files"
	@echo ""
	@echo "Supported testcases: $(SUPPORTED_TCS)"

run: $(OUT_DIR) $(WAVE_DIR)
	@if [[ ! " $(SUPPORTED_TCS) " =~ " $(TC) " ]]; then \
		echo "ERROR: Unsupported testcase '$(TC)'"; exit 1; \
	fi
	@echo "[RUN] Compiling $(TC) using $($(addprefix FILELIST_,$(TC)))"
	@iverilog -g2012 -o $(OUT_BIN) -c $($(addprefix FILELIST_,$(TC)))
	@echo "[RUN] Executing $(TC)"
	@vvp $(OUT_BIN)
	@if [[ -f $(TC).vcd ]]; then \
		mv -f $(TC).vcd $(WAVE_FILE); \
		echo "[RUN] Waveform saved: $(WAVE_FILE)"; \
	else \
		echo "[WARN] Expected waveform $(TC).vcd not found"; \
	fi

view:
	@if [[ ! -f $(WAVE_FILE) ]]; then \
		echo "ERROR: $(WAVE_FILE) does not exist. Run: make run $(TC)"; \
		exit 1; \
	fi
	@echo "[VIEW] Opening $(WAVE_FILE) in VS Code"
	@code -g $(WAVE_FILE) >/dev/null 2>&1 || true
	@echo "[VIEW] If it did not auto-open, open $(WAVE_FILE) in Explorer (WaveTrace extension)."

run-all:
	@for t in $(SUPPORTED_TCS); do \
		echo "==== Running $$t ===="; \
		$(MAKE) run $$t || exit 1; \
	done

lint:
	@if [[ ! " $(SUPPORTED_TCS) " =~ " $(TC) " ]]; then \
		echo "ERROR: Unsupported testcase '$(TC)'"; exit 1; \
	fi
	@echo "[LINT] Verilator syntax check for $(TC)"
	@verilator --lint-only --timing -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME -Wno-TIMESCALEMOD -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -f $($(addprefix FILELIST_,$(TC))) --top-module tb_$(TC)

$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

$(WAVE_DIR):
	@mkdir -p $(WAVE_DIR)

clean:
	@rm -rf $(OUT_DIR) $(WAVE_DIR) obj_dir
	@rm -f *.vcd *.fst

# Dummy targets so commands like "make run tc1" work naturally.
tc1 tc2 tc3 tc4:
	@:
