`timescale 1ns / 1ps

module ID_EX #(
    parameter NB = 32,
    parameter NB_OPCODE = 6,
    parameter NB_FCODE = 6,
    parameter NB_SIZE_TYPE = 3,
    parameter NB_REGS = 5
) (
    input                      i_clk,
    input                      i_step,
    input                      i_reset,
    input [      NB_FCODE-1:0] i_instruction_funct_code,
    input [     NB_OPCODE-1:0] i_instruction_op_code,
    input                      i_alu_src,                 // 0 data_b, 1 immediate
    input [            NB-1:0] i_data_a,
    input [            NB-1:0] i_data_b,
    input [            NB-1:0] i_shamt,
    input [            NB-1:0] i_extension_result,
    input [            NB-1:0] i_pc4,
    input                      i_branch,
    input [NB_SIZE_TYPE-1 : 0] i_word_size,
    input                      i_mem_read,
    input                      i_mem_write,
    input                      i_mem_to_reg,
    input                      i_reg_write,
    input [       NB_REGS-1:0] i_reg_dir_to_write,
    input                      i_jump,
    input                      i_signed,
    input [            NB-1:0] i_jump_addr,



    output reg                      o_signed,
    output reg [            NB-1:0] o_pc4,
    output reg [NB_SIZE_TYPE-1 : 0] o_word_size,
    output reg                      o_branch,
    output reg [      NB_FCODE-1:0] o_instruction_funct_code,
    output reg [     NB_OPCODE-1:0] o_instruction_op_code,
    output reg                      o_alu_src,                 // 0 data_b, 1 immediate
    output reg [            NB-1:0] o_data_a,
    output reg [            NB-1:0] o_data_b,
    output reg [            NB-1:0] o_shamt,
    output reg [            NB-1:0] o_extension_result,
    output reg                      o_mem_read,
    output reg                      o_mem_write,
    output reg                      o_mem_to_reg,
    output reg                      o_reg_write,
    output reg [       NB_REGS-1:0] o_reg_dir_to_write,
    output reg                      o_jump,
    output reg [            NB-1:0] o_jump_addr
);

  always @(negedge i_clk) begin
    if (i_reset) begin
      o_pc4 <= 0;
      o_word_size <= 0;
      o_branch <= 0;
      o_instruction_funct_code <= 0;
      o_instruction_op_code <= 0;
      o_alu_src <= 0;
      o_data_a <= 0;
      o_data_b <= 0;
      o_shamt <= 0;
      o_extension_result <= 0;
      o_mem_read <= 0;
      o_mem_write <= 0;
      o_mem_to_reg <= 0;
      o_reg_write <= 0;
      o_reg_dir_to_write <= 0;
      o_jump <= 0;
      o_signed <= 0;
      o_jump_addr <= 0;
    end else begin
      if (i_step) begin
        o_pc4 <= i_pc4;
        o_word_size <= i_word_size;
        o_branch <= i_branch;
        o_instruction_funct_code <= i_instruction_funct_code;
        o_instruction_op_code <= i_instruction_op_code;
        o_alu_src <= i_alu_src;
        o_data_a <= i_data_a;
        o_data_b <= i_data_b;
        o_shamt <= i_shamt;
        o_extension_result <= i_extension_result;
        o_mem_read <= i_mem_read;
        o_mem_write <= i_mem_write;
        o_mem_to_reg <= i_mem_to_reg;
        o_reg_write <= i_reg_write;
        o_reg_dir_to_write <= i_reg_dir_to_write;
        o_jump <= i_jump;
        o_signed <= o_signed;
        o_jump_addr <= i_jump_addr;
      end
    end
  end

endmodule
