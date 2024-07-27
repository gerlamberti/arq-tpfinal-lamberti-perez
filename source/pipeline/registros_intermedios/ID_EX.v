`timescale 1ns / 1ps

module ID_EX #(
    parameter NB = 32,
    parameter NB_OPCODE = 6,
    parameter NB_FCODE = 6
) (
    input                 i_clk,
    input                 i_step,
    input                 i_reset,
    input [ NB_FCODE-1:0] i_instruction_funct_code,
    input [NB_OPCODE-1:0] i_instruction_op_code,
    input                 i_alu_src,                 // 0 data_b, 1 immediate
    input [       NB-1:0] i_data_a,
    input [       NB-1:0] i_data_b,
    input [       NB-1:0] i_extension_result,
    input                 i_branch,
    input [2   :   0]     i_word_size


    output [2   :   0]         o_word_size,
    output                     o_branch,
    output reg [ NB_FCODE-1:0] o_instruction_funct_code,
    output reg [NB_OPCODE-1:0] o_instruction_op_code,
    output reg                 o_alu_src,                 // 0 data_b, 1 immediate
    output reg [       NB-1:0] o_data_a,
    output reg [       NB-1:0] o_data_b,
    output reg [       NB-1:0] o_extension_result
);

  always @(negedge i_clk) begin
    if (i_reset) begin
      o_instruction_funct_code <= 0;
      o_instruction_op_code <= 0;
      o_alu_src <= 0;
      o_branch <= 0;
      o_data_a <= 0;
      o_data_b <= 0;
      o_word_size <= 0;
      o_extension_result <= 0;
    end else begin
      if (i_step) begin
        o_instruction_funct_code <= i_instruction_funct_code;
        o_instruction_op_code <= i_instruction_op_code;
        o_alu_src <= i_alu_src;
        o_branch <= i_branch;
        o_data_a <= i_data_a;
        o_data_b <= i_data_b;
        o_word_size <= i_word_size;
        o_extension_result <= i_extension_result;
      end
    end
  end

endmodule
