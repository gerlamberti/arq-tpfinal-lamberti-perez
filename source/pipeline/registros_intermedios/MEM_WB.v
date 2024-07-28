`timescale 1ns / 1ps

module MEM_WB #(
    parameter NB = 32
) (
    input i_clk,
    input i_step,
    input i_reset,

    input i_reg_write,
    input i_mem_to_reg,
    input [NB-1:0] i_data_memory,
    input [NB-1:0] i_alu_address_result,

    output reg o_reg_write,
    output reg o_mem_to_reg,
    output reg [NB-1:0] o_data_memory,
    output reg [NB-1:0] o_alu_address_result
);

  always @(negedge i_clk) begin
    if (i_reset) begin
      o_reg_write <= 0;
      o_mem_to_reg <= 0;
      o_data_memory <= 0;
      o_alu_address_result <= 0;

    end else begin
      if (i_step) begin
        o_reg_write <= i_reg_write;
        o_mem_to_reg <= i_mem_to_reg;
        o_data_memory <= i_data_memory;
        o_alu_address_result <= i_alu_address_result;
      end
    end
  end

endmodule
