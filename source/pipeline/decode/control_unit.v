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
    input i_flush,

    output reg                      o_alu_src,
    output reg                      o_mem_read,
    output reg                      o_mem_write,
    output reg                      o_mem_to_reg,
    output reg                      o_reg_write,
    output reg [       NB_REGS-1:0] o_reg_dir_to_write,
    output reg                      o_branch,
    output reg                      o_jump,
    output reg                      o_halt,
    output reg                      o_jr_jalr,
    output reg                      o_signed,            // solo usado para loads
    output reg [             1 : 0] o_ExtensionMode,
    output reg [NB_SIZE_TYPE-1 : 0] o_word_size
);
  wire [NB_OPCODE-1:0] i_opcode = i_instruction[31:26];
  wire [  NB_REGS-1:0] i_rs = i_instruction[25:21];
  wire [  NB_REGS-1:0] i_rt = i_instruction[20:16];
  wire [  NB_REGS-1:0] i_rd = i_instruction[15:11];
  wire [NB_OPCODE-1:0] i_func_code = i_instruction[5:0];

  `define RESET_BLOCK \
    o_alu_src <= `RT_ALU_SRC; \
    o_mem_read <= 0; \
    o_mem_write <= 0; \
    o_mem_to_reg <= 0; \
    o_reg_write <= 0; \
    o_reg_dir_to_write <= 0; \
    o_branch <= 0; \
    o_jump <= 0; \
    o_halt <= 0; \
    o_ExtensionMode <= `SIGNED_EXTENSION_MODE; \
    o_signed <= 0; \
    o_jr_jalr <= 0; \
    o_word_size <= `COMPLETE_WORD;


  always @(*) begin
    `RESET_BLOCK
    if (i_flush) begin
      `RESET_BLOCK
    end else if (i_instruction == `HALT_INSTRUCTION) begin
      o_halt <= 1'b1;
    end else begin
      case (i_opcode)
        `RTYPE_OPCODE: begin
          o_alu_src           <= `RT_ALU_SRC;
          o_ExtensionMode    <= `SIGNED_EXTENSION_MODE;
          o_mem_read         <= 1'b0;
          o_mem_write        <= 1'b0;
          o_reg_write        <= 1'b1;
          o_branch           <= 1'b0;
          o_jump             <= 1'b0;
          o_word_size        <= 3'b000;
          o_reg_dir_to_write <= i_rd;
        
          if(i_func_code == `JALR_FUNCT) begin
              o_jr_jalr <= 1'b1; // Ambas escriben en el PC=$rs
              o_reg_dir_to_write <= 5'd31;
          end else if (i_func_code == `JR_FUNCT) begin
              o_jr_jalr <= 1'b1; // Ambas escriben en el PC=$rs
          end else begin
              o_jr_jalr <= 1'b0;
          end

        end
        `ADDI_OPCODE, `SLTI_OPCODE: begin
          o_alu_src           <= `INMEDIATE_ALU_SRC;
          o_ExtensionMode    <= `SIGNED_EXTENSION_MODE;
          o_mem_read         <= 1'b0;
          o_mem_write        <= 1'b0;
          o_reg_write        <= 1'b1;
          o_word_size        <= 3'b000;
          o_reg_dir_to_write <= i_rt;


        end
        `ANDI_OPCODE, `ORI_OPCODE, `XORI_OPCODE, `LUI_OPCODE: begin
          o_alu_src           <= `INMEDIATE_ALU_SRC;
          o_ExtensionMode    <= `UNSIGNED_EXTENSION_MODE;
          o_mem_read         <= 1'b0;
          o_mem_write        <= 1'b0;
          o_reg_write        <= 1'b1;
          o_word_size        <= 3'b000;
          o_reg_dir_to_write <= i_rt;
        end

        `BEQ_OPCODE, `BNE_OPCODE: begin
          o_alu_src        <= `RT_ALU_SRC;
          o_ExtensionMode <= `SIGNED_EXTENSION_MODE;
          o_branch        <= 1'b1;
        end
        `J_OPCODE: begin
          o_jump <= 1'b1;
        end
        `JAL_OPCODE:begin
          o_mem_read          <= 1'b0; // no read mem
          o_mem_write         <= 1'b0; // no write mem
          o_reg_write         <= 1'b1; // escribe en rt
          o_jump              <= 1'b1; // TODO: ver si se necesta señal que haga $ra=PC+4
          o_reg_dir_to_write  <= 5'd31;
        end

        `SB_OPCODE: begin
          o_alu_src    <= `INMEDIATE_ALU_SRC;
          o_mem_read  <= 1'b0;  // no read mem
          o_mem_write <= 1'b1;  // write mem
          o_word_size <= `BYTE_WORD;
        end
        `SH_OPCODE: begin
          o_alu_src    <= `INMEDIATE_ALU_SRC;
          o_mem_read  <= 1'b0;  // no read mem
          o_mem_write <= 1'b1;  // write mem
          o_word_size <= `HALF_WORD;
        end
        `SW_OPCODE: begin
          o_alu_src    <= `INMEDIATE_ALU_SRC;
          o_mem_read  <= 1'b0;
          o_mem_write <= 1'b1;
          o_word_size <= `COMPLETE_WORD;
        end
        `LB_OPCODE: begin
          o_alu_src           <= `INMEDIATE_ALU_SRC;  // immediate
          o_ExtensionMode    <= `SIGNED_EXTENSION_MODE;
          o_signed           <= 1'b1;  // solo se usa en los loads
          o_mem_read         <= 1'b1;  // read mem
          o_mem_write        <= 1'b0;  // no write mem
          o_mem_to_reg       <= 1'b1;  // read salida data memory
          o_reg_write        <= 1'b1;  // escribe en rt
          o_reg_dir_to_write <= i_rt;  // rt
          o_word_size        <= `BYTE_WORD;
        end
        `LBU_OPCODE: begin
          o_alu_src           <= `INMEDIATE_ALU_SRC;  // immediate
          o_ExtensionMode    <= `UNSIGNED_EXTENSION_MODE;
          o_signed           <= 1'b0;
          o_mem_read         <= 1'b1;  // read mem
          o_mem_write        <= 1'b0;  // no write mem
          o_mem_to_reg       <= 1'b1;  // read salida data memory
          o_reg_write        <= 1'b1;  // escribe en rt
          o_reg_dir_to_write <= i_rt;  // rt
          o_word_size        <= `BYTE_WORD;
        end
        `LH_OPCODE: begin
          o_alu_src           <= `INMEDIATE_ALU_SRC;  // immediate
          o_ExtensionMode    <= `SIGNED_EXTENSION_MODE;
          o_signed           <= 1'b1;
          o_mem_read         <= 1'b1;  // read mem
          o_mem_write        <= 1'b0;  // no write mem
          o_mem_to_reg       <= 1'b1;  // read salida data memory
          o_reg_write        <= 1'b1;  // escribe en rt
          o_reg_dir_to_write <= i_rt;  // rt
          o_word_size        <= `HALF_WORD;
        end
        `LHU_OPCODE: begin
          o_alu_src           <= `INMEDIATE_ALU_SRC;  // immediate
          o_ExtensionMode    <= `UNSIGNED_EXTENSION_MODE;
          o_signed           <= 1'b0;
          o_mem_read         <= 1'b1;  // read mem
          o_mem_write        <= 1'b0;  // no write mem
          o_mem_to_reg       <= 1'b1;  // read salida data memory
          o_reg_write        <= 1'b1;  // escribe en rt
          o_reg_dir_to_write <= i_rt;  // rt
          o_word_size        <= `HALF_WORD;
        end
        `LW_OPCODE: begin
          o_alu_src           <= `INMEDIATE_ALU_SRC;
          o_ExtensionMode    <= `SIGNED_EXTENSION_MODE;
          o_signed           <= 1'b1;  // solo se usa en los loads
          o_mem_read         <= 1'b1;  // read mem
          o_mem_write        <= 1'b0;  // no write mem
          o_mem_to_reg       <= 1'b1;  // read salida data memory
          o_reg_write        <= 1'b1;  // escribe en rt
          o_reg_dir_to_write <= i_rt;
          o_word_size        <= `COMPLETE_WORD;
        end
        `LWU_OPCODE: begin
          o_alu_src           <= `INMEDIATE_ALU_SRC;  // immediate
          o_ExtensionMode    <= `UNSIGNED_EXTENSION_MODE;
          o_signed           <= 1'b0;
          o_mem_read         <= 1'b1;  // read mem
          o_mem_write        <= 1'b0;  // no write mem
          o_mem_to_reg       <= 1'b1;  // read salida data memory
          o_reg_write        <= 1'b1;  // escribe en rt
          o_reg_dir_to_write <= i_rt;  // rt
          o_word_size        <= `COMPLETE_WORD;
        end
        default: begin
          `RESET_BLOCK
        end
      endcase
    end
  end
endmodule
