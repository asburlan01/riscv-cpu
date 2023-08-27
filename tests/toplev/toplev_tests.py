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
    await Timer(half_period, units="ns")

async def clock_pulse(dut):
    dut.clk.value = 1
    await Timer(half_period, units="ns")
    dut.clk.value = 0
    await Timer(half_period, units="ns")


@cocotb.test()
async def my_first_test(dut):
    await reset_module(dut)
    instructions = [
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b10000100000001000001100011,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
    ]
   
    for i in instructions:
        dut.read_value.value = i;
        dut._log.info("Read request: %d", dut.read_req.value)
        await clock_pulse(dut)
        dut._log.info("x0 register: %s", dut.regfile.registers[1].value)
    

@cocotb.test()
async def fibonacci(dut):
    await reset_module(dut)
    """
     0: ori x1, x0, 1   // x1 =  1
     4: ori x2, x0, 1   // x2 =  1
     8: ori x4, x0, 10  // x4 = 10
    12: addi x3, x1, 0  // x3 = x1
    16: add x1, x1, x2  // x1 = x1 + x2
    20: addi x2, x3, 0  // x2 = x3
    24: addi x4, x4, -1 // x4 = x4 - 1
    28: jne x4, x0, -16  // jump
    """
    
    instructions = [
        0b0000000000001_00000_110_00001_0010011,
        0b0000000000001_00000_110_00010_0010011,
        0b0000000001010_00000_110_00100_0010011,
        0b0000000000000_00001_000_00011_0010011,
        0b0000000_00010_00001_000_00001_0110011,
        0b0000000000000_00011_000_00010_0010011,
        0b111111111111_00100_000_00100_0010011,
        0b1111111_00000_00100_001_10001_1100011, 
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
        0b1000010110111,
    ]

    dut.read_value.value = instructions[0]

    dut._log.info("Read request: %d", dut.read_req.value)
    dut._log.info("x0=%d, x1=%d, x2=%d, x3=%d, x4=%d",
                  dut.regfile.registers[0].value,
                  dut.regfile.registers[1].value,
                  dut.regfile.registers[2].value,
                  dut.regfile.registers[3].value,
                  dut.regfile.registers[4].value
    )

    while int(dut.read_req.value) < 48:
        req = dut.read_req.value // 4
        await clock_pulse(dut)
        dut._log.info("Read request: %d", dut.read_req.value)
        dut._log.info("x0=%d, x1=%d, x2=%d, x3=%d, x4=%d",
                      dut.regfile.registers[0].value,
                      dut.regfile.registers[1].value,
                      dut.regfile.registers[2].value,
                      dut.regfile.registers[3].value,
                      dut.regfile.registers[4].value
        )
        dut.read_value.value = instructions[req]

