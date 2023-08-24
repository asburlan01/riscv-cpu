module BPU #(
    parameter bpu_size = 10,
    parameter counter_size = 2
)(
    input clk,
    input rst,

    input [31:0] query_addr, 
    output logic prediction,

    input update_valid,
    input [31:0] update_addr,
    input update_taken
);

// TODO: check whether we should use an sram here

logic valid[0:(1 << bpu_size) - 1];
logic [counter_size-1:0] sat_counters[0 : (1 << bpu_size) - 1];

logic [bpu_size-1:0] query_addr_hash;
assign query_addr_hash = query_addr[bpu_size-1:0];

logic pred;
assign pred = valid[query_addr_hash] && sat_counters[query_addr_hash][counter_size-1];

logic [bpu_size-1:0] update_addr_hash;
assign update_addr_hash = update_addr[bpu_size-1:0];

logic [counter_size-1:0] updated_counter;

always_comb
    if (valid[update_addr_hash])
        if (update_taken)
            if (&sat_counters[update_addr_hash])
                updated_counter = sat_counters[update_addr_hash];
            else
                updated_counter = sat_counters[update_addr_hash] + 1;
        else
            if (|sat_counters[update_addr_hash])
                updated_counter = sat_counters[update_addr_hash] - 1;
            else
                updated_counter = sat_counters[update_addr_hash];
    else
        updated_counter = {counter_size{update_taken}};

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (int i = 0; i < (1 << bpu_size); i++) begin
            valid[i] <= 1'b0;
        end
        prediction <= 1'b0;
    end else begin
        prediction <= pred;
        if (update_valid) begin
            valid[update_addr_hash] <= 1'b1;
            sat_counters[update_addr_hash] <= updated_counter;
        end
    end
end

endmodule

