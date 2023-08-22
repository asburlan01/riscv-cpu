SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += ../../rtl/fetch/fetch.sv
VERILOG_INCLUDE_DIRS = ../../rtl ../../rtl/fetch
TOPLEVEL = Fetch
MODULE = fetch_tests

ifeq (${SIM}, verilator)
	EXTRA_ARGS +=--timing --unroll-count 512
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

