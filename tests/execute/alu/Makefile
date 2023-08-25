SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += ${PROJ_ROOT}/rtl/execute/alu.sv
VERILOG_INCLUDE_DIRS = ${PROJ_ROOT}/rtl
TOPLEVEL = ALU
MODULE = alu_tests

ifeq (${SIM}, verilator)
	EXTRA_ARGS +=--timing --unroll-count 1024
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

