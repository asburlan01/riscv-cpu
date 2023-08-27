`include "fetch/fetch.sv"
`include "decode/decode.sv"
`include "execute/execute.sv"
`include "writeback/writeback.sv"
`include "toplev/regfile.sv"

module TopLev(
    input clk,
    input rst,

    output [31:0] read_req,
    input  [31:0] read_value
);

/******************************************/

logic [4 :0] rf_read_reg1;
logic [31:0] rf_read_val1;

logic [4 :0] rf_read_reg2;
logic [31:0] rf_read_val2;

logic rf_write_enable;
logic [4 :0] rf_write_reg;
logic [31:0] rf_write_val;

RegFile regfile(
    .clk(clk),
    .rst(rst),

    .read_reg1(rf_read_reg1),
    .reg_val1(rf_read_val1),

    .read_reg2(rf_read_reg2),
    .reg_val2(rf_read_val2),

    .write_enable(rf_write_enable),
    .write_reg(rf_write_reg),
    .write_val(rf_write_val)
);

/******************************************/

/******************************************/

logic [31:0] fetch_pc;
logic [31:0] fetch_pred_next_pc;

assign read_req = fetch_pred_next_pc;

Fetch fetch(
    .clk(clk),
    .rst(rst),
    
    // From WriteBack
    .branch_update_valid(wb_branch_update_valid),
    .branch_update_taken(wb_branch_update_taken),
    .branch_update_mispredicted(wb_branch_update_mispredicted),
    .branch_update_unconditional(wb_branch_update_unconditional),
    .branch_update_addr(wb_branch_update_addr),
    .branch_update_target(wb_branch_update_target),
    
    .pc(fetch_pc),
    .next_pc(fetch_pred_next_pc) // To Memory Controller
);

/******************************************/

/******************************************/

logic  [31:0] decode_pc;
logic  [31:0] decode_imm;
e_inst_type decode_inst_type;
e_alu_function decode_alu_function;
e_cmp_function decode_cmp_function;
logic  [ 4:0] decode_reg1;
logic  [ 4:0] decode_reg2;
logic decode_is_linking_branch;
logic [31:0] decode_pred_next_pc;
logic [ 4:0] decode_rd;

Decode decode(
    .clk(clk),
    .rst(rst),

    .fetch_pc(fetch_pc),
    .fetch_pred_next_pc(fetch_pred_next_pc),
    .fetch_inst(read_value),

    .execute_pc(decode_pc),
    .execute_imm(decode_imm),
    .execute_inst_type(decode_inst_type),
    .execute_alu_function(decode_alu_function),
    .execute_cmp_function(decode_cmp_function),
    .execute_reg1(decode_reg1),
    .execute_reg2(decode_reg2),
    .execute_is_linking_branch(decode_is_linking_branch),
    .execute_pred_next_pc(decode_pred_next_pc),
    .execute_rd(decode_rd)
);

/******************************************/

/******************************************/

logic [31:0] execute_pc;
e_inst_type execute_inst_type;
logic execute_cmp_out;
logic [31:0]execute_alu_out;
logic execute_is_linking_branch;
logic [31:0]execute_pred_next_pc;
logic [ 4:0] execute_rd;

Execute execute(
    .clk(clk),
    .rst(rst),

    // From decode
    .decode_pc(decode_pc),
    .decode_imm(decode_imm),
    .decode_inst_type(decode_inst_type),
    .decode_alu_function(decode_alu_function),
    .decode_cmp_function(decode_cmp_function),
    .decode_reg1(decode_reg1),
    .decode_reg2(decode_reg2),
    .decode_is_linking_branch(decode_is_linking_branch),
    .decode_pred_next_pc(decode_pred_next_pc),
    .decode_rd(decode_rd),
   
    // To/From RegFile 
    .rf_reg1(rf_read_reg1),
    .rf_reg1_val(rf_read_val1),
    .rf_reg2(rf_read_reg2),
    .rf_reg2_val(rf_read_val2),

    // To WriteBack
    .wb_pc(execute_pc),
    .wb_inst_type(execute_inst_type),
    .wb_cmp_out(execute_cmp_out),
    .wb_alu_out(execute_alu_out),
    .wb_is_linking_branch(execute_is_linking_branch),
    .wb_pred_next_pc(execute_pred_next_pc),
    .wb_rd(execute_rd)
);

/******************************************/

/******************************************/

logic wb_branch_update_valid;
logic wb_branch_update_taken;
logic wb_branch_update_mispredicted;
logic wb_branch_update_unconditional;
logic [31:0] wb_branch_update_addr;
logic [31:0] wb_branch_update_target;

WriteBack writeback(
    .clk(clk),
    .rst(rst),
    
    // From Execute
    .execute_pc(execute_pc),
    .execute_inst_type(execute_inst_type),
    .execute_cmp_out(execute_cmp_out),
    .execute_alu_out(execute_alu_out),
    .execute_is_linking_branch(execute_is_linking_branch),
    .execute_pred_next_pc(execute_pred_next_pc),
    .execute_rd(execute_rd),

    // To Fetch
    .fetch_branch_update_valid(wb_branch_update_valid),
    .fetch_branch_update_taken(wb_branch_update_taken),
    .fetch_branch_update_mispredicted(wb_branch_update_mispredicted),
    .fetch_branch_update_unconditional(wb_branch_update_unconditional),
    .fetch_branch_update_addr(wb_branch_update_addr),
    .fetch_branch_update_target(wb_branch_update_target),

    // To RegFile
    .rf_write_enable(rf_write_enable),
    .rf_write_reg(rf_write_reg),
    .rf_write_value(rf_write_val)
);

endmodule

