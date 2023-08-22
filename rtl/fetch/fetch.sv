`include "btb.sv"
// `include "bpu.sv"

module Fetch #(
    parameter reset_vector = 0
) (
    input clk,
    input rst,
    input btb_update_valid,
    input [31:0] btb_update_addr,
    input [31:0] btb_update_target,
    output logic [31:0] pc
);

// logic [31:0] pc;
logic [31:0] next_pc;

logic [31:0] btb_pred_pc;
logic btb_pred_pc_valid;

BTB btb(
    .clk(clk),
    .rst(rst),

    // BTB updates
    .update_valid(btb_update_valid),
    .update_addr(btb_update_addr),
    .update_target(btb_update_target),

    // BTB queries
    .query_pc(next_pc),
    .pred_pc(btb_pred_pc),
    .pred_pc_valid(btb_pred_pc_valid)
);

always_comb begin
    if (btb_pred_pc_valid)
        next_pc = btb_pred_pc;
    else
        next_pc = pc + 4;
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= reset_vector;
    end else begin
        pc <= next_pc;
    end
end

endmodule

