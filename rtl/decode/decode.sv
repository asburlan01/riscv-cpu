`include "execute/common.sv"

module Decode(
    input clk,
    input rst,

    // From Fetch
    input [31:0] fetch_pc,
    input [31:0] fetch_pred_next_pc,
    input [31:0] fetch_inst,
    
    // To Execute
    output logic [31:0] execute_pc,
    output logic [31:0] execute_imm,
    output e_inst_type execute_inst_type,
    output e_alu_function execute_alu_function,
    output e_cmp_function execute_cmp_function,
    output logic [ 4:0] execute_reg1,
    output logic [ 4:0] execute_reg2,
    output logic [ 4:0] execute_rd,
    output logic execute_is_linking_branch,
    output logic [31:0] execute_pred_next_pc,
    output e_rf_write_source execute_rf_write_source
);

logic [31:0] pc_flop;
logic [31:0] pred_next_pc_flop;
logic [31:0] inst_flop;

assign execute_pc = pc_flop;

logic [6:0] opcode;
logic [2:0] func3;
logic [6:0] func7;

assign opcode = inst_flop[6:0];
assign func3 = inst_flop[14:12];
assign func7 = inst_flop[31:25];

always_comb begin
    
    execute_pred_next_pc = pred_next_pc_flop;
    
    case (opcode)
        // case 7'b: // 
        //     begin
        //         
        //     end
        7'b0110111: // LUI
            begin
                execute_imm = {{inst_flop[31:12]}, {12'd0}};
                execute_inst_type = INST_REG_IMM;
                execute_alu_function = ALU_ADD;
                execute_cmp_function = CMP_DISABLE;
                execute_reg1 = 5'd0;
                execute_reg2 = 5'd0;
                execute_rd = inst_flop[11:7];
                execute_is_linking_branch = 1'b0;
                execute_rf_write_source = SOURCE_ALU;
            end
        7'b0010111: // AUIPC 
            begin
                execute_imm = {{inst_flop[31:12]}, {12'd0}};
                execute_inst_type = INST_PC_IMM;
                execute_alu_function = ALU_ADD;
                execute_cmp_function = CMP_DISABLE;
                execute_reg1 = 5'd0;
                execute_reg2 = 5'd0;
                execute_rd = inst_flop[11:7];
                execute_is_linking_branch = 1'b0;
                execute_rf_write_source = SOURCE_ALU;
            end
        7'b1101111: // JAL 
            begin
                execute_imm = {{12{inst_flop[31]}}, 
                               {inst_flop[19:12]},
                               {inst_flop[20]},
                               {inst_flop[30:21]},
                               {1'b0}};
                execute_inst_type = INST_PC_IMM;
                execute_alu_function = ALU_ADD_SIGN_FLIP;
                execute_cmp_function = CMP_DISABLE;
                execute_reg1 = 5'd0;
                execute_reg2 = 5'd0;
                execute_rd = inst_flop[11:7];
                execute_is_linking_branch = 1'b1;
                execute_rf_write_source = SOURCE_SEQ_PC;
            end
        7'b1100111: // JALR
            begin
                execute_imm = {{21{inst_flop[31]}}, {inst_flop[30:20]}}; 
                execute_inst_type = INST_REG_IMM;
                execute_alu_function = ALU_ADD_SIGN_FLIP;
                execute_cmp_function = CMP_DISABLE;
                execute_reg1 = inst_flop[19:15];
                execute_reg2 = 5'd0;
                execute_rd = inst_flop[11:7];
                execute_is_linking_branch = 1'b1;
                execute_rf_write_source = SOURCE_SEQ_PC;
            end
        7'b1100011: // BEQ, BNE, BLT, BGE, BLTU, BGEU
            begin
                execute_imm = {
                    {20{inst_flop[31]}},
                    {inst_flop[7]},
                    {inst_flop[30:25]},
                    {inst_flop[11:8]},
                    {1'b0}
                };
                execute_inst_type = INST_PC_IMM;
                execute_alu_function = ALU_ADD_SIGN_FLIP;
                `ifdef YOSYS
                execute_cmp_function = func3;
                `else
                execute_cmp_function = e_cmp_function'(func3);
                `endif
                execute_reg1 = inst_flop[19:15];
                execute_reg2 = inst_flop[24:20];
                execute_rd = 5'd0;
                execute_is_linking_branch = 1'b0;
                execute_rf_write_source = SOURCE_CMP;
            end
        7'b0010011: // ADDI, SLTI, SLTIU, XORI, ORI
            begin
                execute_imm = {{21{inst_flop[31]}}, {inst_flop[30:20]}}; 
                execute_reg1 = inst_flop[19:15];
                execute_reg2 = 5'd0;
                execute_rd = inst_flop[11:7];
                execute_is_linking_branch = 1'b0;
                
                case (func3)
                    3'b000: // ADDI
                        begin
                            execute_inst_type = INST_REG_IMM;
                            execute_alu_function = ALU_ADD;
                            execute_cmp_function = CMP_DISABLE;
                            execute_rf_write_source = SOURCE_ALU;
                        end
                    3'b001: // SLLI
                        begin
                            execute_inst_type = INST_REG_IMM;
                            execute_alu_function = ALU_SLL;
                            execute_cmp_function = CMP_DISABLE;
                            execute_rf_write_source = SOURCE_ALU;
                        end
                    3'b010: // SLTI
                        begin
                            execute_inst_type = INST_PC_REG;
                            execute_alu_function = ALU_DISABLE;
                            execute_cmp_function = CMP_LT;
                            execute_rf_write_source = SOURCE_CMP;
                        end
                    3'b011: // SLTIU
                        begin
                            execute_inst_type = INST_PC_REG;
                            execute_alu_function = ALU_DISABLE;
                            execute_cmp_function = CMP_LTU;
                            execute_rf_write_source = SOURCE_CMP;
                        end
                    3'b100: // XORI 
                        begin
                            execute_inst_type = INST_REG_IMM;
                            execute_alu_function = ALU_XOR;
                            execute_cmp_function = CMP_DISABLE;
                            execute_rf_write_source = SOURCE_ALU;
                        end
                    3'b101: // SRLI, SRAI
                        begin
                            execute_inst_type = INST_REG_IMM;
                            // TODO: check this
                            if (inst_flop[30])
                                execute_alu_function = ALU_SRA;
                            else
                                execute_alu_function = ALU_SRL;
                            execute_cmp_function = CMP_DISABLE;
                            execute_rf_write_source = SOURCE_ALU;
                        end
                    3'b110: // ORI 
                        begin
                            execute_inst_type = INST_REG_IMM;
                            execute_alu_function = ALU_OR;
                            execute_cmp_function = CMP_DISABLE;
                            execute_rf_write_source = SOURCE_ALU;
                        end
                    3'b111: // ANDI 
                        begin
                            execute_inst_type = INST_REG_IMM;
                            execute_alu_function = ALU_AND;
                            execute_cmp_function = CMP_DISABLE;
                            execute_rf_write_source = SOURCE_ALU;
                        end
                endcase
            end
        7'b0110011:
            begin
                execute_imm = 32'd0; 
                execute_inst_type = INST_REG_REG;
                execute_reg1 = inst_flop[19:15];
                execute_reg2 = inst_flop[24:20];
                execute_rd = inst_flop[11:7];
                execute_is_linking_branch = 1'b0;
               
                case (func7)
                    7'b0000000:
                        case (func3)
                            3'b000: // ADD
                                begin
                                    execute_alu_function = ALU_ADD;
                                    execute_cmp_function = CMP_DISABLE;
                                    execute_rf_write_source = SOURCE_ALU;
                                end
                            3'b001: // SLL
                                begin
                                    execute_alu_function = ALU_SLL;
                                    execute_cmp_function = CMP_DISABLE;
                                    execute_rf_write_source = SOURCE_ALU;
                                end
                            3'b010: // SLT
                                begin
                                    execute_alu_function = ALU_DISABLE;
                                    execute_cmp_function = CMP_LT;
                                    execute_rf_write_source = SOURCE_CMP;
                                end
                            3'b011: // SLTU
                                begin
                                    execute_alu_function = ALU_DISABLE;
                                    execute_cmp_function = CMP_LTU;
                                    execute_rf_write_source = SOURCE_CMP;
                                end
                            3'b100: // XOR
                                begin
                                    execute_alu_function = ALU_XOR;
                                    execute_cmp_function = CMP_DISABLE;
                                    execute_rf_write_source = SOURCE_ALU;
                                end
                            3'b101: // SRL
                                begin
                                    execute_alu_function = ALU_SRL;
                                    execute_cmp_function = CMP_DISABLE;
                                    execute_rf_write_source = SOURCE_ALU;
                                end
                            3'b110: // OR
                                begin
                                    execute_alu_function = ALU_OR;
                                    execute_cmp_function = CMP_DISABLE;
                                    execute_rf_write_source = SOURCE_ALU;
                                end
                            3'b111: // AND
                                begin
                                    execute_alu_function = ALU_AND;
                                    execute_cmp_function = CMP_DISABLE;
                                    execute_rf_write_source = SOURCE_ALU;
                                end
                        endcase
                    7'b0100000:
                        case (func3)
                            3'b000: // SUB
                                begin
                                    execute_alu_function = ALU_SUB;
                                    execute_cmp_function = CMP_DISABLE;
                                    execute_rf_write_source = SOURCE_ALU;
                                end
                            3'b101: // SRA
                                begin
                                    execute_alu_function = ALU_SRA;
                                    execute_cmp_function = CMP_DISABLE;
                                    execute_rf_write_source = SOURCE_ALU;
                                end
                            default:
                                begin
                                    execute_alu_function = ALU_DISABLE;
                                    execute_cmp_function = CMP_DISABLE;
                                    execute_rf_write_source = SOURCE_CMP;
                                end
                        endcase
                    default:
                        begin
                            execute_alu_function = ALU_DISABLE;
                            execute_cmp_function = CMP_DISABLE;
                            execute_rf_write_source = SOURCE_CMP;
                        end
                endcase 
            end
        default
            begin
                execute_imm = 32'd0; 
                execute_inst_type = INST_REG_IMM;
                execute_alu_function = ALU_DISABLE;
                execute_cmp_function = CMP_DISABLE;
                execute_reg1 = 5'd0;
                execute_reg2 = 5'd0;
                execute_rd = 5'd0;
                execute_is_linking_branch = 1'b0;
                execute_rf_write_source = SOURCE_CMP;
            end
    endcase
end

// Flop Inputs
always_ff @(posedge clk or posedge rst) begin
    if (~rst) begin
        pc_flop <= fetch_pc;
        pred_next_pc_flop <= fetch_pred_next_pc;
        inst_flop <= fetch_inst;
    end
end

endmodule

