module CrossBar #(parameter size = 1)(
    input logic sel,
    input [size-1:0] in1,
    input [size-1:0] in2,
    output logic [size-1:0] out1,
    output logic [size-1:0] out2
);
    always_comb begin
        if (sel)
            begin
                out1 = in2;
                out2 = in1;
            end
        else
            begin
                out1 = in1;
                out2 = in2;
            end
    end
endmodule
