import cocotb
from cocotb.triggers import Timer

hp = 1

async def reset_module(dut):
    dut.clk.value = 0
    dut.write_enable.value = 0
    dut.write_reg.value = 0 
    dut.write_val.value = 0
    
    dut.rst.value = 0
    await Timer(hp, units="ns")
    dut.rst.value = 1
    await Timer(hp, units="ns")
    dut.rst.value = 0
    await Timer(hp, units="ns")

@cocotb.test()
async def resets_all_registers_to_0(dut):

    await reset_module(dut)

    for i in range(32):
        dut.read_reg1.value = i
        dut.read_reg2.value = i
        await Timer(hp, units="ns")
        assert dut.reg_val1.value == 0
        assert dut.reg_val2.value == 0
    
@cocotb.test()
async def writes_to_x0_are_ignored(dut):
    await reset_module(dut)

    dut.write_enable.value = 1
    dut.write_reg.value = 0 
    dut.write_val.value = 76

    dut.clk.value = 1
    await Timer(hp, units="ns")
    dut.clk.value = 0
    await Timer(hp, units="ns")

    dut.write_enable.value = 0 
    dut.read_reg1.value = 0
    dut.read_reg2.value = 0

    await Timer(hp, units="ns")

    assert dut.reg_val1.value == 0
    assert dut.reg_val2.value == 0

@cocotb.test()
async def can_write_to_registers(dut):
    await reset_module(dut)

    for i in range(1,32):
        dut.write_enable.value = 1
        dut.write_reg.value = i
        dut.write_val.value = i

        dut.clk.value = 1
        await Timer(hp, units="ns")
        dut.clk.value = 0
        await Timer(hp, units="ns")
        
        dut.write_enable.value = 0
        
        dut.read_reg1.value = i
        dut.read_reg2.value = i
        
        await Timer(hp, units="ns")

        assert dut.reg_val1.value == i
        assert dut.reg_val2.value == i

@cocotb.test()
async def can_forward_to_reg1(dut):
    await reset_module(dut)

    dut.write_enable.value = 1
    dut.write_reg.value = 1 
    dut.write_val.value = 76

    dut.read_reg1.value = 1
    dut.read_reg2.value = 0

    await Timer(hp, units="ns")

    assert dut.reg_val1.value == 76

@cocotb.test()
async def can_forward_to_reg1(dut):
    await reset_module(dut)

    dut.write_enable.value = 1
    dut.write_reg.value = 1 
    dut.write_val.value = 76

    dut.read_reg1.value = 0
    dut.read_reg2.value = 1

    await Timer(hp, units="ns")

    assert dut.reg_val2.value == 76

@cocotb.test()
async def does_not_forward_to_x0(dut):
    await reset_module(dut)

    dut.write_enable.value = 1
    dut.write_reg.value = 0
    dut.write_val.value = 76

    dut.read_reg1.value = 0

    await Timer(hp, units="ns")

    assert dut.reg_val1.value == 0

