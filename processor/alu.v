module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] alu_control,
    output reg  [7:0] result,
    output wire       zero
);

    always @(*) begin
        case (alu_control)
            3'b000: result = a + b;
            3'b001: result = a - b;
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            3'b101: result = ~a;
            3'b110: result = a << b[2:0];
            3'b111: result = a >> b[2:0];
            default: result = 8'b0;
        endcase
    end

    assign zero = (result == 8'b0);

endmodule
