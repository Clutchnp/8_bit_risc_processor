
module control_unit (
    input  wire [3:0] opcode,
    input  wire [2:0] funct,

    output reg        reg_write,
    output reg        alu_src,
    output reg        mem_read,
    output reg        mem_write,
    output reg  [1:0] result_src,
    output reg  [3:0] alu_control,
    output reg        branch_eq,
    output reg        branch_ne,
    output reg        jump
);

    always @(*) begin
        reg_write   = 1'b0;
        alu_src     = 1'b0; // decides weather to use the register or the immediate value as the second operand 
        mem_read    = 1'b0; //decides weather to read the memory the data memory will return 0
        mem_write   = 1'b0; //same as above just for writing
        result_src  = 2'b00; // where does the result comes from memory / alu out or another register
        alu_control = 4'b0000; // which function will alu get
        branch_eq   = 1'b0; //dont unserstand how will branching work regarding to jump instructions tbh
        branch_ne   = 1'b0;
        jump        = 1'b0;

        case (opcode)

            4'b0000: begin // R-ALU
                reg_write   = 1'b1;
                alu_control = {1'b0, funct};
            end

            4'b0001: begin // ADDI
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                alu_control = 4'b0000; // ADD
            end

            4'b0010: begin // LDI // I dont think we actually need it because I will be hardwiring r0 to 0 so we this can be done by just ADDI
                reg_write  = 1'b1;
                result_src = 2'b10;
            end

            4'b0011: begin // LD
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                mem_read    = 1'b1;
                result_src  = 2'b01;
                alu_control = 4'b0000; // ADD address + offset
            end

            4'b0100: begin // ST
                alu_src     = 1'b1;
                mem_write   = 1'b1;
                alu_control = 4'b0000; // ADD address + offset
            end

            4'b0101: begin // BEQ
                branch_eq   = 1'b1;
                alu_control = 4'b0001; // SUB for comparison
            end

            4'b0110: begin // BNE
                branch_ne   = 1'b1;
                alu_control = 4'b0001; // SUB for comparison
            end

            4'b0111: begin // JMP
                jump = 1'b1;
            end

            4'b1000: begin // SHLI
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                alu_control = 4'b1000;
            end

            4'b1001: begin // SHRI
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                alu_control = 4'b1001;
            end

            4'b1010: begin // ANDI
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                alu_control = 4'b0010;
            end

            4'b1011: begin // ORI
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                alu_control = 4'b0011;
            end

            4'b1100: begin // XORI
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                alu_control = 4'b0100;
            end

            default: begin 
                //rest are reserved for now
            end

        endcase
    end

endmodule
