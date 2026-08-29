TOPNAME ?= sim_top
NAME ?= minirv
INC_PATH ?=

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc --trace \
                    -O3 --x-assign fast --x-initial fast --noassert \
                    -Wall -Wno-DECLFILENAME -Wno-UNUSED

BUILD_DIR = ./build/$(NAME)
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(NAME)

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

# Find source files recursively in vsrc and csrc directories
VSRCS = $(shell find $(abspath ./vsrc/minirv) -name "*.v" -or -name "*.sv")
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
