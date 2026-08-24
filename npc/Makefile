TOPNAME = top
VSRCS = $(shell find $(abspath .) -name "*.v" -o -name "*.sv")
CSRCS = $(shell find $(abspath .) -name "*.c" -o -name "*.cc" -o -name "*.cpp")

VERILATOR_FLAGS += --cc --exe --trace-fst --build -j 0
BIN = ./obj_dir/V$(TOPNAME)

all: sim
	

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@verilator $(VERILATOR_FLAGS) $(VSRCS) $(CSRCS)
	@$(BIN)

wave: sim_dump.fst
				@gtkwave sim_dump.fst

clean:
			rm -rf obj_dir sim_dump.fst
	
include ../Makefile
