module alu (overflow,alu_out,zero,src_a,src_b,opcode,reset,clk) ;

output  reg overflow;
output  reg zero ;
output  reg [3:0]alu_out ;
input[3:0] src_a,src_b;
input[2:0]opcode ;
input reset,clk;

always @(*) begin
    case(opcode)
      3'b000:alu_out  = 4'b0000;
      3'b001:alu_out  = (src_a & src_b);
      3'b010:alu_out  = (src_a |src_b);
      3'b011:alu_out  = src_a;
      3'b100:alu_out  = src_a+src_b;
      3'b101:alu_out  = src_a-src_b;
      3'b110:alu_out  = src_a>>src_b;
      3'b111:alu_out= src_a<<src_b;
      default:alu_out=4'b0000;
    endcase
end

always@(*)begin
  zero=~(|alu_out);
  end
  
always@(*)begin
  case(opcode)
    3'b100: overflow=((src_a[3]^alu_out[3])&(src_b[3]^alu_out[3]))?1'b1:1'b0;
    3'b101: overflow=((src_a[3]^alu_out[3])&~(src_b[3]^alu_out[3]))?1'b1:1'b0;
    default overflow=1'b0;
  endcase
end

endmodule

