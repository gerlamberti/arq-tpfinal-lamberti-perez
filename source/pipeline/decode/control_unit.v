`timescale 1ns/1ps
`include "instruction_constants.vh"
`include "decode_constants.vh"

module control_unit #(
        parameter NB = 6
    )(
        input   wire    [NB-1:0]        i_Instruction,
        input   wire    [NB-1:0]        i_Special,
        output  reg                     o_ALUSrc,
        output  reg                     o_mem_read,
        output  reg                     o_mem_write,
        output  reg                     o_reg_write,
        output  reg    [1   :   0]      o_ExtensionMode
    );

// `define ADDI_OPCODE 6'b001000
// `define ANDI_OPCODE  6'b001100 

    always @(*) begin
        case(i_Instruction)
            `RTYPE_OPCODE: begin
                o_ALUSrc          <=  `RT_ALU_SRC;
                o_ExtensionMode   <=  `SIGNED_EXTENSION_MODE;
                o_mem_read        <=  1'b0;
                o_mem_write       <=  1'b0 ;
                o_reg_write       <=  1'b0 ;
            end

            `ADDI_OPCODE: begin
                o_ALUSrc          <=  `INMEDIATE_ALU_SRC;
                o_ExtensionMode   <=  `SIGNED_EXTENSION_MODE;
                o_mem_read        <=  1'b0;
                o_mem_write       <=  1'b0;
                o_reg_write       <=  1'b1;
            end

            `ANDI_OPCODE: begin
                o_ALUSrc          <=  `INMEDIATE_ALU_SRC;
                o_ExtensionMode   <=  `UNSIGNED_EXTENSION_MODE;
                o_mem_read        <=  1'b0;
                o_mem_write       <=  1'b0;
                o_reg_write       <=  1'b1;
            end
            default: begin    
                o_ALUSrc          <=  `RT_ALU_SRC;
                o_ExtensionMode   <=  `SIGNED_EXTENSION_MODE;
                o_mem_read        <=  1'b0;
                o_mem_write       <=  1'b0 ;
                o_reg_write       <=  1'b0 ;
            end
        endcase
    end
endmodule