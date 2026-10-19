module register_file (
    input  wire clk,
    input  wire reset,
    input  wire reg_write,
    input  wire [2:0] read_addr_a,
    input  wire [2:0] read_addr_b,
    input  wire [2:0] write_reg,
    input  wire [7:0] write_content,
    output wire [7:0] read_data_a,
    output wire [7:0] read_data_b
);

  integer i;
  reg [7:0] memory[7:0];

  // Ground address 0 to return zero whenever r0 is accessed  
  assign read_data_a = (read_addr_a == 3'b000) ? 8'b0 : memory[read_addr_a];
  assign read_data_b = (read_addr_b == 3'b000) ? 8'b0 : memory[read_addr_b];

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (i = 0; i < 8; i = i + 1) begin
        memory[i] <= 8'b00000000;
      end
    end else if (reg_write && (write_reg != 3'b000)) begin
      memory[write_reg] <= write_content;
    end
  end

endmodule
