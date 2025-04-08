//############################################################################
//
//   Author      : Jus7in (justinh5567@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TESTBED_top.v
//   Module Name : TESTBED_top
//   Release version : v4.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps

`include "./pattern/PATTERN_top.v"
`include "./src/top.v"
`include "./src/define.v"
module TESTBED_top();

wire clk, rst_n, in_valid, out_valid;
wire [4:0]m, n, k;

top U_top(
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .m(m),
    .n(n),
    .k(k),
    .out_valid(out_valid)
);

PATTERN_top U_PATTERN_top(
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .m(m),
    .n(n),
    .k(k),
    .out_valid(out_valid)
);

integer i;
initial begin
    $dumpfile("./vcd/top.vcd"); // Name your VCD file
    $dumpvars(0, TESTBED_top); // Dump signals starting at time 0
    // for(i=0;i<1024;i=i+1)begin
    //     $dumpvars(0, U_top.TPU.mult_pe[i]);	
    // end
end



  
endmodule