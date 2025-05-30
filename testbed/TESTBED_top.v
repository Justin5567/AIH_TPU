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
`include "./src/define.v"
`ifdef RTL
    `include "./src/top.v"
`endif
`ifdef IVERILOG
    `include "./src/top.v"
`endif
`ifdef GATE
    `include "./synthesis/top_syn.v"
`endif

module TESTBED_top();

wire clk, rst_n, in_valid, out_valid;
wire [4:0]m, n, k;
wire [255:0] gbuff_a,gbuff_b,gbuff_out;
top U_top(
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .gbuff_a(gbuff_a),
    .gbuff_b(gbuff_b),
    .m(m),
    .n(n),
    .k(k),
    .gbuff_out(gbuff_out),
    .out_valid(out_valid)
);

PATTERN_top U_PATTERN_top(
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .gbuff_a(gbuff_a),
    .gbuff_b(gbuff_b),
    .m(m),
    .n(n),
    .k(k),
    .gbuff_out(gbuff_out),
    .out_valid(out_valid)
);

integer i;
`ifdef FSDB
initial begin

    `ifdef RTL
        $fsdbDumpfile("top.fsdb");
        $fsdbDumpvars;
        $fsdbDumpMDA;
    `endif
    
    `ifdef GATE
        $sdf_annotate("top_syn.sdf", u_ESCAPE);
        $fsdbDumpfile("top_syn.fsdb");
        $fsdbDumpvars(0,"+mda"); 
    `endif
    `ifdef IVERILOG
        $dumpfile("./vcd/top.vcd"); // Name your VCD file
        $dumpvars(0, TESTBED_top); // Dump signals starting at time 0
    `endif
    //$fsdbDumpfile("top.fsdb");
    //$fsdbDumpvars(0, top);
    //$dumpfile("./vcd/top.vcd"); // Name your VCD file
    //$dumpvars(0, TESTBED_top); // Dump signals starting at time 0
    // for(i=0;i<1024;i=i+1)begin
    //     $dumpvars(0, U_top.TPU.mult_pe[i]);	
    // end
end
`endif

endmodule