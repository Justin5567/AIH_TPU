//============================================================================//
// 25 Spring AI Hardwar Final Project                                         //
// file: global_buffer.v                                                      //
// description: global buffer read write behavior module                      //
// authors: Jus7in (justinh5567@gmail.com)                                    //
//============================================================================//

//----------------------------------------------------------------------------//
// Matrix Parameters Definations                                              //
//----------------------------------------------------------------------------//
// `include "build/matrix_define.v"

//----------------------------------------------------------------------------//
// Common Definations                                                         //
//----------------------------------------------------------------------------//
`define DATA_SIZE 16
`define WORD_SIZE 512
`define GBUFF_ADDR_SIZE 256
//`define GBUFF_INDX_SIZE (GBUFF_ADDR_SIZE/WORD_SIZE)
`define GBUFF_INDX_SIZE 32
`define GBUFF_SIZE (WORD_SIZE*GBUFF_ADDR_SIZE)
`define PE_SIZE 1024
`define ROW_SIZE 5

`define GBUFF_IN_DATA_SIZE 16
`define GBUFF_IN_ADDR_SIZE 32
`define GBUFF_IN_LINE_SIZE 512
`define GBUFF_IN_IDX_SIZE 5

`define MULT_SIZE 32

`define GBUFF_OUT_DATA_SIZE 37
`define GBUFF_OUT_ADDR_SIZE 32
`define GBUFF_OUT_LINE_SIZE 1184
`define GBUFF_OUT_IDX_SIZE 5
//----------------------------------------------------------------------------//
// Simulations Definations                                                    //
//----------------------------------------------------------------------------//
//`define CYCLE 10
// `define MAX   500000

//----------------------------------------------------------------------------//
// User Definations                                                           //
//----------------------------------------------------------------------------//
