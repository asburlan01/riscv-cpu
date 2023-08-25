import cocotb
from cocotb.triggers import Timer
from enum import IntEnum
import random

half_period = 4

async def reset_module(dut):
    dut.clk.value = 0
    dut.rst.value = 0
    await Timer(half_period, units="ns")
    dut.rst.value = 1
    await Timer(half_period, units="ns")
    dut.rst.value = 0

async def clock_pulse(dut):
    dut.clk.value = 1
    await Timer(half_period, units="ns")
    dut.clk.value = 0
    await Timer(half_period, units="ns")

@cocotb.test()
async def alu_reg2reg_ops(dut):
    dut.decode_crossbar_sel1.value = 0
    dut.decode_crossbar_sel2.value = 1
    dut.decode_alu_function.value = 0

    await clock_pulse(dut)
    
    dut.rf_reg1_val.value = 32
    dut.rf_reg2_val.value = 44
    await Timer(half_period, units="ns")

    assert dut.wb_alu_out.value == 76
