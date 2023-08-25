`include "util/crossbar.sv"
`include "execute/common.sv"
`include "execute/alu.sv"
`include "execute/cmp.sv"

module Execute (
    input clk,
    input rst,

    // From Decode
    input  [31:0] decode_pc,
    input  [31:0] decode_imm,
    input e_inst_type decode_inst_type,
    input e_alu_function decode_alu_function,
    input e_cmp_function decode_cmp_function,
    input  [ 4:0] decode_reg1,
    input  [ 4:0] decode_reg2,
    input decode_is_linking_branch,
    input [31:0] decode_pred_next_pc,
    input [ 4:0] decode_rd,

    // From RegFile
    output logic [ 4:0] rf_reg1,
    input  [31:0] rf_reg1_val,
    output logic [ 4:0] rf_reg2,
    input  [31:0] rf_reg2_val,
    
    // To WriteBack
    output [31:0] wb_pc,
    output e_inst_type wb_inst_type,
    output wb_cmp_out,
    output [31:0] wb_alu_out,
    output wb_is_linking_branch,
    output [31:0] wb_pred_next_pc,
    output [ 4:0] wb_rd

    // To MemoryController
    // output mem_read_valid,
    // output [31:0] mem_read_addr
);

// Input flops
logic [31:0] pc_flop;
logic [31:0] imm_flop;
e_inst_type inst_type_flop;
e_alu_function alu_function_flop;
e_cmp_function cmp_function_flop;
logic [ 4:0] reg1_flop;
logic [ 4:0] reg2_flop;
logic is_linking_branch_flop;
logic [31:0] pred_next_pc_flop;
logic [ 4:0] rd_flop;

/********************* CrossBar 1 *********************/

logic [31:0] alu_in1;
logic [31:0] cmp_in1;

CrossBar #(.size(32)) crossbar_op1  (
    .sel(inst_type_flop[0]), // from decode
    .in1(pc_flop),
    .in2(rf_reg1_val),
    .out1(cmp_in1),
    .out2(alu_in1)
);

/******************************************************/

/********************* CrossBar 2 *********************/

logic [31:0] alu_in2_mem_in;
logic [31:0] cmp_in2;

CrossBar #(.size(32)) crossbar_op2 (
    .sel(inst_type_flop[1]), // from decode
    .in1(rf_reg2_val),
    .in2(imm_flop), // from decode
    .out1(cmp_in2),
    .out2(alu_in2_mem_in)
);

/******************************************************/

/********************* ALU & CMP **********************/

ALU alu(
    .op1(alu_in1),
    .op2(alu_in2_mem_in),
    .alu_function(alu_function_flop),
    .res(wb_alu_out)
);

CMP cmp(
    .op1(cmp_in1),
    .op2(cmp_in2),
    .cmp_function(cmp_function_flop),
    .res(wb_cmp_out)
);

/******************************************************/

assign rf_reg1 = reg1_flop;
assign rf_reg2 = reg2_flop;

assign wb_pc = pc_flop;
assign wb_inst_type = inst_type_flop;
assign wb_is_linking_branch = is_linking_branch_flop;
assign wb_pred_next_pc = pred_next_pc_flop;
assign wb_rd = rd_flop;

// Flop inputs
always_ff @(posedge clk or posedge rst) begin
    pc_flop <= decode_pc;
    imm_flop <= decode_imm;
    inst_type_flop <= decode_inst_type;
    alu_function_flop <= decode_alu_function;
    cmp_function_flop <= decode_cmp_function;
    reg1_flop <= decode_reg1;
    reg2_flop <= decode_reg2;
    is_linking_branch_flop <= decode_is_linking_branch;
    pred_next_pc_flop <= decode_pred_next_pc;
    rd_flop <= decode_rd;
end

endmodule

