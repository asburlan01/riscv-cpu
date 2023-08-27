`include "execute/common.sv"

module WriteBack(
    input clk,
    input rst,

    // From Execute
    input [31:0] execute_pc,
    input e_inst_type execute_inst_type,
    input execute_cmp_out,
    input [31:0] execute_alu_out,
    input execute_is_linking_branch,
    input [31:0] execute_pred_next_pc,
    input [ 4:0] execute_rd,
    input e_rf_write_source execute_rf_write_source,

    // To Fetch
    output fetch_branch_update_valid,
    output fetch_branch_update_taken,
    output fetch_branch_update_mispredicted,
    output fetch_branch_update_unconditional,
    output [31:0] fetch_branch_update_addr,
    output [31:0] fetch_branch_update_target,

    // To RegFile
    output logic rf_write_enable,
    output [ 4:0] rf_write_reg,
    output logic [31:0] rf_write_value
);

// Input Flops
logic [31:0] pc_flop;
e_inst_type inst_type_flop;
logic cmp_out_flop;
logic [31:0] alu_out_flop;
logic is_linking_branch_flop;
logic [31:0] pred_next_pc_flop;
logic [4:0] rd_flop;
e_rf_write_source rf_write_source_flop;

// Branch Handling
logic [31:0] next_pc;
logic [31:0] sequential_pc;
logic is_branch;
logic is_taken;

assign sequential_pc = pc_flop + 32'd4;

always_comb begin
    if (is_linking_branch_flop) begin // JAL, JALR
        next_pc = alu_out_flop;
        is_branch = 1'b1;
        is_taken = 1'b1;
    end else if (inst_type_flop == INST_PC_IMM) begin // JC
        next_pc = cmp_out_flop ? alu_out_flop : sequential_pc;
        is_branch = 1'b1;
        is_taken = cmp_out_flop;
    end else begin // Other instructions
        next_pc   = sequential_pc;
        is_branch = 1'b0;
        is_taken  = 1'b0; 
    end
end

logic [31:0] inst_rf_write_value;

logic misprediction_detected;
assign misprediction_detected = next_pc != pred_next_pc_flop;

// RegFile writes handling

// do not write anything if currently squashing
// writes to x0 are ignored
assign rf_write_enable = ~|squash_cycles && |rd_flop; 
assign rf_write_reg = rd_flop; 

always_comb
    case (rf_write_source_flop)
        SOURCE_ALU:    rf_write_value = alu_out_flop;
        SOURCE_CMP:    rf_write_value = {{30'd0},{cmp_out_flop}};
        SOURCE_SEQ_PC: rf_write_value = sequential_pc;
        SOURCE_MEM:    rf_write_value = 32'hdeadbeef; // Not supported yet
     endcase

// Fetch branch updates handling
//
assign fetch_branch_update_valid = ~|squash_cycles && is_branch;
assign fetch_branch_update_taken = is_taken;
assign fetch_branch_update_mispredicted = misprediction_detected;
assign fetch_branch_update_unconditional = is_linking_branch_flop;
assign fetch_branch_update_addr = pc_flop;
assign fetch_branch_update_target = next_pc;

logic [2:0] squash_cycles;
logic [2:0] next_squash_cycles;

always_comb
    if (|squash_cycles)
        next_squash_cycles = squash_cycles - 1;
    else if (misprediction_detected)
        next_squash_cycles = 3'd4;
    else
        next_squash_cycles = 3'd0;

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        squash_cycles <= 3'd3;
    else begin
        squash_cycles <= next_squash_cycles;

        // flop inputs, ignore squasing cycles
        if (next_squash_cycles == 3'd0) begin
            pc_flop <= execute_pc;
            inst_type_flop <= execute_inst_type;
            cmp_out_flop <= execute_cmp_out;
            alu_out_flop <= execute_alu_out;
            is_linking_branch_flop <= execute_is_linking_branch;
            pred_next_pc_flop <= execute_pred_next_pc;
            rd_flop <= execute_rd;
            rf_write_source_flop <= execute_rf_write_source;
        end
    end
end

endmodule

