`timescale 1ns / 1ps
`include "memory_constants.vh"

module memory_controller #(
    parameter NB_DATA = 32,
    parameter NB_TYPE = 3
) (
    input               i_signed,
    input               i_mem_write,
    input               i_mem_read,
    input [NB_TYPE-1:0] i_word_size,
    input [NB_DATA-1:0] i_data_in,
    input [NB_DATA-1:0] i_data_out,
    output [NB_DATA-1:0] o_data_in,
    output [NB_DATA-1:0] o_data_out
);


endmodule
