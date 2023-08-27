`ifndef EXECUTE_COMMON
`define EXECUTE_COMMON

typedef enum logic [2:0] {
    ALU_ADD = 0, 
    ALU_SUB = 1, 
    ALU_AND = 2, 
    ALU_OR  = 3, 
    ALU_XOR = 4,
    ALU_ADD_SIGN_FLIP = 5,
    ALU_BYPASS_OP2 = 6,
    ALU_DISABLE = 7
} e_alu_function;

typedef enum logic [2:0] {
    CMP_EQ  = 3'b000, 
    CMP_NE  = 3'b001, 
    CMP_LT  = 3'b100, 
    CMP_LTU = 3'b110, 
    CMP_GE  = 3'b101, 
    CMP_GEU = 3'b111,
    CMP_DISABLE = 3'b010
} e_cmp_function;

typedef enum logic [1:0] {
    INST_REG_IMM = 2'b00,
    INST_PC_IMM  = 2'b01,
    INST_REG_REG = 2'b10,
    INST_PC_REG = 2'b11
} e_inst_type;

`endif

