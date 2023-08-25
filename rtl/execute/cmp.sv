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
        EQ:  res = op1 == op2;
        NE:  res = op1 != op2;
        LT:  res = signed_op1 < signed_op2;
        LTU: res = op1 < op2;
        GE:  res = signed_op1 >= signed_op2;
        GEU: res = op1 >= op2;
        default: res = 1'b0;
     endcase
end

endmodule
