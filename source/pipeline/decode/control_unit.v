`timescale 1ns / 1ps
`include "instruction_constants.vh"
`include "decode_constants.vh"

module control_unit #(
    parameter NB = 32,
    parameter NB_SIZE_TYPE = 3,
    parameter NB_REGS = 5,
    parameter NB_OPCODE = 6
) (
    input [NB-1:0] i_instruction,

    output reg                      o_ALUSrc,
    output reg                      o_mem_read,
    output reg                      o_mem_write,
    output reg                      o_reg_write,
    output reg [       NB_REGS-1:0] o_reg_dir_to_write,
    output reg                      o_branch,
    output reg                      o_jump,
    output reg [             1 : 0] o_ExtensionMode,
    output reg [NB_SIZE_TYPE-1 : 0] o_word_size
);
  wire [NB_OPCODE-1:0] i_opcode = i_instruction[31:26];
  wire [  NB_REGS-1:0] i_rs = i_instruction[25:21];
  wire [  NB_REGS-1:0] i_rt = i_instruction[20:16];
  wire [  NB_REGS-1:0] i_rd = i_instruction[15:11];
  wire [NB_OPCODE-1:0] i_func_code = i_instruction[5:0];

  always @(*) begin
    o_reg_dir_to_write <= 0;
    case (i_opcode)
      `RTYPE_OPCODE: begin
        o_ALUSrc           <= `RT_ALU_SRC;
        o_ExtensionMode    <= `SIGNED_EXTENSION_MODE;
        o_mem_read         <= 1'b0;
        o_mem_write        <= 1'b0;
        o_reg_write        <= 1'b0;
        o_branch           <= 1'b0;
        o_jump             <= 1'b0;
        o_word_size        <= 3'b000;
        o_reg_dir_to_write <= i_rd;
      end

      `ADDI_OPCODE: begin
        o_ALUSrc           <= `INMEDIATE_ALU_SRC;
        o_ExtensionMode    <= `SIGNED_EXTENSION_MODE;
        o_mem_read         <= 1'b0;
        o_mem_write        <= 1'b0;
        o_reg_write        <= 1'b1;
        o_branch           <= 1'b0;
        o_jump             <= 1'b0;
        o_word_size        <= 3'b000;
        o_reg_dir_to_write <= i_rt;

      end

      `ANDI_OPCODE: begin
        o_ALUSrc           <= `INMEDIATE_ALU_SRC;
        o_ExtensionMode    <= `UNSIGNED_EXTENSION_MODE;
        o_mem_read         <= 1'b0;
        o_mem_write        <= 1'b0;
        o_reg_write        <= 1'b1;
        o_branch           <= 1'b0;
        o_jump             <= 1'b0;
        o_word_size        <= 3'b000;
        o_reg_dir_to_write <= i_rt;
      end
      `BEQ_OPCODE: begin
        o_ALUSrc        <= `RT_ALU_SRC;
        o_ExtensionMode <= `SIGNED_EXTENSION_MODE;
        o_mem_read      <= 1'b0;
        o_mem_write     <= 1'b0;
        o_reg_write     <= 1'b0;
        o_branch        <= 1'b1;
        o_jump          <= 1'b0;
        o_word_size     <= 3'b000;
      end
      `JUMP_OPCODE: begin
        o_ALUSrc           <= `RT_ALU_SRC;
        o_ExtensionMode    <= `SIGNED_EXTENSION_MODE;
        o_mem_read         <= 1'b0;
        o_mem_write        <= 1'b0;
        o_reg_write        <= 1'b0;
        o_branch           <= 1'b0;
        o_jump             <= 1'b1;
        o_word_size        <= 3'b000;
        o_reg_dir_to_write <= i_rt;

      end
      default: begin
        o_ALUSrc           <= `RT_ALU_SRC;
        o_ExtensionMode    <= `SIGNED_EXTENSION_MODE;
        o_mem_read         <= 1'b0;
        o_mem_write        <= 1'b0;
        o_reg_write        <= 1'b0;
        o_branch           <= 1'b0;
        o_jump             <= 1'b0;
        o_word_size        <= 3'b000;
        o_reg_dir_to_write <= 0;
      end
    endcase
  end
endmodule
