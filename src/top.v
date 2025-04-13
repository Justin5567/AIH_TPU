//############################################################################
//
//   Author      : Jus7in (justinh5567@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : top.v
//   Module Name : top
//   Release version : v1.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`include "src/define.v"
`include "src/global_buffer.v"
`include "src/tpu.v"
`include "src/GATED_OR.v"
module top(
	clk,
	rst_n,
	in_valid,
    gbuff_a,
    gbuff_b,
	m,
	n,
	k,
    gbuff_out, 
	out_valid
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;
input rst_n;
input in_valid;
input [4:0] m;
input [4:0] n;
input [4:0] k;
input [255:0] gbuff_a, gbuff_b;
output reg out_valid;
output reg [255:0] gbuff_out;
// ===============================================================
// Parameter & Integer Declaration
// ===============================================================

// parameter
parameter IDLE  = 4'd0;
parameter LOAD  = 4'd1;
parameter IDLE3 = 4'd2;
parameter RD    = 4'd3;
parameter IDLE2 = 4'd4;
parameter OP    = 4'd5;
parameter WR    = 4'd6;
parameter IDLE4 = 4'd7;
parameter IDLE5 = 4'd8;
parameter OUTPUT= 4'd9;
parameter DONE  = 4'd10;

// reg
reg [3:0] state_cs, state_ns;

reg                             gbuffer_wr_en_a,
                                gbuffer_wr_en_b;
reg                             gbuffer_wr_en_o;
reg  [`ROW_SIZE-1:0]            gbuffer_idx_a,
                                gbuffer_idx_b,
                                gbuffer_idx_o;
reg  [`WORD_SIZE-1:0]           gbuffer_in_a,
                                gbuffer_in_b;
reg  [`WORD_SIZE-1:0]           gbuffer_in_o;
wire [`WORD_SIZE-1:0]           gbuffer_out_a,
                                gbuffer_out_b,
                                gbuffer_out_o;

reg [`ROW_SIZE+1:0] counter;

reg [`WORD_SIZE-1:0] tpu_data_a,
                     tpu_data_b;
wire[`WORD_SIZE-1:0] tpu_data_o;

// wire
wire RD_done;
wire OP_done;
wire WR_done;
wire LOAD_done;
wire OUTPUT_done;

reg tpu_in_valid;
wire tpu_in_ready;
reg tpu_out_ready;
wire tpu_out_valid;
wire tpu_done;

//================================================================
// SUB MODULE
//================================================================

//ver2 cg
reg cg_ab;
wire cg_clk_ab;
always@(*)begin
    if(state_cs==IDLE || state_cs==LOAD || state_cs==IDLE3|| state_cs==RD)
        cg_ab = 0; 
    else 
        cg_ab = 1; 
end


GATED_OR GATED_top_gbuff_ab (
            .CLOCK(clk),
            .SLEEP_CTRL(cg_ab),
            .RST_N(rst_n),
            .CLOCK_GATED(cg_clk_ab));

reg cg_out;
wire cg_clk_out;

always@(*)begin
    if( state_ns==WR ||state_cs==WR || state_cs==IDLE4 || state_cs==IDLE5 || state_cs==OUTPUT)
        cg_out = 0; 
    else 
        cg_out = 1; 
end

GATED_OR GATED_top_gbuff_out (
            .CLOCK(clk),
            .SLEEP_CTRL(cg_out),
            .RST_N(rst_n),
            .CLOCK_GATED(cg_clk_out));


tpu TPU(.clk        (clk),
	    .rst_n      (rst_n),
	    .in_valid   (tpu_in_valid),
        .out_ready  (tpu_out_ready),
	    .a          (tpu_data_a),
        .b          (tpu_data_b),
        .out        (tpu_data_o),
        .in_ready   (tpu_in_ready),
        .out_valid  (tpu_out_valid),
        .done       (tpu_done)
    );

always@(*)begin
    if(state_cs==RD)
        tpu_in_valid = 1;
    else
        tpu_in_valid = 0;
end

always@(*)begin
    if((state_cs== OP || state_cs==WR) && state_ns!=DONE)
        tpu_out_ready = 1;
    else
        tpu_out_ready = 0;
end

always@(*)begin
    if(state_cs==RD)begin
        tpu_data_a  = gbuffer_out_a;
        tpu_data_b  = gbuffer_out_b;
    end
    else begin
        tpu_data_a  = 0;
        tpu_data_b  = 0;
    end
end
wire tpu_start;
assign tpu_start = (state_cs==IDLE && state_ns==RD);


//================================================================
// Global Buffer
//================================================================
global_buffer GBUFF_A(  .clk     (cg_clk_ab       ),
                        .rst_n   (rst_n     ),
                        .wr_en   (gbuffer_wr_en_a),
                        .index   (gbuffer_idx_a),
                        .data_in (gbuffer_in_a ),
                        .data_out(gbuffer_out_a));

global_buffer GBUFF_B(  .clk     (cg_clk_ab       ),
                        .rst_n   (rst_n     ),
                        .wr_en   (gbuffer_wr_en_b),
                        .index   (gbuffer_idx_b),
                        .data_in (gbuffer_in_b),
                        .data_out(gbuffer_out_b));

global_buffer GBUFF_OUT(  .clk     (cg_clk_out      ),
                          .rst_n   (rst_n    ),
                          .wr_en   (gbuffer_wr_en_o),
                          .index   (gbuffer_idx_o),
                          .data_in (gbuffer_in_o),
                          .data_out(gbuffer_out_o));

// assign gbuffer_wr_en_a = 0; // always read
// assign gbuffer_wr_en_b = 0; // always read

always@(*)begin
    if(state_ns==LOAD)begin
        gbuffer_wr_en_a = 1;
        gbuffer_wr_en_b = 1;
    end
    else begin
        gbuffer_wr_en_a = 0;
        gbuffer_wr_en_b = 0;
    end
end 


always@(*)begin
    if(state_ns==LOAD)begin
        gbuffer_in_a = gbuff_a;
        gbuffer_in_b = gbuff_b;
    end
    else begin
        gbuffer_in_a = 0;
        gbuffer_in_b = 0;
    end
end

always@(*)begin
    if(tpu_out_ready && tpu_out_valid)
        gbuffer_wr_en_o = 1;
    else
        gbuffer_wr_en_o = 0;
end 

always@(*)begin
    if(state_cs==RD || state_cs==LOAD)begin
        gbuffer_idx_a = counter;
        gbuffer_idx_b = counter;
    end
    else begin
        gbuffer_idx_a = 0;
        gbuffer_idx_b = 0;
    end
end

always@(*)begin
    if(tpu_out_ready && tpu_out_valid)
        gbuffer_idx_o = counter;
    else if(state_cs==OUTPUT || state_cs==IDLE5)
        gbuffer_idx_o = counter;
    else
        gbuffer_idx_o = 0;
end

always@(*)begin
    if(tpu_out_ready && tpu_out_valid)
        gbuffer_in_o = tpu_data_o;
    else
        gbuffer_in_o = 0;
end

//================================================================
// MAIN DESIGN
//================================================================
assign LOAD_done    = counter==32;
assign RD_done      = counter==32;
assign OP_done      = (state_cs==OP && tpu_out_valid);
assign WR_done      = counter==32;
assign OUTPUT_done  = counter==33;
//FSM
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        state_cs<=IDLE;
    else
        state_cs<=state_ns; 
end

always@(*)begin
    case(state_cs)
        IDLE    :   state_ns = (in_valid)? LOAD : IDLE;
        LOAD    :   state_ns = (LOAD_done)?IDLE3:LOAD;
        IDLE3   :   state_ns = RD;
        RD      :   state_ns = (RD_done)? IDLE2:   RD;
        IDLE2   :   state_ns = OP;
        OP      :   state_ns = (OP_done)? WR:   OP;
        WR      :   state_ns = (WR_done)? IDLE4: WR;
        IDLE4   :   state_ns = IDLE5;
        IDLE5   :   state_ns = OUTPUT;
        OUTPUT  :   state_ns = (OUTPUT_done)? DONE:OUTPUT;
        DONE    :   state_ns = IDLE;
        //default:    state_ns = state_cs;   
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter <= 0;
    else if(state_ns==IDLE || state_ns==IDLE2 || state_ns==OP || state_ns==IDLE3|| state_ns==IDLE4)
        counter <= 0;
    else if(state_ns==RD || state_ns==WR || state_ns==LOAD|| state_ns==OUTPUT || state_ns==IDLE5)
        counter <= counter+1;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        out_valid<=0;
    else if(state_ns==OUTPUT)
        out_valid<=1;
    else
        out_valid<=0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        gbuff_out <=0;
    else if(state_ns==IDLE)
        gbuff_out <=0;
    else if(state_ns==OUTPUT)
        gbuff_out <=gbuffer_out_o;
end



endmodule