module register_file (
    read_reg_num1,
    read_reg_num2,
    write_reg,
    reg_write_control,
    reg1_content,
    reg2_content,
    write_content,
    clk,
    reset
);

  input wire [2:0] read_reg_num1;
  input wire [2:0] read_reg_num2;
  input wire [2:0] write_reg;
  input wire reg_write_control;
  output wire [7:0] reg1_content;
  output wire [7:0] reg2_content;
  input wire [7:0] write_content;
  input clk;
  input reset;
  reg [7:0] memory[7:0];
  always @(posedge reset) begin
    memory[0] = 8'o0;
    memory[1] = 8'o0;
    memory[2] = 8'o0;
    memory[3] = 8'o0;
    memory[4] = 8'o0;
    memory[5] = 8'o0;
    memory[6] = 8'o0;
    memory[7] = 8'o0;
  end
  assign reg1_content = memory[read_reg_num1];
  assign reg2_content = memory[read_reg_num2];
  always @(posedge clk) begin
    if (reg_write_control) begin
      memory[write_reg] = write_content;
    end


  end
endmodule
