TOPNAME ?= SimTop
NAME ?= minirv
INC_PATH ?=
YSYXSOC_HOME ?= $(HOME)/ysyx-workbench/ysyxSoC

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc --trace \
                    -O3 --x-assign fast --x-initial fast --noassert \
										-I$(YSYXSOC_HOME)/perip/uart16550/rtl \
										-I$(YSYXSOC_HOME)/perip/spi/rtl \
										--timescale "1ns/1ns" --no-timing \
										-D__VERILOG__ -DPDK_BEHAV -D__UART_TO_CONSOLE__


BUILD_DIR = ./build/$(NAME)
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(NAME)

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

# Find source files recursively in vsrc and csrc directories
VSRCS = $(shell find $(abspath ./vsrc/minirv) -name "*.v" -or -name "*.sv") \
				$(shell find $(abspath $(YSYXSOC_HOME)/perip) -name "*.v" -or -name "*.sv") \
				$(abspath $(YSYXSOC_HOME)/ready-to-run/minirv/ElaborateTop.v)
CSRCS = $(shell find $(abspath ./csrc/minirv) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""

# Compile binary using Verilator
$(BIN): $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

all: default

run: $(BIN)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@$(BIN)

WAVE_FILE = sim_dump.vcd

wave:
	gtkwave $(WAVE_FILE)

clean:
	rm -rf ./build *.vcd *.fst

lint:
	$(VERILATOR) --lint-only -Wall -Wno-DECLFILENAME \
		--top-module $(TOPNAME) $(VSRCS)

.PHONY: default all clean run wave lint
-include ../Makefile
