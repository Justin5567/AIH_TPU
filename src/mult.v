`include "src/define.v"
module mult(a,
            b,
            out);


input [15:0] a;
input [15:0] b;
output reg [31:0] out;

always@(*)begin
    out = a*b;
end


endmodule