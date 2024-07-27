`timescale 1ns / 1ps

module EX_MEM #(
    parameter NB = 32,
    parameter NB_SIZE_TYPE = 3
) (
    input                    i_clk,
    input                    i_step,
    input                    i_reset,
    input                    i_cero,
    input [          NB-1:0] i_alu_result,
    input [          NB-1:0] i_data_b,
    input                    i_mem_read,
    input                    i_mem_write,
    input                    i_reg_write,
    input [NB_SIZE_TYPE-1:0] i_word_size,

    output reg                    o_cero,
    output reg [          NB-1:0] o_alu_result,
    output reg [          NB-1:0] o_data_b,
    output reg                    o_mem_read,
    output reg                    o_mem_write,
    output reg                    o_reg_write,
    output reg [NB_SIZE_TYPE-1:0] o_word_size
);

  always @(negedge i_clk) begin
    if (i_reset) begin
      o_cero <= 0;
      o_alu_result <= 0;
      o_data_b <= 0;
      o_mem_read <= 0;
      o_mem_write <= 0;
      o_reg_write <= 0;
      o_word_size <= 0;

    end else begin
      if (i_step) begin
        o_cero <= i_cero;
        o_alu_result <= i_alu_result;
        o_data_b <= i_data_b;
        o_mem_read <= i_mem_read;
        o_mem_write <= i_mem_write;
        o_reg_write <= i_reg_write;
        o_word_size <= i_word_size;
      end
    end
  end

endmodule
