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

always_comb begin
    case (alu_function)
        ADD: res = op1 + op2;
        SUB: res = op1 - op2;
        AND: res = op1 & op2;
        OR:  res = op1 | op2;
        XOR: res = op1 ^ op2;
        default: res = 32'd0;
     endcase
end

endmodule

