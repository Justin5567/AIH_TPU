//============================================================================//
// 25 Spring AI Hardwar Final Project                                         //
// file: global_buffer.v                                                      //
// description: global buffer read write behavior module                      //
// authors: Jus7in (justinh5567@gmail.com)                                    //
//============================================================================//

`include "src/define.v"

module global_buffer(clk, rst_n, wr_en, index, data_in, data_out);

  input clk;
  input rst_n;
  input wr_en; // Write enable: 1->write 0->read
  input      [`ROW_SIZE-1:0] index;
  input      [`WORD_SIZE-1:0]       data_in;
  output reg [`WORD_SIZE-1:0]       data_out;

  integer i;

//----------------------------------------------------------------------------//
// Global buffer (Don't change the name)                                      //
//----------------------------------------------------------------------------//
  reg  [`WORD_SIZE-1:0]gbuff [`GBUFF_ADDR_SIZE-1:0];
//----------------------------------------------------------------------------//
// Global buffer read write behavior                                          //
//----------------------------------------------------------------------------//
  always @ (posedge clk or negedge rst_n) begin
    if(!rst_n)begin
      for(i=0; i<=256; i=i+1)
        gbuff[i] <= 32'd0;
    end
    else begin
      if(wr_en) begin
        gbuff[index] <= data_in;
      end
      else begin
        data_out <= gbuff[index];
      end
    end
  end

endmodule