module TopLev(
    input clk,
    input rst,
    output logic [1:0] counter
);

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        counter <= 0;
    else
        if (counter == 2'b11)
            counter <= 0;
        else
            counter <= counter + 1'b1;
end

endmodule
