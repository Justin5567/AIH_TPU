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

module top(
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
input clk;
input rst_n;
input in_valid;
input [4:0] m;
input [4:0] n;
input [4:0] k;
output reg out_valid;

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================

// parameter
parameter IDLE  = 4'd0;
parameter RD    = 4'd1;
parameter IDLE2 = 4'd2;
parameter OP    = 4'd3;
parameter WR    = 4'd5;
parameter DONE  = 4'd6;

// reg
reg [3:0] state_cs, state_ns;

wire                            gbuffer_wr_en_a,
                                gbuffer_wr_en_b;
reg                             gbuffer_wr_en_o;
reg  [`ROW_SIZE-1:0]            gbuffer_idx_a,
                                gbuffer_idx_b,
                                gbuffer_idx_o;
wire  [`WORD_SIZE-1:0]          gbuffer_in_a,
                                gbuffer_in_b;
reg  [`WORD_SIZE-1:0]           gbuffer_in_o;
wire [`WORD_SIZE-1:0]           gbuffer_out_a,
                                gbuffer_out_b,
                                gbuffer_out_o;

reg [`ROW_SIZE:0] counter;

reg [`WORD_SIZE-1:0] tpu_data_a,
                     tpu_data_b;
wire[`WORD_SIZE-1:0] tpu_data_o;

// wire
wire RD_done;
wire OP_done;
wire WR_done;

reg tpu_in_valid;
wire tpu_in_ready;
reg tpu_out_ready;
wire tpu_out_valid;
wire tpu_done;

//================================================================
// SUB MODULE
//================================================================

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
        tpu_data_a  = gbuffer_in_a;
        tpu_data_b  = gbuffer_in_b;
    end
    else begin
        tpu_data_a  = 0;
        tpu_data_b  = 0;
    end
end

assign tpu_start = (state_cs==IDLE && state_ns==RD);

always@(*)begin
    if(state_cs==RD) begin
        tpu_data_a = gbuffer_out_a;
        tpu_data_b = gbuffer_out_b;
    end
    else begin
        tpu_data_a = 0;
        tpu_data_b = 0;
    end

end

//================================================================
// Global Buffer
//================================================================
global_buffer GBUFF_A(  .clk     (clk       ),
                        .rst_n   (rst_n     ),
                        .wr_en   (gbuffer_wr_en_a),
                        .index   (gbuffer_idx_a),
                        .data_in (gbuffer_in_a ),
                        .data_out(gbuffer_out_a));

global_buffer GBUFF_B(  .clk     (clk       ),
                        .rst_n   (rst_n     ),
                        .wr_en   (gbuffer_wr_en_b),
                        .index   (gbuffer_idx_b),
                        .data_in (gbuffer_in_b),
                        .data_out(gbuffer_out_b));

global_buffer GBUFF_OUT(  .clk     (clk      ),
                          .rst_n   (rst_n    ),
                          .wr_en   (gbuffer_wr_en_o),
                          .index   (gbuffer_idx_o),
                          .data_in (gbuffer_in_o),
                          .data_out(gbuffer_out_o));

assign gbuffer_wr_en_a = 0; // always read
assign gbuffer_wr_en_b = 0; // always read

assign gbuffer_in_a = 32'bz;
assign gbuffer_in_b = 32'bz;

always@(*)begin
    if(tpu_out_ready && tpu_out_valid)
        gbuffer_wr_en_o = 1;
    else
        gbuffer_wr_en_o = 0;
end 

always@(*)begin
    if(state_cs==RD)begin
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

assign RD_done = counter==32;
assign OP_done = (state_cs==OP && tpu_out_valid);
assign WR_done = counter==32;
//FSM
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        state_cs<=IDLE;
    else
        state_cs<=state_ns; 
end

always@(*)begin
    case(state_cs)
        IDLE    :   state_ns = (in_valid)? RD : IDLE;
        RD      :   state_ns = (RD_done)? IDLE2:   RD;
        IDLE2   :   state_ns = OP;
        OP      :   state_ns = (OP_done)? WR:   OP;
        WR      :   state_ns = (WR_done)? DONE: WR;
        DONE    :   state_ns = IDLE;
        default:    state_ns = state_cs;   
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        counter <= 0;
    else if(state_ns==IDLE || state_ns==IDLE2 || state_ns==OP)
        counter <= 0;
    else if(state_ns==RD || (state_ns==WR))
        counter <= counter+1;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        out_valid<=0;
    else if(state_ns==DONE)
        out_valid<=1;
    else
        out_valid<=0;
end




endmodule
