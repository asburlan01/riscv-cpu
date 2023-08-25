import cocotb
from cocotb.triggers import Timer
from enum import IntEnum
import random

half_period = 4

class AluFunction(IntEnum):
    ADD = 0 
    SUB = 1 
    AND = 2 
    OR  = 3 
    XOR = 4

    def __str__(self):
        names = ["+", "-", "&", "|", "^"]
        return names[self]

    # Returns unsigned integers
    def __call__(self, A, B):
        if (self == AluFunction.ADD):
            return (A + B) & 0xFFFFFFFF
        elif (self == AluFunction.SUB):
            B = ~B + 1
            return (A + B) & 0xFFFFFFFF
        elif (self == AluFunction.AND):
            return A & B
        elif (self == AluFunction.OR):
            return A | B
        elif (self == AluFunction.XOR):
            return A ^ B

async def run_alu(dut, A, B, func):
    dut.op1.value = A
    dut.op2.value = B
    dut.alu_function.value = func

    await Timer(half_period, units="ns")
    return dut.res.value

async def run_alu_test(dut, func, n_iter = 10):
    for i in range(n_iter):
        A = random.randint(0, 0xFFFFFFFF)
        B = random.randint(0, 0xFFFFFFFF)

        alu_res = await run_alu(dut, A, B, func)
        
        assert alu_res == func(A, B), "Different results for {A} {func} {B}: Python: {func(A, B)}, RTL: {alu_res}"


@cocotb.test()
async def alu_add_function(dut):
    await run_alu_test(dut, AluFunction.ADD)

@cocotb.test()
async def alu_sub_function(dut):
    await run_alu_test(dut, AluFunction.SUB)

@cocotb.test()
async def alu_and_function(dut):
    await run_alu_test(dut, AluFunction.AND)

@cocotb.test()
async def alu_or_function(dut):
    await run_alu_test(dut, AluFunction.OR)

@cocotb.test()
async def alu_xor_function(dut):
    await run_alu_test(dut, AluFunction.XOR)

