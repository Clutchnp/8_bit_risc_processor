//currently the contorl units gives a 4 bit alu control that needs to be fixed
module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] alu_control,
    output reg  [7:0] result,
    output wire       zero
);

    always @(*) begin
        case (op)
            3'b0000: result = a + b;
            3'b0001: result = a - b;
            3'b0010: result = a & b;
            3'b0011: result = a | b;
            3'b0100: result = a ^ b;
            3'b0101: result = ~a;
            3'b0110: result = a << 1;
            3'b0111: result = a >> 1;
            3'b1000: result = ~(a & b);
            3'b1001: result = ~(a^b);
            default: result = 8'b0;
        endcase
    end

    assign zero = (result == 8'b0);

endmodule
