`include "fetch/btb.sv"
`include "fetch/bpu.sv"

module Fetch #(
    parameter reset_vector = 0
) (
    input clk,
    input rst,

    // From WriteBack
    input branch_update_valid,
    input branch_update_taken,
    input branch_update_mispredicted,
    input branch_update_unconditional,
    input [31:0] branch_update_addr,
    input [31:0] branch_update_target,

    // Current Program Counter
    output logic [31:0] pc
);

logic branch_update_valid_flop;
logic branch_update_taken_flop;
logic branch_update_mispredicted_flop;
logic branch_update_unconditional_flop;
logic [31:0] branch_update_addr_flop;
logic [31:0] branch_update_target_flop;

// logic [31:0] pc;
logic [31:0] next_pc;

logic [31:0] btb_pred_pc;
logic btb_pred_pc_valid;

logic btb_update_valid;
assign btb_update_valid = 
        branch_update_valid_flop &&
        branch_update_taken_flop &&
        branch_update_mispredicted_flop;

BTB btb(
    .clk(clk),
    .rst(rst),

    // BTB updates
    .update_valid(btb_update_valid),
    .update_addr(branch_update_addr_flop),
    .update_target(branch_update_target_flop),

    // BTB queries
    .query_pc(next_pc),
    .pred_pc(btb_pred_pc),
    .pred_pc_valid(btb_pred_pc_valid)
);

logic bpu_prediction;

logic bpu_update_valid;
assign bpu_update_valid = 
        branch_update_valid_flop &&
        ~branch_update_unconditional_flop;

BPU bpu(
    .clk(clk),
    .rst(rst),
    
    .query_addr(next_pc),
    .prediction(bpu_prediction),

    .update_valid(bpu_update_valid),
    .update_addr(branch_update_addr_flop),
    .update_taken(branch_update_taken_flop)
);

always_comb begin
    if (branch_update_mispredicted_flop)
        next_pc = branch_update_target;
    else if (btb_pred_pc_valid && bpu_prediction)
        next_pc = btb_pred_pc;
    else
        next_pc = pc + 4;
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= reset_vector;
    end else begin
        pc <= next_pc;
        
        branch_update_valid_flop <= branch_update_valid;
        branch_update_taken_flop <= branch_update_taken;
        branch_update_mispredicted_flop <= branch_update_mispredicted;
        branch_update_unconditional_flop <= branch_update_unconditional;
        branch_update_addr_flop <= branch_update_addr;
        branch_update_target_flop <= branch_update_target;
    end
end

endmodule

