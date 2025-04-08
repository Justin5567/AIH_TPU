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
`define DATA_SIZE 8
`define WORD_SIZE 256
`define GBUFF_ADDR_SIZE 256
//`define GBUFF_INDX_SIZE (GBUFF_ADDR_SIZE/WORD_SIZE)
`define GBUFF_INDX_SIZE 32
`define GBUFF_SIZE (WORD_SIZE*GBUFF_ADDR_SIZE)
`define PE_SIZE 1024
`define ROW_SIZE 5
//----------------------------------------------------------------------------//
// Simulations Definations                                                    //
//----------------------------------------------------------------------------//
`define CYCLE 10
// `define MAX   500000

//----------------------------------------------------------------------------//
// User Definations                                                           //
//----------------------------------------------------------------------------//
