module data_memory (
    input  wire       clk,
    input  wire [7:0] address,
    input  wire [7:0] write_data,
    input  wire       mem_read,
    input  wire       mem_write,
    output wire [7:0] read_data
);

    reg [7:0] memory [0:255];

    assign read_data = mem_read ? memory[address] : 8'b0;

    always @(posedge clk) begin
        if (mem_write) begin
            memory[address] <= write_data;
        end
    end

endmodule