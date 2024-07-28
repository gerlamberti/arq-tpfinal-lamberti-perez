`timescale 1ns / 1ps

module EX_MEM #(
    parameter NB = 32,
    parameter NB_OPCODE = 6,
    parameter NB_FCODE = 6
) (
    input          i_clk,
    input          i_step,
    input          i_reset,
    input          i_cero,
    input [NB-1:0] i_alu_result,
    input [NB-1:0] i_branch_addr,
    input          i_mem_read,
    input          i_mem_write,
    input          i_reg_write,
    input [2:0]    i_word_size,
    input          i_branch,


    output reg          o_branch,
    output [NB-1:0]     o_branch_addr,
    output [2:0]        o_word_size,
    output reg          o_cero,
    output reg [NB-1:0] o_alu_result,
    output reg          o_mem_read,
    output reg          o_mem_write,
    output reg          o_reg_write
);

  always @(negedge i_clk) begin
    if (i_reset) begin
      o_cero <= 0;
      o_alu_result  <= 0;
      o_mem_read    <= 0;
      o_mem_write   <= 0;
      o_reg_write   <= 0;
      o_word_size   <= 0;
      o_branch      <= 0;
      o_branch_addr <= 0;

    end else begin
      if (i_step) begin
        o_cero <= i_cero;
        o_alu_result  <= i_alu_result;
        o_mem_read    <= i_mem_read;
        o_mem_write   <= i_mem_write;
        o_reg_write   <= i_reg_write;
        o_word_size   <= i_word_size;
        o_branch      <= i_branch;
        o_branch_addr <= i_branch_addr;
      end
    end
  end

endmodule
