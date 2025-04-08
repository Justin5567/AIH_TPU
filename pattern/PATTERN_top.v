//############################################################################
//
//   Author      : Jus7in (justinh5567@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : PATTERN_top.v
//   Module Name : PATTERN_top
//   Release version : v1.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`include "./src/define.v"
`timescale 1ns/10ps
`define CYCLE_TIME 10
`define End_CYCLE  100000000

module PATTERN_top(
	clk,
	rst_n,
	in_valid,
	m,
    n,
    k,
    out_valid
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
output reg clk;
output reg rst_n;
output reg in_valid;
output reg [4:0] m;
output reg [4:0] n;
output reg [4:0] k;

input out_valid;

// ===============================================================
// Parameters & Integer Declaration
// ===============================================================
integer golden_read;
integer patcount,output_count;
integer gap;
integer a;
integer i, j;
integer err;
integer cycles;
parameter PATNUM = 1; // change after
reg [`WORD_SIZE-1:0] GOLDEN [`GBUFF_ADDR_SIZE-1:0];
// reg [`WORD_SIZE-1:0] GBUFF [`GBUFF_ADDR_SIZE-1:0];
// ===============================================================
// Wire & Reg Declaration
// ===============================================================

// ===============================================================
// Clock
// ===============================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;

// ===============================================================
// Initial
// ===============================================================
initial begin
	rst_n    = 1'b1;
	in_valid = 1'b0;

    // reset
	force clk = 0;
	reset_task;

    err = 0;
    $readmemb("./build/matrix_a.bin", TESTBED_top.U_top.GBUFF_A.gbuff);
    $readmemb("./build/matrix_b.bin", TESTBED_top.U_top.GBUFF_B.gbuff);
    $readmemb("./build/golden.bin", GOLDEN); 
	// for (i = 0; i < 32; i=i+1) begin
    //  $display("%d: %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b", i,
    //    GOLDEN[i][7:0], GOLDEN[i][15:8], GOLDEN[i][23:16], GOLDEN[i][31:24],
    //    GOLDEN[i][39:32], GOLDEN[i][47:40], GOLDEN[i][55:48], GOLDEN[i][63:56],
    //    GOLDEN[i][71:64], GOLDEN[i][79:72], GOLDEN[i][87:80], GOLDEN[i][95:88],
    //    GOLDEN[i][103:96], GOLDEN[i][111:104], GOLDEN[i][119:112], GOLDEN[i][127:120],
    //    GOLDEN[i][135:128], GOLDEN[i][143:136], GOLDEN[i][151:144], GOLDEN[i][159:152],
    //    GOLDEN[i][167:160], GOLDEN[i][175:168], GOLDEN[i][183:176], GOLDEN[i][191:184],
    //    GOLDEN[i][199:192], GOLDEN[i][207:200], GOLDEN[i][215:208], GOLDEN[i][223:216],
    //    GOLDEN[i][231:224], GOLDEN[i][239:232], GOLDEN[i][247:240], GOLDEN[i][255:248]);
    // end
	@(negedge clk);
	for (patcount=0;patcount<PATNUM;patcount=patcount+1) begin		
		$display("\033[1;44mStart Pattern %02d\033[0;1m\n\033[0;33m[Input Data]\033[0;0m",patcount);
        in_valid = 1'b1;
        @(negedge clk);
        in_valid = 1'b0;
        wait_out_valid_task;
		$display();
		check_answer;
        // for (i = 0; i < 32; i=i+1) begin
        //     $display("%d: %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", i,
        //     TESTBED_top.U_top.GBUFF_OUT.gbuff[i][7:0], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][15:8], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][23:16], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][31:24],
        //     TESTBED_top.U_top.GBUFF_OUT.gbuff[i][39:32], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][47:40], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][55:48], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][63:56],
        //     TESTBED_top.U_top.GBUFF_OUT.gbuff[i][71:64], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][79:72], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][87:80], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][95:88],
        //     TESTBED_top.U_top.GBUFF_OUT.gbuff[i][103:96], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][111:104], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][119:112], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][127:120],
        //     TESTBED_top.U_top.GBUFF_OUT.gbuff[i][135:128], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][143:136], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][151:144], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][159:152],
        //     TESTBED_top.U_top.GBUFF_OUT.gbuff[i][167:160], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][175:168], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][183:176], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][191:184],
        //     TESTBED_top.U_top.GBUFF_OUT.gbuff[i][199:192], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][207:200], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][215:208], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][223:216],
        //     TESTBED_top.U_top.GBUFF_OUT.gbuff[i][231:224], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][239:232], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][247:240], TESTBED_top.U_top.GBUFF_OUT.gbuff[i][255:248]);
        // end
		@(negedge clk);
	end
	#(1);

    check_err;
	$display("\033[1;32m\033[5m[Pass] Congradulation You Pass All of the Testcases!!!\033[0;1m");
	$finish;
end 

// ===============================================================
// TASK
// ===============================================================
integer sel0;
reg [7:0] golden_byte, out_byte;
task check_answer ; begin
    #(10);
    for (i = 0; i < 32; i=i+1) begin
        for( j = 0 ; j < 32; j=j+1)begin
            sel0 = 256-8*(j+1);
            golden_byte = GOLDEN[i] >> sel0;
            out_byte    = TESTBED_top.U_top.GBUFF_OUT.gbuff[i] >> sel0;
            if(golden_byte!=out_byte)begin
                $display ("----------------------------------------------------------------------------------------------------------------------");
                $display ("                                                Error at [%2d,%2d]!                            						 ",i,j);
                $display ("                                                Your Answer:    %3d, %8b                                          ",out_byte,out_byte);
                $display ("                                                Correct Answer: %3d, %8b                                          ",golden_byte,golden_byte);
                $display ("----------------------------------------------------------------------------------------------------------------------");
                repeat(1)  @(negedge clk);
                $finish;
                err = err + 1;
            end
            else begin
                $write("%2d, ",out_byte);
            end

            
        end
        $display();
    end
end endtask

task wait_out_valid_task ; begin
    cycles = 0;
    while(out_valid!==1)begin
        cycles = cycles+1;
        if(cycles==3000)begin
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                            Exceed maximun cycle!!!                                                         ");
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            repeat(5) @(negedge clk);
            $finish;
        end
        @(negedge clk);
    end
end endtask

task reset_task ; begin
	#(20); rst_n = 0;
	#(20);
	if((out_valid !== 0)) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                  Output signal should be 0 after initial RESET at %8t                                      ",$time);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		#(100);
	    $finish ;
	end
	#(20); rst_n = 1 ;
	#(6.0); release clk;
end endtask

task check_err; begin

    if( err == 0 )begin
            $display("\n");
            $display("                                             / \\  //\\                      ");
            $display("                              |\\___/|      /   \\//  \\\\                   ");
            $display("                             /0  0  \\__  /    //  | \\ \\                   ");
            $display("                            /     /  \\/_/    //   |  \\  \\                 ");
            $display("                            @_^_@'/   \\/_   //    |   \\   \\               ");
            $display("                            //_^_/     \\/_ //     |    \\    \\             ");
            $display("                         ( //) |        \\///      |     \\     \\           ");
            $display("                        ( / /) _|_ /   )  //       |      \\     _\\         ");
            $display("                      ( // /) '/,_ _ _/  ( ; -.    |    _ _\\.-~        .-~~~^-.                      ");
            $display(" ********************(( / / )) ,-{        _      `-.|.-~-.            .~         `.                   ");
            $display(" **                   (( // / ))  '/\\      /                 ~-. _ .-~      .-~^-.  \                ");
            $display(" **  Congratulations!  (( /// ))      `.   {            }                    /      \  \              ");
            $display(" **  Simulation Passed!  (( / ))     .----~-.\\        \\-'                .~         \  `. \^-.      ");
            $display(" **                      **           ///.----..>        \\             _ -~             `.  ^-`  ^-_ ");
            $display(" **************************             ///-._ _ _ _ _ _ _}^ - - - -- ~                     ~-- ,.-~  ");
            $display("\n");
    end
    else begin
            $display("\n");
            $display(" **************************    __ __   ");
            $display(" **                      **   /--\\/ \\ ");
            $display(" **  Awwwww              **  |   /   | ");
            $display(" **  Simulation Failed!  **  |-    --| ");
            $display(" **                      **   \\__-*_/ ");
            $display(" **************************            ");
            $display(" Total %4d errors\n", err);
    end
end endtask

endmodule