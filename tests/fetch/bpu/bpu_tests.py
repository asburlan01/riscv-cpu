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
    dut.clk.value = 0
    await Timer(half_period, units="ns")
    dut.clk.value = 1
    await Timer(half_period, units="ns")

@cocotb.test()
async def resets_all_entries(dut):
    await reset_module(dut)
    
    dut.query_addr.value = 32
    await clock_pulse(dut)

    assert dut.prediction.value == 0

@cocotb.test()
async def initializes_sat_counters_on_update(dut):
    await reset_module(dut)
    
    dut.update_valid.value = 1
    dut.update_addr.value = 32
    dut.update_taken.value = 1

    await clock_pulse(dut)
    
    dut.update_valid.value = 1
    dut.update_addr.value = 36
    dut.update_taken.value = 0

    await clock_pulse(dut)

    dut.update_valid.value = 0
    dut.query_addr.value = 32
    await clock_pulse(dut)
    assert dut.prediction.value == 1
    
    dut.query_addr.value = 36
    await clock_pulse(dut)
    assert dut.prediction.value == 0

@cocotb.test()
async def updates_counters(dut):
    await reset_module(dut)
    
    dut.update_valid.value = 1
    dut.update_addr.value = 32
    dut.update_taken.value = 1
 
    await clock_pulse(dut)

    dut.query_addr.value = 32

    # counter  3  2  1  0  0  1  2  3  3
    updates = [0, 0, 0, 0, 1, 1, 1, 1, 1]
    results = [1, 1, 0, 0, 0, 0, 1, 1, 1]

    for i, (u,r) in enumerate(zip(updates, results)):
        dut.update_taken.value = u
        await clock_pulse(dut)
        assert dut.prediction.value == r , f"wrong prediction at index {i} in test sequence"

