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
`define CYCLE_TIME 15
`define End_CYCLE  100000000

module PATTERN_top(
	clk,
	rst_n,
	in_valid,
    gbuff_a,
    gbuff_b,
    gbuff_out,
    out_valid
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
output reg clk;
output reg rst_n;
output reg in_valid;

output reg [`GBUFF_IN_LINE_SIZE-1:0]gbuff_a,gbuff_b;

input out_valid;
input [`GBUFF_OUT_LINE_SIZE-1:0]gbuff_out;
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

reg [`GBUFF_IN_LINE_SIZE-1:0]     gbuff_a_reg [`GBUFF_IN_ADDR_SIZE-1:0];
reg [`GBUFF_IN_LINE_SIZE-1:0]     gbuff_b_reg [`GBUFF_IN_ADDR_SIZE-1:0];
reg [`GBUFF_OUT_LINE_SIZE-1:0]    GOLDEN      [`GBUFF_OUT_ADDR_SIZE-1:0];


real MRED_total;
real MRED;
integer clock_count;
// ===============================================================
// Wire & Reg Declaration
// ===============================================================

// ===============================================================
// Clock
// ===============================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;

always@(posedge clk)begin
    clock_count = clock_count +1;
end

// ===============================================================
// Initial
// ===============================================================
initial begin
	rst_n    = 1'b1;
	in_valid = 1'b0;
    
    // reset
	force clk = 0;
	reset_task;
    clock_count = 0;
    err = 0;
    MRED_total = 0;
    $readmemb("./build/matrix_a.bin", gbuff_a_reg);
    $readmemb("./build/matrix_b.bin", gbuff_b_reg);
    $readmemb("./build/golden.bin", GOLDEN); 
	@(negedge clk);
	for (patcount=0;patcount<PATNUM;patcount=patcount+1) begin		
		$display("\033[1;44mStart Pattern %02d\033[0;1m\n\033[0;33m[Input Data]\033[0;0m",patcount);
        input_task;
        wait_out_valid_task;
		$display();
		check_answer;
		@(negedge clk);
	end
	#(1);
    $display("[Total Cycle] %5d",clock_count);
    MRED = MRED_total/1024;
    // $display("MRED_total: %f",MRED_total);
    $display("MRED: %f",MRED);
    check_err;
    
	$display("\033[1;32m\033[5m[Pass] Congradulation You Pass All of the Testcases!!!\033[0;1m");
	$finish;
end 

// ===============================================================
// TASK
// ===============================================================
task input_task; begin
    in_valid = 1'b1;
    for(i = 0; i<32; i=i+1)begin
        gbuff_a = gbuff_a_reg[i];
        gbuff_b = gbuff_b_reg[i];
        @(negedge clk);
    end
    gbuff_a = 'bx;
    gbuff_b = 'bx;
    in_valid = 1'b0;
end endtask

integer sel0;
reg [`GBUFF_OUT_DATA_SIZE-1:0] golden_byte, out_byte;
real tmp_g,tmp_o;
task check_answer ; begin
    // #(10);
    for (i = 0; i < 32; i=i+1) begin
        for( j = 0 ; j < 32; j=j+1)begin
            sel0 = 1184-37*(j+1);
            golden_byte = GOLDEN[i] >> sel0;
            out_byte    = gbuff_out >> sel0;
            tmp_g = golden_byte;
            tmp_o = out_byte;
            if(golden_byte!=out_byte || out_byte ===37'bx)begin
                $display ("----------------------------------------------------------------------------------------------------------------------");
                $display ("                                                Error at [%2d,%2d]!                            						 ",i,j);
                $display ("                                                Your Answer:    %3d, %8b                                          ",out_byte,out_byte);
                $display ("                                                Correct Answer: %3d, %8b                                          ",golden_byte,golden_byte);
                $display ("                                                ABS: %d                                          ",abs(tmp_g-tmp_o));
                $display ("----------------------------------------------------------------------------------------------------------------------");
                // repeat(1)  @(negedge clk);
                // $finish;
                err = err + 1;
                MRED_total = MRED_total+ ((abs(golden_byte-out_byte))/tmp_g);
            end
            else begin
                // $write("%37b, ",out_byte);
            end
        
            
        end
    //    $display();
        @(negedge clk);
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


function integer abs;
  input integer val;
  begin
    if (val < 0)
      abs = -val;
    else
      abs = val;
  end
endfunction

endmodule


