`include "macros/sky130_sram_1kbyte_1rw1r_32x256_8.v"

module BTB(
    input  clk,
    input  rst,

    // BTB updates
    input update_valid,
    input [31:0] update_addr,
    input [31:0] update_target,
    
    // BTB queries
    input  [31:0] query_pc,
    output [31:0] pred_pc,
    output logic pred_pc_valid
);

logic valid[0:255];

logic [7:0] hashed_query_pc;
assign hashed_query_pc = query_pc[7:0];

logic [7:0] hashed_update_addr;
assign hashed_update_addr = update_addr[7:0];

sky130_sram_1kbyte_1rw1r_32x256_8 target_buffer(
    // Update write port   
    .clk0(clk),
    .csb0(~update_valid),
    .web0(1'b0),
    .wmask0(4'hf),
    .addr0(hashed_update_addr),
    .din0(update_target),
    .dout0(),
    
    
    // Query read port   
    .clk1(clk),
    .csb1(1'b0),
    .addr1(hashed_query_pc),
    .dout1(pred_pc)
);

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        for (int i = 0; i < 256; i++)
            valid[i] <= 1'b0;
    else begin
        if (update_valid)
            valid[hashed_update_addr] <= 1'b1;
        pred_pc_valid <= valid[hashed_query_pc];
    end
end

endmodule

