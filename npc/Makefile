TOPNAME ?= light
NXDC_FILES = constr/$(TOPNAME).nxdc 
INC_PATH ?=

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc --trace \
          -O3 --x-assign fast --x-initial fast --noassert

BUILD_DIR = ./build/$(TOPNAME)
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

# constraint file rule
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

VSRCS = $(shell find $(abspath ./vsrc/$(TOPNAME)) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc/$(TOPNAME)) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
CSRCS += $(SRC_AUTO_BIND)

include $(NVBOARD_HOME)/scripts/nvboard.mk

INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
	  --top-module $(TOPNAME) $^ \
	  $(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
	  --Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

all: default
	

run: $(BIN)
				$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
				@$^

WAVE_FILE = $(BUILD_DIR)/sim_dump.vcd

wave: $(WAVE_FILE)
				gtkwave $(WAVE_FILE)

clean:
			rm -rf $(BUILD_DIR) sim_dump.fst

.PHONY: default all clean run wave
include ../Makefile
