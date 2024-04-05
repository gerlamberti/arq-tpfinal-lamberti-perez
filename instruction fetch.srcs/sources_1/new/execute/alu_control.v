`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.04.2024 17:32:43
// Design Name: 
// Module Name: alu_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`define RTYPE_OPCODE 6'h00
// Loads
`define LB_OPCODE    6'h20 
`define LH_OPCODE    6'h21 
`define LHU_OPCODE   6'h22 
`define LW_OPCODE    6'h23 
`define LWU_OPCODE   6'h24 
`define LBU_OPCODE   6'h25 
// stores
`define SB_OPCODE    6'h28 
`define SH_OPCODE    6'h29 
`define SW_OPCODE    6'h2b

`define ADDI_OPCODE  6'h08 
`define ANDI_OPCODE  6'h0c 
`define ORI_OPCODE   6'h0d 
`define XORI_OPCODE  6'h0e 
`define BEQ_OPCODE   6'h04

`define BNE_OPCODE   6'h05 
`define SLTI_OPCODE  6'h0a 
`define LUI_OPCODE   6'h0f 
`define JAL_OPCODE   6'h03 



module alu_control#(
        parameter   WIDTH_FCODE        = 6,
        parameter   WIDTH_OPCODE       = 6,
        parameter   WIDTH_ALU_CTRLI    = 4
        
    )
    (
        input      [WIDTH_FCODE-1     : 0] i_funct_code, // Codigo de funcion para instrucciones tipo R
        input      [WIDTH_OPCODE-1    : 0] i_alu_op,     // opcode
        output reg [WIDTH_ALU_CTRLI-1 : 0] o_alu_ctrl   // Senial que indica a la ALU que tipo de operacion ejecutar
    );
    
   
    always@(*) begin
        // Inicializacion para que no se produzca un inferred latch
        o_alu_ctrl = 4'h00;

        case(i_alu_op)
            `RTYPE_OPCODE: begin
                case(i_funct_code)
                        // TODO: implementar correctamente los R type
                        `SLL_FCODE   : begin
                            o_alu_ctrl = 4'h00;
                            o_shamt_ctrl = 1'b0; // Elige shamt
                            o_last_register_ctrl = 1'b0;
                        end 
                        `SRL_FCODE   : begin
                            o_alu_ctrl = 4'h01;
                            o_shamt_ctrl = 1'b0; // Elige shamt
                            o_last_register_ctrl = 1'b0;
                        end
                        `SRA_FCODE   : begin
                            o_alu_ctrl = 4'h02;
                            o_shamt_ctrl = 1'b0; // Elige shamt
                            o_last_register_ctrl = 1'b0;
                        end
                        `SLLV_FCODE  : begin
                            o_alu_ctrl = 4'h00;
                            o_shamt_ctrl = 1'b1; // Elige data_a (rs)
                            o_last_register_ctrl = 1'b0;
                        end
                        `SRLV_FCODE  : begin
                            o_alu_ctrl = 4'h01;
                            o_shamt_ctrl = 1'b1; // Elige data_a (rs)
                            o_last_register_ctrl = 1'b0;
                        end
                        `SRAV_FCODE  : begin
                            o_alu_ctrl = 4'h02;
                            o_shamt_ctrl = 1'b1; // Elige data_a (rs)
                            o_last_register_ctrl = 1'b0;
                        end
                        `ADD_FCODE   : begin
                            o_alu_ctrl = 4'h03;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `ADDU_FCODE  : begin
                            o_alu_ctrl = 4'h03;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `SUB_FCODE   : begin
                            o_alu_ctrl = 4'h04;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `SUBU_FCODE  : begin
                            o_alu_ctrl = 4'h04;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `AND_FCODE   : begin
                            o_alu_ctrl = 4'h05;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `OR_FCODE    : begin
                            o_alu_ctrl = 4'h06;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `XOR_FCODE   : begin
                            o_alu_ctrl = 4'h07;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `NOR_FCODE   : begin
                            o_alu_ctrl = 4'h08;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `SLT_FCODE   : begin
                            o_alu_ctrl = 4'h09;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `JALR_FCODE  : begin
                            o_alu_ctrl = 4'h00;
                            o_shamt_ctrl = 1'b0;
                            o_last_register_ctrl = 1'b1;
                        end
                        default     : begin
                            o_alu_ctrl = o_alu_ctrl;
                        end                      
                endcase
            end
            // Todos los loads
            `LB_OPCODE, `LH_OPCODE, `LW_OPCODE,
            `LWU_OPCODE, `LBU_OPCODE, `LHU_OPCODE,
            // Todos los stores
            `SB_OPCODE, `SH_OPCODE, `SW_OPCODE
                : begin
                o_alu_ctrl = 4'b0010;  // INSTRUCCION ITYPE - ADDI -> ADD de ALU
            end
            `ADDI_OPCODE : begin
                o_alu_ctrl = 4'b0010;
            end
            `ANDI_OPCODE : begin
                o_alu_ctrl = 4'b0000;
            end
            `ORI_OPCODE  : begin
                o_alu_ctrl = 4'b0001;
            end
            `XORI_OPCODE : begin
                o_alu_ctrl = 4'b0011;
            end
            `LUI_OPCODE  : begin
                o_alu_ctrl = 4'b1001;
            end
            `SLTI_OPCODE : begin
                o_alu_ctrl = 4'b0111;
            end
            `BEQ_OPCODE  : begin
                o_alu_ctrl = 4'b0111; // NOT EQ
            end
            `BNE_OPCODE  : begin
                o_alu_ctrl = 4'b1000; // EQ
            end
            // TODO: JAL_OPCODE
            default     : begin
                o_alu_ctrl = o_alu_ctrl;
            end
        endcase
    end
    
endmodule