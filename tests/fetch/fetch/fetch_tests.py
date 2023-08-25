import cocotb
from cocotb.triggers import Timer

half_period = 4

async def reset_module(dut):
    dut.rst.value = 0
    await Timer(half_period, units="ns")
    dut.rst.value = 1
    await Timer(half_period, units="ns")
    dut.rst.value = 0

@cocotb.test()
async def pc_resets_to_0(dut):
    await reset_module(dut)
    
    assert dut.pc.value == 0, "pc did not reset to 0"

@cocotb.test()
async def pc_increments_each_clock_cycle(dut):
    await reset_module(dut)
    
    dut.clk.value = 0
    await Timer(half_period, units="ns")
    dut.clk.value = 1
    await Timer(half_period, units="ns")
    
    assert dut.pc.value == 4
    
    dut.clk.value = 0
    await Timer(half_period, units="ns")
    dut.clk.value = 1
    await Timer(half_period, units="ns")
    
    assert dut.pc.value == 8
    
    dut.clk.value = 0
    await Timer(half_period, units="ns")
    dut.clk.value = 1
    await Timer(half_period, units="ns")
    
    assert dut.pc.value == 12

@cocotb.test()
async def updates_btb(dut):
    await reset_module(dut)

    dut.clk.value = 0
    await Timer(half_period, units="ns")
    dut.clk.value = 1
    await Timer(half_period, units="ns")
    
    dut.btb_update_valid.value = 1
    dut.btb_update_addr.value  = 16
    dut.btb_update_target.value = 32
    
    dut.bpu_update_valid.value = 1
    dut.bpu_update_addr.value  = 16
    dut.bpu_update_taken.value = 1

    dut.clk.value = 0
    await Timer(half_period, units="ns")
    dut.clk.value = 1
    await Timer(half_period, units="ns")
    
    dut.clk.value = 0
    await Timer(half_period, units="ns")
    dut.btb_update_valid.value = 0
    dut.bpu_update_valid.value = 0
    dut.clk.value = 1
    await Timer(half_period, units="ns")
    
    dut.clk.value = 0
    await Timer(half_period, units="ns")
    dut.clk.value = 1
    await Timer(half_period, units="ns")
    
    dut.clk.value = 0
    await Timer(half_period, units="ns")
    dut.clk.value = 1
    await Timer(half_period, units="ns")
    
    assert dut.pc.value == 32
    
