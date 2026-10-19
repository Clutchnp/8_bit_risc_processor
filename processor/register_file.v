module register_file (
    read_reg_num1,
    read_reg_num2,
    write_reg,
    reg_write,
    reg1_content,
    reg2_content,
    write_content,
    clk,
    reset
);

  input wire [2:0] read_reg_num1;
  input wire [2:0] read_reg_num2;
  input wire [2:0] write_reg;
  input wire reg_write;
  output wire [7:0] reg1_content;
  output wire [7:0] reg2_content;
  input wire [7:0] write_content;
  input clk;
  input reset;
  reg [7:0] memory[7:0];
  //ground the address to return zero whenever r0 is accessed  
  assign read_data_a =
    (read_addr_a == 3'b000) ? 8'b0 : memory[read_addr_a];
  assign read_data_b =
    (read_addr_b == 3'b000) ? 8'b0 : memory[read_addr_b];
  always @(posedge clk or posedge reset) begin
      if (reset) begin
          for (i = 0; i < 8; i = i + 1) begin
              memory[i] <= 8'b00000000;
          end
      end
      else if (reg_write) begin
          memory[write_reg] <= write_content;
      end
  end


  end
endmodule
