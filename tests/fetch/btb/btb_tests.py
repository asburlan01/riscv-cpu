import cocotb
from cocotb.triggers import Timer

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
async def valid_entries_are_reset(dut):
    await reset_module(dut)
   
    dut.query_pc.value = 32
    await clock_pulse(dut)

    assert dut.pred_pc_valid.value == 0
    
@cocotb.test()
async def saves_updates(dut):
    await reset_module(dut)
  
    dut.update_valid.value = 1
    dut.update_addr.value = 32
    dut.update_target.value = 64
    await clock_pulse(dut)

    dut.update_valid.value = 0
    dut.query_pc.value = 32
    await clock_pulse(dut)

    assert dut.pred_pc_valid.value == 1
    assert dut.pred_pc.value == 64

