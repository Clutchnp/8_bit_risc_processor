
module cpu (
    input wire clk,
    input wire reset
);

  // ==================================================
  // 1. PROGRAM COUNTER (PC)
  // ==================================================

  reg  [ 7:0] pc;
  wire [ 7:0] next_pc;

  // ==================================================
  // 2. INSTRUCTION MEMORY
  // ==================================================

  wire [15:0] instruction;

  instruction_memory imem (
      .address(pc),
      .instruction(instruction)
  );

  // ==================================================
  // 3. INSTRUCTION FIELDS
  // ==================================================

  wire [3:0] opcode;
  wire [2:0] rd;
  wire [2:0] rs1;
  wire [2:0] rs2;
  wire [2:0] funct;

  assign opcode = instruction[15:12];
  assign rd     = instruction[11:9];
  assign rs1    = instruction[8:6];
  assign rs2    = instruction[5:3];
  assign funct  = instruction[2:0];

  // Immediate extraction
  wire [5:0] imm6;
  wire [7:0] imm_sign_ext;
  wire [7:0] imm_zero_ext;
  wire [7:0] immediate;

  assign imm6 = instruction[5:0];
  assign imm_sign_ext = {{2{imm6[5]}}, imm6};
  assign imm_zero_ext = {2'b00, imm6};

  // Logical immediates (ANDI, ORI, XORI) are zero-extended;
  // Arithmetic/memory immediates (ADDI, LD, ST) are sign-extended.
  wire is_logical_imm;
  assign is_logical_imm = (opcode == 4'b1001) || (opcode == 4'b1010) || (opcode == 4'b1011);
  assign immediate      = is_logical_imm ? imm_zero_ext : imm_sign_ext;

  // ==================================================
  // 4. CONTROL UNIT
  // ==================================================

  wire       reg_write;
  wire       alu_src;
  wire       mem_read;
  wire       mem_write;
  wire [1:0] result_src;
  wire [2:0] alu_control;
  wire       branch_eq;
  wire       branch_ne;
  wire       jump;
  wire       halt;

  control_unit cu (
      .opcode(opcode),
      .funct(funct),
      .reg_write(reg_write),
      .alu_src(alu_src),
      .mem_read(mem_read),
      .mem_write(mem_write),
      .result_src(result_src),
      .alu_control(alu_control),
      .branch_eq(branch_eq),
      .branch_ne(branch_ne),
      .jump(jump),
      .halt(halt)
  );

  // ==================================================
  // 5. REGISTER FILE
  // ==================================================

  wire [7:0] read_data_a;
  wire [7:0] read_data_b;
  wire [7:0] write_content;
  wire [2:0] reg_read_addr_b;

  // For store instructions (ST), the register holding data to store is rd
  assign reg_read_addr_b = mem_write ? rd : rs2;

  register_file rf (
      .clk(clk),
      .reset(reset),
      .reg_write(reg_write),
      .read_addr_a(rs1),
      .read_addr_b(reg_read_addr_b),
      .write_reg(rd),
      .write_content(write_content),
      .read_data_a(read_data_a),
      .read_data_b(read_data_b)
  );

  // ==================================================
  // 6. ALU INPUT MUX
  // ==================================================

  wire [7:0] alu_b;
  wire [7:0] alu_result;
  wire zero;
  assign alu_b = alu_src ? immediate : read_data_b;

  // ==================================================
  // 7. ALU
  // ==================================================

  alu alu_unit (
      .a(read_data_a),
      .b(alu_b),
      .alu_control(alu_control),
      .result(alu_result),
      .zero(zero)
  );

  // ==================================================
  // 8. DATA MEMORY
  // ==================================================

  wire [7:0] mem_data;

  data_memory dmem (
      .clk(clk),
      .address(alu_result),
      .write_data(read_data_b),
      .mem_read(mem_read),
      .mem_write(mem_write),
      .read_data(mem_data)
  );

  // ==================================================
  // 9. WRITE-BACK MUX
  // result_src:
  // 00 = ALU result
  // 01 = memory data
  // 10 = immediate
  // ==================================================

  assign write_content =
        (result_src == 2'b00) ? alu_result :
        (result_src == 2'b01) ? mem_data   :
        (result_src == 2'b10) ? immediate  :
                                8'b0;

  // ==================================================
  // 10. BRANCH DECISION & NEXT PC
  // ==================================================

  wire take_branch;
  wire [7:0] pc_plus_one;
  wire [7:0] jump_target;

  assign take_branch = (branch_eq && zero) || (branch_ne && !zero);
  assign pc_plus_one = pc + 8'd1;
  assign jump_target = instruction[7:0];

  assign next_pc = jump        ? jump_target :
                   take_branch ? pc_plus_one + imm_sign_ext :
                                 pc_plus_one;

  always @(posedge clk or posedge reset) begin
    if (reset) pc <= 8'b0;
    else if (!halt) pc <= next_pc;
  end

endmodule
