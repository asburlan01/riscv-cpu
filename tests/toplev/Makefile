SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += ../../rtl/toplev/toplev.sv
VERILOG_INCLUDE_DIRS = ../../rtl
TOPLEVEL = TopLev
MODULE = toplev_tests

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

