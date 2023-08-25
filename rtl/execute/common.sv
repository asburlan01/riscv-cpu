`ifndef EXECUTE_COMMON
`define EXECUTE_COMMON

typedef enum logic [2:0] {
    ADD = 0, 
    SUB = 1, 
    AND = 2, 
    OR  = 3, 
    XOR = 4 
} e_alu_function;

typedef enum logic [2:0] {
    EQ  = 0, 
    NE  = 1, 
    LT  = 2, 
    LTU = 3, 
    GE  = 4, 
    GEU = 5
} e_cmp_function;

typedef enum logic [1:0] {
    INST_REG_IMM = 2'b00,
    INST_PC_IMM  = 2'b01,
    INST_REG_REG = 2'b10
} e_inst_type;

`endif

