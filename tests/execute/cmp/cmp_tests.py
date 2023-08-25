import cocotb
from cocotb.triggers import Timer
from enum import IntEnum
import random

half_period = 4

class CmpFunction(IntEnum):
    EQ  = 0 
    NE  = 1 
    LT  = 2 
    LTU = 3 
    GE  = 4 
    GEU = 5

    def __str__(self):
        names = ["==", "!=", "<", "<U", ">=", ">=U"]
        return names[self]

    def __call__(self, A, B):
        if (self == CmpFunction.EQ):
            return int(A == B)
        elif (self == CmpFunction.NE):
            return int(A != B)
        elif (self == CmpFunction.LT):
            return int(A < B)
        elif (self == CmpFunction.LTU):
            A = A & 0xFFFFFFFF 
            B = B & 0xFFFFFFFF 
            return int(A < B)
        elif (self == CmpFunction.GE):
            return int(A >= B)
        elif (self == CmpFunction.GEU):
            A = A & 0xFFFFFFFF
            B = B & 0xFFFFFFFF
            return int(A >= B)

async def run_cmp(dut, A, B, func):
    dut.op1.value = A
    dut.op2.value = B
    dut.cmp_function.value = func

    await Timer(half_period, units="ns")
    return dut.res.value

async def test_func(dut, func, iters = 10):
    for i in range(iters):
        A = random.randint(-(1<<31), (1 << 31)-1)
        B = random.randint(-(1<<31), (1 << 31)-1)

        cmp_res = await run_cmp(dut, A, B, func)

        assert cmp_res == func(A,B), f"Different results for {A} {str(func)} {B}. Python: {func(A,B)}, RTL: {cmp_res}"

@cocotb.test()
async def cmp_eq_function(dut):
    await test_func(dut, CmpFunction.EQ)

@cocotb.test()
async def cmp_neq_function(dut):
    await test_func(dut, CmpFunction.NE)

@cocotb.test()
async def cmp_lt_function(dut):
    await test_func(dut, CmpFunction.LT)

@cocotb.test()
async def cmp_ltu_function(dut):
    await test_func(dut, CmpFunction.LTU)

@cocotb.test()
async def cmp_ge_function(dut):
    await test_func(dut, CmpFunction.GE)

@cocotb.test()
async def cmp_geu_function(dut):
    await test_func(dut, CmpFunction.GEU)
