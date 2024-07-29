`timescale 1ns / 1ps
`include "instruction_constants.vh"
`include "decode_constants.vh"
`include "memory_constants.vh"


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
    output reg                      o_mem_to_reg,
    output reg                      o_reg_write,
    output reg [       NB_REGS-1:0] o_reg_dir_to_write,
    output reg                      o_branch,
    output reg                      o_jump,
    output reg                      o_signed,            // solo usado para loads
    output reg [             1 : 0] o_ExtensionMode,
    output reg [NB_SIZE_TYPE-1 : 0] o_word_size
);
  wire [NB_OPCODE-1:0] i_opcode = i_instruction[31:26];
  wire [  NB_REGS-1:0] i_rs = i_instruction[25:21];
  wire [  NB_REGS-1:0] i_rt = i_instruction[20:16];
  wire [  NB_REGS-1:0] i_rd = i_instruction[15:11];
  wire [NB_OPCODE-1:0] i_func_code = i_instruction[5:0];

  always @(*) begin
    o_ALUSrc <= 0;
    o_mem_read <= 0;
    o_mem_write <= 0;
    o_mem_to_reg <= 0;
    o_reg_write <= 0;
    o_reg_dir_to_write <= 0;
    o_branch <= 0;
    o_jump <= 0;
    o_ExtensionMode <= 0;
    o_signed <= 0;
    o_word_size <= `COMPLETE_WORD;

    case (i_opcode)
      `RTYPE_OPCODE: begin
        o_ALUSrc           <= `RT_ALU_SRC;
        o_ExtensionMode    <= `SIGNED_EXTENSION_MODE;
        o_mem_read         <= 1'b0;
        o_mem_write        <= 1'b0;
        o_reg_write        <= 1'b1;
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
      `SW_OPCODE: begin
        o_ALUSrc        <= `INMEDIATE_ALU_SRC;
        o_mem_read      <= 1'b0;
        o_mem_write     <= 1'b1;
        o_ExtensionMode <= `SIGNED_EXTENSION_MODE;
        o_word_size     <= `COMPLETE_WORD;
      end
      `LW_OPCODE: begin
        o_ALUSrc           <= `INMEDIATE_ALU_SRC;
        o_mem_read         <= 1'b1;  // read mem
        o_mem_write        <= 1'b0;  // no write mem
        o_mem_to_reg       <= 1'b1;  // read salida data memory
        o_reg_write        <= 1'b1;  // escribe en rt
        o_signed           <= 1'b1;  // solo se usa en los loads
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
        o_word_size        <= `COMPLETE_WORD;
        o_reg_dir_to_write <= 0;
      end
    endcase
  end
endmodule
