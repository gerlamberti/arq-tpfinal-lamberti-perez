`timescale 1ns / 1ps

module MEMORY #(
    parameter NB = 32,
    parameter TAM = 16,
    parameter NB_ADDR = $clog2(TAM),
    parameter NB_SIZE_TYPE = 3
) (
    input i_clk,
    input i_reset,
    input i_step,
    input [NB-1:0] i_alu_address_result,
    input [NB-1:0] i_debug_address,
    input [NB-1:0] i_data_b_to_write,
    input [NB_SIZE_TYPE-1:0] i_word_size,
    input i_mem_read,
    input i_mem_write,
    input i_reg_write,
    input i_signed,

    output [NB-1:0] o_data_memory,
    output [NB-1:0] o_data_debug_memory
);
  wire [NB-1:0] w_data_to_write;

  memory_data #(
      .NB(NB),
      .TAM(TAM),
      .NB_ADDR(NB_ADDR)
  ) memory_data (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_step(i_step),
      .i_alu_address(i_alu_address_result[NB_ADDR-1:0]),
      .i_data_to_write(w_data_to_write),
      .i_mem_write(i_mem_write),
      .i_debug_address(i_debug_address[NB_ADDR-1:0]),
      .i_mem_read(i_mem_read),
      .o_alu_address_data(w_memory_read_data),
      .o_debug_address_data(o_data_debug_memory)
  );

  memory_controller #(
      .NB_DATA(NB),
      .NB_TYPE(NB_SIZE_TYPE)
  ) memory_controller (
      .i_signed(i_signed),
      .i_mem_write(i_mem_write),
      .i_mem_read(i_mem_read),
      .i_word_size(i_word_size),
      .i_raw_data_to_write(i_data_b_to_write),
      .i_raw_read_data(w_memory_read_data),
      .o_formatted_write_data(w_data_to_write),
      .o_formatted_read_data(o_data_memory)
  );

endmodule
