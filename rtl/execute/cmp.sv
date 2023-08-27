`include "execute/common.sv"

module CMP(
    input unsigned [31:0] op1,
    input unsigned [31:0] op2,
    input e_cmp_function cmp_function,
    output logic res
);

logic signed [31:0] signed_op1;
assign signed_op1 = op1;

logic signed [31:0] signed_op2;
assign signed_op2 = op2;

always_comb begin
    case (cmp_function)
        CMP_EQ:  res = op1 == op2;
        CMP_NE:  res = op1 != op2;
        CMP_LT:  res = signed_op1 < signed_op2;
        CMP_LTU: res = op1 < op2;
        CMP_GE:  res = signed_op1 >= signed_op2;
        CMP_GEU: res = op1 >= op2;
        CMP_DISABLE: res = 1'b0;
        default: res = 1'b0;
     endcase
end

endmodule
