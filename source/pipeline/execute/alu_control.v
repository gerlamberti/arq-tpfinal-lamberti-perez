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
    output reg [NB_ALU_OP-1 : 0] o_alu_operation,   // Senial que indica a la ALU que tipo de operacion ejecutar
    output reg                   o_shamt_ctrl
);
    localparam DEFAULT_ALU_OPERATION = 0;
    localparam DEFAULT_SHAMT_CTRL = 0;

    always @(*) begin
        o_alu_operation = DEFAULT_ALU_OPERATION; // Para evitar inferred latches
        o_shamt_ctrl = DEFAULT_SHAMT_CTRL;

        case(i_instruction_opcode)
            `RTYPE_OPCODE: begin // Se llama Rtype porque se usan registros en las operaciones
                case (i_funct_code)
                    `ADD_FCODE: begin
                        o_alu_operation = `ADD;
                        o_shamt_ctrl = 1'b0;
                    end
                    `ADDU_FCODE: begin
                        o_alu_operation = `ADD;
                        o_shamt_ctrl = 1'b0;
                    end
                    `SUB_FCODE: begin
                        o_alu_operation = `SUB;
                        o_shamt_ctrl = 1'b0;
                    end
                    `SUBU_FCODE: begin
                        o_alu_operation = `SUB;
                        o_shamt_ctrl = 1'b0;
                    end
                    `AND_FCODE: begin
                        o_alu_operation = `AND;
                        o_shamt_ctrl = 1'b0;
                    end
                    `OR_FCODE: begin
                        o_alu_operation = `OR;
                        o_shamt_ctrl = 1'b0;
                    end
                    `XOR_FCODE: begin
                        o_alu_operation = `XOR;
                        o_shamt_ctrl = 1'b0;
                    end
                    `NOR_FCODE: begin
                        o_alu_operation = `NOR;
                        o_shamt_ctrl = 1'b0;
                    end
                    `SLT_FCODE: begin
                        o_alu_operation = `SLT;
                        o_shamt_ctrl = 1'b0;
                    end
                    `SLL_FCODE: begin
                        o_alu_operation = `SLL;
                        o_shamt_ctrl = 1'b1;
                    end
                    `SRL_FCODE: begin
                        o_alu_operation = `SRL;
                        o_shamt_ctrl = 1'b1;
                    end
                    `SRA_FCODE: begin
                        o_alu_operation = `SRA;
                        o_shamt_ctrl = 1'b1;
                    end
                    `SLLV_FCODE: begin
                        o_alu_operation = `SLL;
                        o_shamt_ctrl = 1'b0;
                    end
                    `SRLV_FCODE: begin
                        o_alu_operation = `SRL;
                        o_shamt_ctrl = 1'b0;
                    end
                    `SRAV_FCODE: begin
                        o_alu_operation = `SRA;
                        o_shamt_ctrl = 1'b0;
                    end
                    default: begin
                        o_alu_operation = DEFAULT_ALU_OPERATION;
                        o_shamt_ctrl = 1'b0;  
                    end
                endcase 
            end    
            `ADDI_OPCODE: begin 
                o_alu_operation = `ADD;
                o_shamt_ctrl = 1'b0;  
            end
            `BEQ_OPCODE: begin 
                o_alu_operation = `SUB;
                o_shamt_ctrl = 1'b0;  
            end
            `BNE_OPCODE: begin 
                o_alu_operation = `BNE;
                o_shamt_ctrl = 1'b0;  
            end
            `ANDI_OPCODE: begin 
                o_alu_operation = `AND;
                o_shamt_ctrl = 1'b0;  
            end
            `ORI_OPCODE: begin 
                o_alu_operation = `OR;
                o_shamt_ctrl = 1'b0;  
            end
            `XORI_OPCODE: begin 
                o_alu_operation = `XOR;
                o_shamt_ctrl = 1'b0;  
            end
            `LUI_OPCODE: begin 
                o_alu_operation = `LUI; //`SLL16;
                o_shamt_ctrl = 1'b0;  
            end
            `SLTI_OPCODE: begin 
                o_alu_operation = `SLT;
                o_shamt_ctrl = 1'b0;  
            end

            `SW_OPCODE: begin 
                o_alu_operation = `ADD;
                o_shamt_ctrl = 1'b0;  
            end
            `LW_OPCODE: begin 
                o_alu_operation = `ADD;
                o_shamt_ctrl = 1'b0;  
            end
            default: begin
                o_alu_operation = DEFAULT_ALU_OPERATION;
                o_shamt_ctrl = DEFAULT_SHAMT_CTRL;
            end
        endcase

    end
endmodule
