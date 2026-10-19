
module cpu (
    input wire clk,
    input wire reset
);

    // ==================================================
    // 1. PROGRAM COUNTER (PC)
    // ==================================================

    reg  [7:0] pc;
    wire [7:0] next_pc;

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
    // ASSUMED FORMAT -- finalize bit positions later!
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

    // Example immediate extraction.
    // This 6-bit field is only an assumption.
    wire [5:0] imm6;
    wire [7:0] immediate;

    assign imm6 = instruction[5:0];

    // Zero-extend the immediate to 8 bits.
    assign immediate = {2'b00, imm6};

    // ==================================================
    // 4. CONTROL UNIT
    // ==================================================

    wire       reg_write;
    wire       alu_src;
    wire       mem_read;
    wire       mem_write;
    wire [1:0] result_src;
    wire [3:0] alu_control;
    wire       branch_eq;
    wire       branch_ne;
    wire       jump;

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
        .jump(jump)
    );

    // ==================================================
    // 5. REGISTER FILE
    // ==================================================

    wire [7:0] read_data_a;
    wire [7:0] read_data_b;
    wire [7:0] write_content;

    register_file rf (
        .clk(clk),
        .reset(reset),
        .reg_write_control(reg_write),
        .read_addr_a(rs1),
        .read_addr_b(rs2),
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

    assign alu_b = alu_src ? immediate : read_data_b;

    // ==================================================
    // 7. ALU
    // ==================================================

    alu alu_unit (
        .A(read_data_a),
        .B(alu_b),
        .alu_control(alu_control),
        .result(alu_result)
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
    // 10. BRANCH DECISION
    // ==================================================

    wire equal;
    wire take_branch;

    assign equal = (read_data_a == read_data_b);

    assign take_branch =
        (branch_eq && equal) ||
        (branch_ne && !equal);

    // Assumed: branch target = PC + 1 + immediate.
    // Immediate must be properly sign-extended if
    // negative branch offsets are supported.
    wire [7:0] pc_plus_one;

    assign pc_plus_one = pc + 8'd1;

    assign next_pc =
        jump        ? immediate :
        take_branch ? pc_plus_one + immediate :
                      pc_plus_one;


    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 8'b0;
        else
            pc <= next_pc;
    end

endmodule