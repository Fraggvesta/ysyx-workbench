.DEFAULT_GOAL := default
SOC ?= 0

NAME ?= minirv
INC_PATH ?=
YSYXSOC_HOME ?= $(HOME)/ysyx-workbench/ysyxSoC
NVBOARD_HOME ?= $(HOME)/ysyx-workbench/nvboard

NETLIST ?= 0
ifeq ($(NETLIST),1)
BUILD_DIR = ./build/netlist
VSRCS = vsrc/testb/sim_top.v vsrc/testb/mem.v vsrc/netlist/minirv_sim.v <path-to-cell-models>.v
VFLAGS += --timescale "1ns/1ns" --no-timing -D__VERILATOR__ -Dfunctional -Wno-fatal -DNETLIST
CXXFLAGS += -DNETLIST
endif

ifeq ($(SOC),1)
TOPNAME = SimTop
BUILD_DIR = ./build/soc
NXDC_FILES = $(abspath ./constr/simtop.nxdc)
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

include $(NVBOARD_HOME)/scripts/nvboard.mk
IMG ?= $(YSYXSOC_HOME)/ready-to-run/minirv/hello-minirv-ysyxsoc.bin
else
TOPNAME = sim_top
BUILD_DIR = ./build/npc
endif

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc --trace-fst \
                    -O3 --x-assign fast --x-initial fast --noassert
ifeq ($(SOC),1)
VERILATOR_CFLAGS += -DSOC \
                    -I$(YSYXSOC_HOME)/perip/uart16550/rtl \
                    -I$(YSYXSOC_HOME)/perip/spi/rtl \
                    --timescale "1ns/1ns" --no-timing \
                    -D__VERILOG__ -DPDK_BEHAV -D__UART_TO_CONSOLE__
CXXFLAGS += -DSOC
endif


OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(NAME)
default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

# Find source files recursively in vsrc and csrc directories
VSRCS = $(shell find $(abspath ./vsrc/minirv) -name "*.v" -or -name "*.sv")
ifeq ($(SOC),1)
VSRCS += $(shell find $(abspath $(YSYXSOC_HOME)/perip) -name "*.v" -or -name "*.sv") \
$(abspath $(YSYXSOC_HOME)/ready-to-run/minirv/ElaborateTop.v)
else
VSRCS += $(abspath ./vsrc/testb/sim_top.v) $(abspath ./vsrc/testb/mem.v)
endif
CSRCS = $(shell find $(abspath ./csrc/minirv) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
CSRCS += $(SRC_AUTO_BIND)


INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""

# Compile binary using Verilator
$(BIN): $(VSRCS) $(CSRCS) $(SRC_AUTO_BIND) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

all: default

run: $(BIN)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@$(BIN) $(IMG)

WAVE_FILE = sim_dump.vcd

wave:
	gtkwave $(WAVE_FILE)

clean:
	rm -rf ./build *.vcd *.fst


CPU_VSRCS = $(shell find $(abspath ./vsrc/minirv) -name "*.v" -or -name "*.sv")

lint:
	$(VERILATOR) --lint-only -Wall -Wno-DECLFILENAME \
		--top-module ysyx_20237522 $(CPU_VSRCS)

.PHONY: default all clean run wave lint
-include ../Makefile