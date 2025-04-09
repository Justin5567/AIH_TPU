//############################################################################
//
//   Author      : Jus7in (justinh5567@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TPU.v
//   Module Name : TPU
//   Release version : v1.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`include "src/define.v"
`include "src/mult.v"
`include "src/GATED_OR.v"
module tpu(
	clk,
	rst_n,
	in_valid,
    out_ready,
	a,
    b,
    out,
    in_ready,
    out_valid,
    done
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;
input rst_n;
input in_valid;
input out_ready;
input [`WORD_SIZE-1:0] a;
input [`WORD_SIZE-1:0] b;
output reg [`WORD_SIZE-1:0] out;
output reg in_ready;
output reg out_valid;
output reg done;

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================

// parameter
parameter IDLE  = 4'd0;
parameter OP    = 4'd2;
parameter IDLE3 = 4'd3;
parameter WR    = 4'd4;
parameter DONE  = 4'd5;

// reg
reg [3:0] state_cs, state_ns;



reg [9:0] counter;



reg [`DATA_SIZE-1:0]mult_a [`PE_SIZE-1:0];
reg [`DATA_SIZE-1:0]mult_b [`PE_SIZE-1:0];
wire [`DATA_SIZE-1:0]mult_out [`PE_SIZE-1:0];
reg [`DATA_SIZE-1:0]mult_pe [`PE_SIZE-1:0];
// wire
wire start;
wire RD_done;
wire OP_done;
wire WR_done;

wire [`DATA_SIZE-1:0]side_buffer_a_w[0:31];
wire [`DATA_SIZE-1:0]side_buffer_b_w[0:31];

reg [`DATA_SIZE-1:0]side_buffer_a_w0   ;
reg [`DATA_SIZE-1:0]side_buffer_a_w1   [0: 1];
reg [`DATA_SIZE-1:0]side_buffer_a_w2   [0: 2];
reg [`DATA_SIZE-1:0]side_buffer_a_w3   [0: 3];
reg [`DATA_SIZE-1:0]side_buffer_a_w4   [0: 4];
reg [`DATA_SIZE-1:0]side_buffer_a_w5   [0: 5];
reg [`DATA_SIZE-1:0]side_buffer_a_w6   [0: 6];
reg [`DATA_SIZE-1:0]side_buffer_a_w7   [0: 7];
reg [`DATA_SIZE-1:0]side_buffer_a_w8   [0: 8];
reg [`DATA_SIZE-1:0]side_buffer_a_w9   [0: 9];
reg [`DATA_SIZE-1:0]side_buffer_a_w10  [0:10];
reg [`DATA_SIZE-1:0]side_buffer_a_w11  [0:11];
reg [`DATA_SIZE-1:0]side_buffer_a_w12  [0:12];
reg [`DATA_SIZE-1:0]side_buffer_a_w13  [0:13];
reg [`DATA_SIZE-1:0]side_buffer_a_w14  [0:14];
reg [`DATA_SIZE-1:0]side_buffer_a_w15  [0:15];
reg [`DATA_SIZE-1:0]side_buffer_a_w16  [0:16];
reg [`DATA_SIZE-1:0]side_buffer_a_w17  [0:17];
reg [`DATA_SIZE-1:0]side_buffer_a_w18  [0:18];
reg [`DATA_SIZE-1:0]side_buffer_a_w19  [0:19];
reg [`DATA_SIZE-1:0]side_buffer_a_w20  [0:20];
reg [`DATA_SIZE-1:0]side_buffer_a_w21  [0:21];
reg [`DATA_SIZE-1:0]side_buffer_a_w22  [0:22];
reg [`DATA_SIZE-1:0]side_buffer_a_w23  [0:23];
reg [`DATA_SIZE-1:0]side_buffer_a_w24  [0:24];
reg [`DATA_SIZE-1:0]side_buffer_a_w25  [0:25];
reg [`DATA_SIZE-1:0]side_buffer_a_w26  [0:26];
reg [`DATA_SIZE-1:0]side_buffer_a_w27  [0:27];
reg [`DATA_SIZE-1:0]side_buffer_a_w28  [0:28];
reg [`DATA_SIZE-1:0]side_buffer_a_w29  [0:29];
reg [`DATA_SIZE-1:0]side_buffer_a_w30  [0:30];
reg [`DATA_SIZE-1:0]side_buffer_a_w31  [0:31];

reg [`DATA_SIZE-1:0]side_buffer_b_w0   ;
reg [`DATA_SIZE-1:0]side_buffer_b_w1   [0: 1];
reg [`DATA_SIZE-1:0]side_buffer_b_w2   [0: 2];
reg [`DATA_SIZE-1:0]side_buffer_b_w3   [0: 3];
reg [`DATA_SIZE-1:0]side_buffer_b_w4   [0: 4];
reg [`DATA_SIZE-1:0]side_buffer_b_w5   [0: 5];
reg [`DATA_SIZE-1:0]side_buffer_b_w6   [0: 6];
reg [`DATA_SIZE-1:0]side_buffer_b_w7   [0: 7];
reg [`DATA_SIZE-1:0]side_buffer_b_w8   [0: 8];
reg [`DATA_SIZE-1:0]side_buffer_b_w9   [0: 9];
reg [`DATA_SIZE-1:0]side_buffer_b_w10  [0:10];
reg [`DATA_SIZE-1:0]side_buffer_b_w11  [0:11];
reg [`DATA_SIZE-1:0]side_buffer_b_w12  [0:12];
reg [`DATA_SIZE-1:0]side_buffer_b_w13  [0:13];
reg [`DATA_SIZE-1:0]side_buffer_b_w14  [0:14];
reg [`DATA_SIZE-1:0]side_buffer_b_w15  [0:15];
reg [`DATA_SIZE-1:0]side_buffer_b_w16  [0:16];
reg [`DATA_SIZE-1:0]side_buffer_b_w17  [0:17];
reg [`DATA_SIZE-1:0]side_buffer_b_w18  [0:18];
reg [`DATA_SIZE-1:0]side_buffer_b_w19  [0:19];
reg [`DATA_SIZE-1:0]side_buffer_b_w20  [0:20];
reg [`DATA_SIZE-1:0]side_buffer_b_w21  [0:21];
reg [`DATA_SIZE-1:0]side_buffer_b_w22  [0:22];
reg [`DATA_SIZE-1:0]side_buffer_b_w23  [0:23];
reg [`DATA_SIZE-1:0]side_buffer_b_w24  [0:24];
reg [`DATA_SIZE-1:0]side_buffer_b_w25  [0:25];
reg [`DATA_SIZE-1:0]side_buffer_b_w26  [0:26];
reg [`DATA_SIZE-1:0]side_buffer_b_w27  [0:27];
reg [`DATA_SIZE-1:0]side_buffer_b_w28  [0:28];
reg [`DATA_SIZE-1:0]side_buffer_b_w29  [0:29];
reg [`DATA_SIZE-1:0]side_buffer_b_w30  [0:30];
reg [`DATA_SIZE-1:0]side_buffer_b_w31  [0:31];


wire cg_clk[0:`PE_SIZE-1];
reg  cg_pe [0:`PE_SIZE-1];

// memory
integer i,j;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        side_buffer_a_w0 <=0;
        for(i=0;i<2;i=i+1)begin
            side_buffer_a_w1[i] <=0;
        end
        for(i=0;i<3;i=i+1)begin
            side_buffer_a_w2[i] <=0;
        end
        for(i=0;i<4;i=i+1)begin
            side_buffer_a_w3[i] <=0;
        end
        for(i=0;i<5;i=i+1)begin
            side_buffer_a_w4[i] <=0;
        end
        for(i=0;i<6;i=i+1)begin
            side_buffer_a_w5[i] <=0;
        end
        for(i=0;i<7;i=i+1)begin
            side_buffer_a_w6[i] <=0;
        end
        for(i=0;i<8;i=i+1)begin
            side_buffer_a_w7[i] <=0;
        end
        for(i=0;i<9;i=i+1)begin
            side_buffer_a_w8[i] <=0;
        end
        for(i=0;i<10;i=i+1)begin
            side_buffer_a_w9[i] <=0;
        end
        for(i=0;i<11;i=i+1)begin
            side_buffer_a_w10[i] <=0;
        end
        for(i=0;i<12;i=i+1)begin
            side_buffer_a_w11[i] <=0;
        end
        for(i=0;i<13;i=i+1)begin
            side_buffer_a_w12[i] <=0;
        end
        for(i=0;i<14;i=i+1)begin
            side_buffer_a_w13[i] <=0;
        end
        for(i=0;i<15;i=i+1)begin
            side_buffer_a_w14[i] <=0;
        end
        for(i=0;i<16;i=i+1)begin
            side_buffer_a_w15[i] <=0;
        end
        for(i=0;i<17;i=i+1)begin
            side_buffer_a_w16[i] <=0;
        end
        for(i=0;i<18;i=i+1)begin
            side_buffer_a_w17[i] <=0;
        end
        for(i=0;i<19;i=i+1)begin
            side_buffer_a_w18[i] <=0;
        end
        for(i=0;i<20;i=i+1)begin
            side_buffer_a_w19[i] <=0;
        end
        for(i=0;i<21;i=i+1)begin
            side_buffer_a_w20[i] <=0;
        end
        for(i=0;i<22;i=i+1)begin
            side_buffer_a_w21[i] <=0;
        end
        for(i=0;i<23;i=i+1)begin
            side_buffer_a_w22[i] <=0;
        end
        for(i=0;i<24;i=i+1)begin
            side_buffer_a_w23[i] <=0;
        end
        for(i=0;i<25;i=i+1)begin
            side_buffer_a_w24[i] <=0;
        end
        for(i=0;i<26;i=i+1)begin
            side_buffer_a_w25[i] <=0;
        end
        for(i=0;i<27;i=i+1)begin
            side_buffer_a_w26[i] <=0;
        end
        for(i=0;i<28;i=i+1)begin
            side_buffer_a_w27[i] <=0;
        end
        for(i=0;i<29;i=i+1)begin
            side_buffer_a_w28[i] <=0;
        end
        for(i=0;i<30;i=i+1)begin
            side_buffer_a_w29[i] <=0;
        end
        for(i=0;i<31;i=i+1)begin
            side_buffer_a_w30[i] <=0;
        end
        for(i=0;i<32;i=i+1)begin
            side_buffer_a_w31[i] <=0;
        end
    end
    else if(state_ns==IDLE)begin
        side_buffer_a_w0 <=0;
        for(i=0;i<2;i=i+1)begin
            side_buffer_a_w1[i] <=0;
        end
        for(i=0;i<3;i=i+1)begin
            side_buffer_a_w2[i] <=0;
        end
        for(i=0;i<4;i=i+1)begin
            side_buffer_a_w3[i] <=0;
        end
        for(i=0;i<5;i=i+1)begin
            side_buffer_a_w4[i] <=0;
        end
        for(i=0;i<6;i=i+1)begin
            side_buffer_a_w5[i] <=0;
        end
        for(i=0;i<7;i=i+1)begin
            side_buffer_a_w6[i] <=0;
        end
        for(i=0;i<8;i=i+1)begin
            side_buffer_a_w7[i] <=0;
        end
        for(i=0;i<9;i=i+1)begin
            side_buffer_a_w8[i] <=0;
        end
        for(i=0;i<10;i=i+1)begin
            side_buffer_a_w9[i] <=0;
        end
        for(i=0;i<11;i=i+1)begin
            side_buffer_a_w10[i] <=0;
        end
        for(i=0;i<12;i=i+1)begin
            side_buffer_a_w11[i] <=0;
        end
        for(i=0;i<13;i=i+1)begin
            side_buffer_a_w12[i] <=0;
        end
        for(i=0;i<14;i=i+1)begin
            side_buffer_a_w13[i] <=0;
        end
        for(i=0;i<15;i=i+1)begin
            side_buffer_a_w14[i] <=0;
        end
        for(i=0;i<16;i=i+1)begin
            side_buffer_a_w15[i] <=0;
        end
        for(i=0;i<17;i=i+1)begin
            side_buffer_a_w16[i] <=0;
        end
        for(i=0;i<18;i=i+1)begin
            side_buffer_a_w17[i] <=0;
        end
        for(i=0;i<19;i=i+1)begin
            side_buffer_a_w18[i] <=0;
        end
        for(i=0;i<20;i=i+1)begin
            side_buffer_a_w19[i] <=0;
        end
        for(i=0;i<21;i=i+1)begin
            side_buffer_a_w20[i] <=0;
        end
        for(i=0;i<22;i=i+1)begin
            side_buffer_a_w21[i] <=0;
        end
        for(i=0;i<23;i=i+1)begin
            side_buffer_a_w22[i] <=0;
        end
        for(i=0;i<24;i=i+1)begin
            side_buffer_a_w23[i] <=0;
        end
        for(i=0;i<25;i=i+1)begin
            side_buffer_a_w24[i] <=0;
        end
        for(i=0;i<26;i=i+1)begin
            side_buffer_a_w25[i] <=0;
        end
        for(i=0;i<27;i=i+1)begin
            side_buffer_a_w26[i] <=0;
        end
        for(i=0;i<28;i=i+1)begin
            side_buffer_a_w27[i] <=0;
        end
        for(i=0;i<29;i=i+1)begin
            side_buffer_a_w28[i] <=0;
        end
        for(i=0;i<30;i=i+1)begin
            side_buffer_a_w29[i] <=0;
        end
        for(i=0;i<31;i=i+1)begin
            side_buffer_a_w30[i] <=0;
        end
        for(i=0;i<32;i=i+1)begin
            side_buffer_a_w31[i] <=0;
        end
    end
     else if(state_ns==OP)begin
        side_buffer_a_w0         <= a[255:248];
        side_buffer_a_w1    [ 1] <= a[247:240];
        side_buffer_a_w2    [ 2] <= a[239:232];
        side_buffer_a_w3    [ 3] <= a[231:224];
        side_buffer_a_w4    [ 4] <= a[223:216];
        side_buffer_a_w5    [ 5] <= a[215:208];
        side_buffer_a_w6    [ 6] <= a[207:200];
        side_buffer_a_w7    [ 7] <= a[199:192];
        side_buffer_a_w8    [ 8] <= a[191:184];
        side_buffer_a_w9    [ 9] <= a[183:176];
        side_buffer_a_w10   [10] <= a[175:168];
        side_buffer_a_w11   [11] <= a[167:160];
        side_buffer_a_w12   [12] <= a[159:152];
        side_buffer_a_w13   [13] <= a[151:144];
        side_buffer_a_w14   [14] <= a[143:136];
        side_buffer_a_w15   [15] <= a[135:128];
        side_buffer_a_w16   [16] <= a[127:120];
        side_buffer_a_w17   [17] <= a[119:112];
        side_buffer_a_w18   [18] <= a[111:104];
        side_buffer_a_w19   [19] <= a[103: 96];
        side_buffer_a_w20   [20] <= a[ 95: 88];
        side_buffer_a_w21   [21] <= a[ 87: 80];
        side_buffer_a_w22   [22] <= a[ 79: 72];
        side_buffer_a_w23   [23] <= a[ 71: 64];
        side_buffer_a_w24   [24] <= a[ 63: 56];
        side_buffer_a_w25   [25] <= a[ 55: 48];
        side_buffer_a_w26   [26] <= a[ 47: 40];
        side_buffer_a_w27   [27] <= a[ 39: 32];
        side_buffer_a_w28   [28] <= a[ 31: 24];
        side_buffer_a_w29   [29] <= a[ 23: 16];
        side_buffer_a_w30   [30] <= a[ 15:  8];
        side_buffer_a_w31   [31] <= a[  7:  0];

        for(i=0;i<1;i=i+1)begin
            side_buffer_a_w1[i] <= side_buffer_a_w1[i+1];
        end
        for(i=0;i<2;i=i+1)begin
            side_buffer_a_w2[i] <= side_buffer_a_w2[i+1];
        end
        for(i=0;i<3;i=i+1)begin
            side_buffer_a_w3[i] <= side_buffer_a_w3[i+1];
        end
        for(i=0;i<4;i=i+1)begin
            side_buffer_a_w4[i] <= side_buffer_a_w4[i+1];
        end
        for(i=0;i<5;i=i+1)begin
            side_buffer_a_w5[i] <= side_buffer_a_w5[i+1];
        end
        for(i=0;i<6;i=i+1)begin
            side_buffer_a_w6[i] <= side_buffer_a_w6[i+1];
        end
        for(i=0;i<7;i=i+1)begin
            side_buffer_a_w7[i] <= side_buffer_a_w7[i+1];
        end
        for(i=0;i<8;i=i+1)begin
            side_buffer_a_w8[i] <= side_buffer_a_w8[i+1];
        end
        for(i=0;i<9;i=i+1)begin
            side_buffer_a_w9[i] <= side_buffer_a_w9[i+1];
        end
        for(i=0;i<10;i=i+1)begin
            side_buffer_a_w10[i] <= side_buffer_a_w10[i+1];
        end
        for(i=0;i<11;i=i+1)begin
            side_buffer_a_w11[i] <= side_buffer_a_w11[i+1];
        end
        for(i=0;i<12;i=i+1)begin
            side_buffer_a_w12[i] <= side_buffer_a_w12[i+1];
        end
        for(i=0;i<13;i=i+1)begin
            side_buffer_a_w13[i] <= side_buffer_a_w13[i+1];
        end
        for(i=0;i<14;i=i+1)begin
            side_buffer_a_w14[i] <= side_buffer_a_w14[i+1];
        end
        for(i=0;i<15;i=i+1)begin
            side_buffer_a_w15[i] <= side_buffer_a_w15[i+1];
        end
        for(i=0;i<16;i=i+1)begin
            side_buffer_a_w16[i] <= side_buffer_a_w16[i+1];
        end
        for(i=0;i<17;i=i+1)begin
            side_buffer_a_w17[i] <= side_buffer_a_w17[i+1];
        end
        for(i=0;i<18;i=i+1)begin
            side_buffer_a_w18[i] <= side_buffer_a_w18[i+1];
        end
        for(i=0;i<19;i=i+1)begin
            side_buffer_a_w19[i] <= side_buffer_a_w19[i+1];
        end
        for(i=0;i<20;i=i+1)begin
            side_buffer_a_w20[i] <= side_buffer_a_w20[i+1];
        end
        for(i=0;i<21;i=i+1)begin
            side_buffer_a_w21[i] <= side_buffer_a_w21[i+1];
        end
        for(i=0;i<22;i=i+1)begin
            side_buffer_a_w22[i] <= side_buffer_a_w22[i+1];
        end
        for(i=0;i<23;i=i+1)begin
            side_buffer_a_w23[i] <= side_buffer_a_w23[i+1];
        end
        for(i=0;i<24;i=i+1)begin
            side_buffer_a_w24[i] <= side_buffer_a_w24[i+1];
        end
        for(i=0;i<25;i=i+1)begin
            side_buffer_a_w25[i] <= side_buffer_a_w25[i+1];
        end
        for(i=0;i<26;i=i+1)begin
            side_buffer_a_w26[i] <= side_buffer_a_w26[i+1];
        end
        for(i=0;i<27;i=i+1)begin
            side_buffer_a_w27[i] <= side_buffer_a_w27[i+1];
        end
        for(i=0;i<28;i=i+1)begin
            side_buffer_a_w28[i] <= side_buffer_a_w28[i+1];
        end
        for(i=0;i<29;i=i+1)begin
            side_buffer_a_w29[i] <= side_buffer_a_w29[i+1];
        end
        for(i=0;i<30;i=i+1)begin
            side_buffer_a_w30[i] <= side_buffer_a_w30[i+1];
        end
        for(i=0;i<31;i=i+1)begin
            side_buffer_a_w31[i] <= side_buffer_a_w31[i+1];
        end
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        side_buffer_b_w0 <=0;
        for(i=0;i<2;i=i+1)begin
            side_buffer_b_w1[i] <=0;
        end
        for(i=0;i<3;i=i+1)begin
            side_buffer_b_w2[i] <=0;
        end
        for(i=0;i<4;i=i+1)begin
            side_buffer_b_w3[i] <=0;
        end
        for(i=0;i<5;i=i+1)begin
            side_buffer_b_w4[i] <=0;
        end
        for(i=0;i<6;i=i+1)begin
            side_buffer_b_w5[i] <=0;
        end
        for(i=0;i<7;i=i+1)begin
            side_buffer_b_w6[i] <=0;
        end
        for(i=0;i<8;i=i+1)begin
            side_buffer_b_w7[i] <=0;
        end
        for(i=0;i<9;i=i+1)begin
            side_buffer_b_w8[i] <=0;
        end
        for(i=0;i<10;i=i+1)begin
            side_buffer_b_w9[i] <=0;
        end
        for(i=0;i<11;i=i+1)begin
            side_buffer_b_w10[i] <=0;
        end
        for(i=0;i<12;i=i+1)begin
            side_buffer_b_w11[i] <=0;
        end
        for(i=0;i<13;i=i+1)begin
            side_buffer_b_w12[i] <=0;
        end
        for(i=0;i<14;i=i+1)begin
            side_buffer_b_w13[i] <=0;
        end
        for(i=0;i<15;i=i+1)begin
            side_buffer_b_w14[i] <=0;
        end
        for(i=0;i<16;i=i+1)begin
            side_buffer_b_w15[i] <=0;
        end
        for(i=0;i<17;i=i+1)begin
            side_buffer_b_w16[i] <=0;
        end
        for(i=0;i<18;i=i+1)begin
            side_buffer_b_w17[i] <=0;
        end
        for(i=0;i<19;i=i+1)begin
            side_buffer_b_w18[i] <=0;
        end
        for(i=0;i<20;i=i+1)begin
            side_buffer_b_w19[i] <=0;
        end
        for(i=0;i<21;i=i+1)begin
            side_buffer_b_w20[i] <=0;
        end
        for(i=0;i<22;i=i+1)begin
            side_buffer_b_w21[i] <=0;
        end
        for(i=0;i<23;i=i+1)begin
            side_buffer_b_w22[i] <=0;
        end
        for(i=0;i<24;i=i+1)begin
            side_buffer_b_w23[i] <=0;
        end
        for(i=0;i<25;i=i+1)begin
            side_buffer_b_w24[i] <=0;
        end
        for(i=0;i<26;i=i+1)begin
            side_buffer_b_w25[i] <=0;
        end
        for(i=0;i<27;i=i+1)begin
            side_buffer_b_w26[i] <=0;
        end
        for(i=0;i<28;i=i+1)begin
            side_buffer_b_w27[i] <=0;
        end
        for(i=0;i<29;i=i+1)begin
            side_buffer_b_w28[i] <=0;
        end
        for(i=0;i<30;i=i+1)begin
            side_buffer_b_w29[i] <=0;
        end
        for(i=0;i<31;i=i+1)begin
            side_buffer_b_w30[i] <=0;
        end
        for(i=0;i<32;i=i+1)begin
            side_buffer_b_w31[i] <=0;
        end
    end
    else if(state_ns==IDLE)begin
        side_buffer_b_w0 <=0;
        for(i=0;i<2;i=i+1)begin
            side_buffer_b_w1[i] <=0;
        end
        for(i=0;i<3;i=i+1)begin
            side_buffer_b_w2[i] <=0;
        end
        for(i=0;i<4;i=i+1)begin
            side_buffer_b_w3[i] <=0;
        end
        for(i=0;i<5;i=i+1)begin
            side_buffer_b_w4[i] <=0;
        end
        for(i=0;i<6;i=i+1)begin
            side_buffer_b_w5[i] <=0;
        end
        for(i=0;i<7;i=i+1)begin
            side_buffer_b_w6[i] <=0;
        end
        for(i=0;i<8;i=i+1)begin
            side_buffer_b_w7[i] <=0;
        end
        for(i=0;i<9;i=i+1)begin
            side_buffer_b_w8[i] <=0;
        end
        for(i=0;i<10;i=i+1)begin
            side_buffer_b_w9[i] <=0;
        end
        for(i=0;i<11;i=i+1)begin
            side_buffer_b_w10[i] <=0;
        end
        for(i=0;i<12;i=i+1)begin
            side_buffer_b_w11[i] <=0;
        end
        for(i=0;i<13;i=i+1)begin
            side_buffer_b_w12[i] <=0;
        end
        for(i=0;i<14;i=i+1)begin
            side_buffer_b_w13[i] <=0;
        end
        for(i=0;i<15;i=i+1)begin
            side_buffer_b_w14[i] <=0;
        end
        for(i=0;i<16;i=i+1)begin
            side_buffer_b_w15[i] <=0;
        end
        for(i=0;i<17;i=i+1)begin
            side_buffer_b_w16[i] <=0;
        end
        for(i=0;i<18;i=i+1)begin
            side_buffer_b_w17[i] <=0;
        end
        for(i=0;i<19;i=i+1)begin
            side_buffer_b_w18[i] <=0;
        end
        for(i=0;i<20;i=i+1)begin
            side_buffer_b_w19[i] <=0;
        end
        for(i=0;i<21;i=i+1)begin
            side_buffer_b_w20[i] <=0;
        end
        for(i=0;i<22;i=i+1)begin
            side_buffer_b_w21[i] <=0;
        end
        for(i=0;i<23;i=i+1)begin
            side_buffer_b_w22[i] <=0;
        end
        for(i=0;i<24;i=i+1)begin
            side_buffer_b_w23[i] <=0;
        end
        for(i=0;i<25;i=i+1)begin
            side_buffer_b_w24[i] <=0;
        end
        for(i=0;i<26;i=i+1)begin
            side_buffer_b_w25[i] <=0;
        end
        for(i=0;i<27;i=i+1)begin
            side_buffer_b_w26[i] <=0;
        end
        for(i=0;i<28;i=i+1)begin
            side_buffer_b_w27[i] <=0;
        end
        for(i=0;i<29;i=i+1)begin
            side_buffer_b_w28[i] <=0;
        end
        for(i=0;i<30;i=i+1)begin
            side_buffer_b_w29[i] <=0;
        end
        for(i=0;i<31;i=i+1)begin
            side_buffer_b_w30[i] <=0;
        end
        for(i=0;i<32;i=i+1)begin
            side_buffer_b_w31[i] <=0;
        end
    end
    else if(state_ns==OP)begin
        // side_buffer_b_w0         <= b[   7:   0];
        // side_buffer_b_w1    [ 1] <= b[  15:   8];
        // side_buffer_b_w2    [ 2] <= b[  23:  16];
        // side_buffer_b_w3    [ 3] <= b[  31:  24];
        // side_buffer_b_w4    [ 4] <= b[  39:  32];
        // side_buffer_b_w5    [ 5] <= b[  47:  40];
        // side_buffer_b_w6    [ 6] <= b[  55:  48];
        // side_buffer_b_w7    [ 7] <= b[  63:  56];
        // side_buffer_b_w8    [ 8] <= b[  71:  64];
        // side_buffer_b_w9    [ 9] <= b[  79:  72];
        // side_buffer_b_w10   [10] <= b[  87:  80];
        // side_buffer_b_w11   [11] <= b[  95:  88];
        // side_buffer_b_w12   [12] <= b[ 103:  96];
        // side_buffer_b_w13   [13] <= b[ 111: 104];
        // side_buffer_b_w14   [14] <= b[ 119: 112];
        // side_buffer_b_w15   [15] <= b[ 127: 120];
        // side_buffer_b_w16   [16] <= b[ 135: 128];
        // side_buffer_b_w17   [17] <= b[ 143: 136];
        // side_buffer_b_w18   [18] <= b[ 151: 144];
        // side_buffer_b_w19   [19] <= b[ 159: 152];
        // side_buffer_b_w20   [20] <= b[ 167: 160];
        // side_buffer_b_w21   [21] <= b[ 175: 168];
        // side_buffer_b_w22   [22] <= b[ 183: 176];
        // side_buffer_b_w23   [23] <= b[ 191: 184];
        // side_buffer_b_w24   [24] <= b[ 199: 192];
        // side_buffer_b_w25   [25] <= b[ 207: 200];
        // side_buffer_b_w26   [26] <= b[ 215: 208];
        // side_buffer_b_w27   [27] <= b[ 223: 216];
        // side_buffer_b_w28   [28] <= b[ 231: 224];
        // side_buffer_b_w29   [29] <= b[ 239: 232];
        // side_buffer_b_w30   [30] <= b[ 247: 240];
        // side_buffer_b_w31   [31] <= b[ 255: 248];
        side_buffer_b_w0         <= b[255:248];
        side_buffer_b_w1    [ 1] <= b[247:240];
        side_buffer_b_w2    [ 2] <= b[239:232];
        side_buffer_b_w3    [ 3] <= b[231:224];
        side_buffer_b_w4    [ 4] <= b[223:216];
        side_buffer_b_w5    [ 5] <= b[215:208];
        side_buffer_b_w6    [ 6] <= b[207:200];
        side_buffer_b_w7    [ 7] <= b[199:192];
        side_buffer_b_w8    [ 8] <= b[191:184];
        side_buffer_b_w9    [ 9] <= b[183:176];
        side_buffer_b_w10   [10] <= b[175:168];
        side_buffer_b_w11   [11] <= b[167:160];
        side_buffer_b_w12   [12] <= b[159:152];
        side_buffer_b_w13   [13] <= b[151:144];
        side_buffer_b_w14   [14] <= b[143:136];
        side_buffer_b_w15   [15] <= b[135:128];
        side_buffer_b_w16   [16] <= b[127:120];
        side_buffer_b_w17   [17] <= b[119:112];
        side_buffer_b_w18   [18] <= b[111:104];
        side_buffer_b_w19   [19] <= b[103: 96];
        side_buffer_b_w20   [20] <= b[ 95: 88];
        side_buffer_b_w21   [21] <= b[ 87: 80];
        side_buffer_b_w22   [22] <= b[ 79: 72];
        side_buffer_b_w23   [23] <= b[ 71: 64];
        side_buffer_b_w24   [24] <= b[ 63: 56];
        side_buffer_b_w25   [25] <= b[ 55: 48];
        side_buffer_b_w26   [26] <= b[ 47: 40];
        side_buffer_b_w27   [27] <= b[ 39: 32];
        side_buffer_b_w28   [28] <= b[ 31: 24];
        side_buffer_b_w29   [29] <= b[ 23: 16];
        side_buffer_b_w30   [30] <= b[ 15:  8];
        side_buffer_b_w31   [31] <= b[  7:  0];
        for(i=0;i<1;i=i+1)begin
            side_buffer_b_w1[i] <= side_buffer_b_w1[i+1];
        end
        for(i=0;i<2;i=i+1)begin
            side_buffer_b_w2[i] <= side_buffer_b_w2[i+1];
        end
        for(i=0;i<3;i=i+1)begin
            side_buffer_b_w3[i] <= side_buffer_b_w3[i+1];
        end
        for(i=0;i<4;i=i+1)begin
            side_buffer_b_w4[i] <= side_buffer_b_w4[i+1];
        end
        for(i=0;i<5;i=i+1)begin
            side_buffer_b_w5[i] <= side_buffer_b_w5[i+1];
        end
        for(i=0;i<6;i=i+1)begin
            side_buffer_b_w6[i] <= side_buffer_b_w6[i+1];
        end
        for(i=0;i<7;i=i+1)begin
            side_buffer_b_w7[i] <= side_buffer_b_w7[i+1];
        end
        for(i=0;i<8;i=i+1)begin
            side_buffer_b_w8[i] <= side_buffer_b_w8[i+1];
        end
        for(i=0;i<9;i=i+1)begin
            side_buffer_b_w9[i] <= side_buffer_b_w9[i+1];
        end
        for(i=0;i<10;i=i+1)begin
            side_buffer_b_w10[i] <= side_buffer_b_w10[i+1];
        end
        for(i=0;i<11;i=i+1)begin
            side_buffer_b_w11[i] <= side_buffer_b_w11[i+1];
        end
        for(i=0;i<12;i=i+1)begin
            side_buffer_b_w12[i] <= side_buffer_b_w12[i+1];
        end
        for(i=0;i<13;i=i+1)begin
            side_buffer_b_w13[i] <= side_buffer_b_w13[i+1];
        end
        for(i=0;i<14;i=i+1)begin
            side_buffer_b_w14[i] <= side_buffer_b_w14[i+1];
        end
        for(i=0;i<15;i=i+1)begin
            side_buffer_b_w15[i] <= side_buffer_b_w15[i+1];
        end
        for(i=0;i<16;i=i+1)begin
            side_buffer_b_w16[i] <= side_buffer_b_w16[i+1];
        end
        for(i=0;i<17;i=i+1)begin
            side_buffer_b_w17[i] <= side_buffer_b_w17[i+1];
        end
        for(i=0;i<18;i=i+1)begin
            side_buffer_b_w18[i] <= side_buffer_b_w18[i+1];
        end
        for(i=0;i<19;i=i+1)begin
            side_buffer_b_w19[i] <= side_buffer_b_w19[i+1];
        end
        for(i=0;i<20;i=i+1)begin
            side_buffer_b_w20[i] <= side_buffer_b_w20[i+1];
        end
        for(i=0;i<21;i=i+1)begin
            side_buffer_b_w21[i] <= side_buffer_b_w21[i+1];
        end
        for(i=0;i<22;i=i+1)begin
            side_buffer_b_w22[i] <= side_buffer_b_w22[i+1];
        end
        for(i=0;i<23;i=i+1)begin
            side_buffer_b_w23[i] <= side_buffer_b_w23[i+1];
        end
        for(i=0;i<24;i=i+1)begin
            side_buffer_b_w24[i] <= side_buffer_b_w24[i+1];
        end
        for(i=0;i<25;i=i+1)begin
            side_buffer_b_w25[i] <= side_buffer_b_w25[i+1];
        end
        for(i=0;i<26;i=i+1)begin
            side_buffer_b_w26[i] <= side_buffer_b_w26[i+1];
        end
        for(i=0;i<27;i=i+1)begin
            side_buffer_b_w27[i] <= side_buffer_b_w27[i+1];
        end
        for(i=0;i<28;i=i+1)begin
            side_buffer_b_w28[i] <= side_buffer_b_w28[i+1];
        end
        for(i=0;i<29;i=i+1)begin
            side_buffer_b_w29[i] <= side_buffer_b_w29[i+1];
        end
        for(i=0;i<30;i=i+1)begin
            side_buffer_b_w30[i] <= side_buffer_b_w30[i+1];
        end
        for(i=0;i<31;i=i+1)begin
            side_buffer_b_w31[i] <= side_buffer_b_w31[i+1];
        end
    end
end
//================================================================
// SUB MODULE
//================================================================
// clock gate
// genvar cg_idx; 
// generate
//     for (cg_idx = 0; cg_idx < 16; cg_idx = cg_idx + 1) begin : gen_gated_clk
//         GATED_OR GATED_r (
//             .CLOCK(clk),
//             .SLEEP_CTRL(cg_pe[cg_idx]),
//             .RST_N(rst_n),
//             .CLOCK_GATED(cg_clk[cg_idx])
//         );
//     end
// endgenerate

// divide pe into four chunk
// x: 0~15 16~31 31~16 15~0
// genvar cg_pe_idx;
// generate
//     for(cg_pe_idx = 0 ; cg_pe_idx < `PE_SIZE; cg_pe_idx = cg_pe_idx + 1)begin
//         if(state_cs==OP)begin
//             if(cg_pe_idx)
//         end
//     end
// endgenerate

// Mult
genvar m;
generate
    for (m = 0; m < `PE_SIZE; m = m + 1) begin : gen_mult
        mult u_mult( .a (mult_a[m]),
                     .b (mult_b[m]),
                     .out (mult_out[m])
        );
    end
endgenerate
// PE


// mult_a
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0 ; i<`PE_SIZE; i=i+1)
            mult_a[i]<=0;
    end
    else if(state_ns==IDLE)begin
        for(i = 0 ; i<`PE_SIZE; i=i+1)
            mult_a[i]<=0;
    end
    else if(state_ns==OP)begin
        mult_a[   0] <= side_buffer_a_w0     ;
        mult_a[  32] <= side_buffer_a_w1     [0];
        mult_a[  64] <= side_buffer_a_w2     [0];
        mult_a[  96] <= side_buffer_a_w3     [0];
        mult_a[ 128] <= side_buffer_a_w4     [0];
        mult_a[ 160] <= side_buffer_a_w5     [0];
        mult_a[ 192] <= side_buffer_a_w6     [0];
        mult_a[ 224] <= side_buffer_a_w7     [0];
        mult_a[ 256] <= side_buffer_a_w8     [0];
        mult_a[ 288] <= side_buffer_a_w9     [0];
        mult_a[ 320] <= side_buffer_a_w10    [0];
        mult_a[ 352] <= side_buffer_a_w11    [0];
        mult_a[ 384] <= side_buffer_a_w12    [0];
        mult_a[ 416] <= side_buffer_a_w13    [0];
        mult_a[ 448] <= side_buffer_a_w14    [0];
        mult_a[ 480] <= side_buffer_a_w15    [0];
        mult_a[ 512] <= side_buffer_a_w16    [0];
        mult_a[ 544] <= side_buffer_a_w17    [0];
        mult_a[ 576] <= side_buffer_a_w18    [0];
        mult_a[ 608] <= side_buffer_a_w19    [0];
        mult_a[ 640] <= side_buffer_a_w20    [0];
        mult_a[ 672] <= side_buffer_a_w21    [0];
        mult_a[ 704] <= side_buffer_a_w22    [0];
        mult_a[ 736] <= side_buffer_a_w23    [0];
        mult_a[ 768] <= side_buffer_a_w24    [0];
        mult_a[ 800] <= side_buffer_a_w25    [0];
        mult_a[ 832] <= side_buffer_a_w26    [0];
        mult_a[ 864] <= side_buffer_a_w27    [0];
        mult_a[ 896] <= side_buffer_a_w28    [0];
        mult_a[ 928] <= side_buffer_a_w29    [0];
        mult_a[ 960] <= side_buffer_a_w30    [0];
        mult_a[ 992] <= side_buffer_a_w31    [0];
        for(i=0;i<`GBUFF_INDX_SIZE;i=i+1)begin
            for(j=1;j<`GBUFF_INDX_SIZE;j=j+1)begin
                mult_a[i*`GBUFF_INDX_SIZE+j]<=mult_a[i*`GBUFF_INDX_SIZE+j-1];
            end
        end
    end
end
// mult_b
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0 ; i<`PE_SIZE; i=i+1)
            mult_b[i]<=0;
    end
    else if(state_ns==IDLE)begin
        for(i = 0 ; i<`PE_SIZE; i=i+1)
            mult_b[i]<=0;
    end
    else if(state_ns==OP)begin
        mult_b[ 0] <= side_buffer_b_w0     ;
        mult_b[ 1] <= side_buffer_b_w1     [0];
        mult_b[ 2] <= side_buffer_b_w2     [0];
        mult_b[ 3] <= side_buffer_b_w3     [0];
        mult_b[ 4] <= side_buffer_b_w4     [0];
        mult_b[ 5] <= side_buffer_b_w5     [0];
        mult_b[ 6] <= side_buffer_b_w6     [0];
        mult_b[ 7] <= side_buffer_b_w7     [0];
        mult_b[ 8] <= side_buffer_b_w8     [0];
        mult_b[ 9] <= side_buffer_b_w9     [0];
        mult_b[10] <= side_buffer_b_w10    [0];
        mult_b[11] <= side_buffer_b_w11    [0];
        mult_b[12] <= side_buffer_b_w12    [0];
        mult_b[13] <= side_buffer_b_w13    [0];
        mult_b[14] <= side_buffer_b_w14    [0];
        mult_b[15] <= side_buffer_b_w15    [0];
        mult_b[16] <= side_buffer_b_w16    [0];
        mult_b[17] <= side_buffer_b_w17    [0];
        mult_b[18] <= side_buffer_b_w18    [0];
        mult_b[19] <= side_buffer_b_w19    [0];
        mult_b[20] <= side_buffer_b_w20    [0];
        mult_b[21] <= side_buffer_b_w21    [0];
        mult_b[22] <= side_buffer_b_w22    [0];
        mult_b[23] <= side_buffer_b_w23    [0];
        mult_b[24] <= side_buffer_b_w24    [0];
        mult_b[25] <= side_buffer_b_w25    [0];
        mult_b[26] <= side_buffer_b_w26    [0];
        mult_b[27] <= side_buffer_b_w27    [0];
        mult_b[28] <= side_buffer_b_w28    [0];
        mult_b[29] <= side_buffer_b_w29    [0];
        mult_b[30] <= side_buffer_b_w30    [0];
        mult_b[31] <= side_buffer_b_w31    [0];
        for(i=0;i<`GBUFF_INDX_SIZE;i=i+1)begin
            for(j=1;j<`GBUFF_INDX_SIZE;j=j+1)begin
                mult_b[j*`GBUFF_INDX_SIZE+i]<=mult_b[(j-1)*`GBUFF_INDX_SIZE+i];
            end
        end
    end
end


genvar pe_idx;
generate
    for(pe_idx = 0; pe_idx<`PE_SIZE; pe_idx = pe_idx+1)begin :PE_GEN
        always@(posedge clk or negedge rst_n)begin
            if(!rst_n)
                mult_pe[pe_idx]<=0;
            else if(state_ns==IDLE)
                mult_pe[pe_idx]<=0;
            else if(state_ns==OP)
                mult_pe[pe_idx]<=mult_pe[pe_idx]+mult_out[pe_idx];
        end
    end
endgenerate

//================================================================
// MAIN DESIGN
//================================================================
assign start = (state_cs==IDLE && in_valid && in_ready);
assign OP_done = (state_cs==OP && counter==96);
assign WR_done = (state_cs==WR && counter==32);


always@(*)begin
    if((state_cs==IDLE || state_cs==OP) && counter<32)
        in_ready = 1;
    else
        in_ready = 0;
end

//FSM
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        state_cs<=IDLE;
    else
        state_cs<=state_ns; 
end

always@(*)begin
    case(state_cs)
        IDLE    :   state_ns = (start)? OP : IDLE;
        OP      :   state_ns = (OP_done)?IDLE3: OP;
        IDLE3   :   state_ns = WR;
        WR      :   state_ns = (WR_done)?DONE: WR;
        DONE    :   state_ns = IDLE;
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter<=0;
    else if(state_ns==IDLE || state_ns==IDLE3 || state_ns==DONE)
        counter<=0;
    else if(state_ns==OP)
        counter<=counter+1;
    else if(state_ns==WR && out_ready)
        counter<=counter+1;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        done<=0;
    else if(state_ns==DONE)
        done<=1;
    else 
        done<=0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        out<=0;
    else if(state_ns==IDLE)
        out<=0;
    else if(state_ns==WR)begin
        out<={mult_pe[counter<<5],
              mult_pe[(counter<<5)+ 1],
              mult_pe[(counter<<5)+ 2],
              mult_pe[(counter<<5)+ 3],
              mult_pe[(counter<<5)+ 4],
              mult_pe[(counter<<5)+ 5],
              mult_pe[(counter<<5)+ 6],
              mult_pe[(counter<<5)+ 7],
              mult_pe[(counter<<5)+ 8],
              mult_pe[(counter<<5)+ 9],
              mult_pe[(counter<<5)+10],
              mult_pe[(counter<<5)+11],
              mult_pe[(counter<<5)+12],
              mult_pe[(counter<<5)+13],
              mult_pe[(counter<<5)+14],
              mult_pe[(counter<<5)+15],
              mult_pe[(counter<<5)+16],
              mult_pe[(counter<<5)+17],
              mult_pe[(counter<<5)+18],
              mult_pe[(counter<<5)+19],
              mult_pe[(counter<<5)+20],
              mult_pe[(counter<<5)+21],
              mult_pe[(counter<<5)+22],
              mult_pe[(counter<<5)+23],
              mult_pe[(counter<<5)+24],
              mult_pe[(counter<<5)+25],
              mult_pe[(counter<<5)+26],
              mult_pe[(counter<<5)+27],
              mult_pe[(counter<<5)+28],
              mult_pe[(counter<<5)+29],
              mult_pe[(counter<<5)+30],
              mult_pe[(counter<<5)+31]};
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        out_valid<=0;
    else if(state_ns==WR)
        out_valid<=1;
    else
        out_valid<=0;
end

endmodule
