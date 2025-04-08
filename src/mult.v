`include "src/define.v"
module mult(a,
            b,
            out);


input [`DATA_SIZE-1:0] a;
input [`DATA_SIZE-1:0] b;
output reg [`DATA_SIZE-1:0] out;

always@(*)begin
    out = a*b;
end


endmodule