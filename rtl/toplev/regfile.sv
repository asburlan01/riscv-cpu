module RegFile(
    input clk,
    input rst,

    input  [4 :0] read_reg1,
    output logic [31:0] reg_val1,

    input  [4 :0] read_reg2,
    output logic [31:0] reg_val2,

    input write_enable,
    input [4 :0] write_reg,
    input [31:0] write_val
);

logic [31:0] registers[0:31];

// writes to x0 are ignored

logic true_write;
assign true_write = write_enable && |write_reg;

logic forward1;
assign forward1 = true_write && (write_reg == read_reg1);
assign reg_val1 = forward1 ? write_val : registers[read_reg1];

logic forward2;
assign forward2 = true_write && (write_reg == read_reg2);
assign reg_val2 = forward2 ? write_val : registers[read_reg2];

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        for (int i = 0; i < 32; i = i + 1)
            registers[i] <= 32'd0;
    else begin
        if (true_write)
            registers[write_reg] <= write_val;
    end
end

endmodule

