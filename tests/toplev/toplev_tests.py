import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def my_first_test(dut):
    """Try accessing the design."""

    dut.rst.value = 0
    await Timer(1, units="ns")
    dut.rst.value = 1
    await Timer(1, units="ns")
    dut.rst.value = 0
    await Timer(1, units="ns")

    for cycle in range(8):
        dut.clk.value = 0
        await Timer(1, units="ns")
        dut.clk.value = 1
        await Timer(1, units="ns")

    dut._log.info("counter is %s", dut.counter.value)

