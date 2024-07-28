`timescale 1ns / 1ps

module MEMORY #(
    parameter NB = 32,
    parameter TAM = 16,
    parameter NB_SIZE_TYPE = 3
) (
    input i_clk,
    input i_reset,
    input i_step,
    input [NB-1:0] i_alu_address_result,
    input i_mem_read,
    input i_signed,
    input [NB-1:0] i_debug_address,
    input [NB-1:0] i_data_b_to_write,
    input [NB_SIZE_TYPE-1:0] i_word_size,
    input i_mem_write,
    input i_reg_write,
    input i_branch,
    input i_cero,
    output [NB-1:0] o_data_memory,
    output [NB-1:0] o_data_debug_memory,
    output [NB-1:0] o_debug_delete_adapter_write,
    output          o_branch_zero,
);
  
  wire [NB-1:0] w_data_to_write, w_memory_read_data;
  assign o_debug_delete_adapter_write = w_data_to_write; 
  assign o_branch_zero = i_branch & i_cero;

  write_adapter #(
      .NB_DATA(NB),
      .NB_TYPE(NB_SIZE_TYPE)
  ) write_adapter_inst (
      .i_word_size(i_word_size),
      .i_data_in  (i_data_b_to_write),
      .o_data_in  (w_data_to_write)
  );

  memory_data #(
      .NB(NB),
      .TAM(TAM)
  ) memory_data (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_step(i_step),
      .i_alu_address(i_alu_address_result),
      .i_data_to_write(w_data_to_write),
      .i_mem_write(i_mem_write),
      .i_debug_address(i_debug_address),
      .i_mem_read(i_mem_read),
      .o_alu_address_data(w_memory_read_data),
      .o_debug_address_data(o_data_debug_memory)
  );


  read_adapter #(
      .NB_DATA(NB),
      .NB_TYPE(NB_SIZE_TYPE)
  ) read_adapter_inst (
      .i_signed(i_signed),
      .i_word_size(i_word_size),
      .i_data_out(w_memory_read_data),
      .o_data_out(o_data_memory)
  );



endmodule
