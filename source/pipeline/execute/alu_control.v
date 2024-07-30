`timescale 1ns / 1ps
`include "instruction_constants.vh"
`include "execute_constants.vh"

module alu_control #(
    parameter NB_FCODE     = 6,
    parameter NB_OPCODE    = 6,
    parameter NB_ALU_OP = 4
) (
    input [NB_FCODE-1 : 0] i_funct_code,  // Codigo de funcion para instrucciones tipo R
    input [NB_OPCODE-1 : 0] i_instruction_opcode,  // opcode. Tambien viene desde la instruccionn
    output reg [NB_ALU_OP-1 : 0] o_alu_operation   // Senial que indica a la ALU que tipo de operacion ejecutar
);
    localparam DEFAULT_ALU_OPERATION = 0;
    always @(*) begin
        o_alu_operation = DEFAULT_ALU_OPERATION; // Para evitar inferred latches

        case(i_instruction_opcode)
            `RTYPE_OPCODE: begin // Se llama Rtype porque se usan registros en las operaciones
                case (i_funct_code)
                    `ADD_FCODE: o_alu_operation = `ADD;
                    `ADDU_FCODE: o_alu_operation = `ADD;
                    `SUB_FCODE: o_alu_operation = `SUB;
                    `SUBU_FCODE: o_alu_operation = `SUB;
                    `AND_FCODE: o_alu_operation = `AND;
                    `OR_FCODE: o_alu_operation = `OR;
                    `XOR_FCODE: o_alu_operation = `XOR;
                    `NOR_FCODE: o_alu_operation = `NOR;
                    `SLT_FCODE: o_alu_operation = `SLT;
                    `SLL_FCODE: o_alu_operation = `SLL;
                    `SRL_FCODE: o_alu_operation = `SRL;
                    `SRA_FCODE: o_alu_operation = `SRA;
                    default: o_alu_operation = DEFAULT_ALU_OPERATION;  
                endcase 
            end    
            `ADDI_OPCODE: o_alu_operation = `ADD;
            `BEQ_OPCODE: o_alu_operation = `SUB;
            `BNE_OPCODE: o_alu_operation = `BNE;
            `SW_OPCODE: o_alu_operation = `ADD;
            `LW_OPCODE: o_alu_operation = `ADD;
            default: o_alu_operation = DEFAULT_ALU_OPERATION;
        endcase

    end
endmodule
