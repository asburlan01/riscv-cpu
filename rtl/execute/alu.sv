`include "execute/common.sv"

module ALU (
    op1,
    op2,
    alu_function,
    res
);

input  [31:0] op1;
input  [31:0] op2;

input e_alu_function alu_function;
output logic [31:0] res;
logic [31:0] sum;
assign sum = op1 + op2;

always_comb begin
    case (alu_function)
        ALU_ADD: res = op1 + op2;
        ALU_SUB: res = op1 - op2;
        ALU_AND: res = op1 & op2;
        ALU_OR:  res = op1 | op2;
        ALU_XOR: res = op1 ^ op2;
        ALU_ADD_SIGN_FLIP: res = {{1'b0}, {sum[30:0]}};
        ALU_SLL: res = 32'hdeadbeef; // unsupported yet
        ALU_SRL: res = 32'hdeadbeef;
        ALU_SRA: res = 32'hdeadbeef;
        ALU_DISABLE: res = 32'd0;
     endcase
end

endmodule

