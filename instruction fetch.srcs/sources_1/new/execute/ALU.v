`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2024 17:31:31
// Design Name: 
// Module Name: ALU
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



module ALU 
#(
    parameter BUS_SIZE = 32
)
(
    input wire [BUS_SIZE-1:0] i_A, 
    input wire [BUS_SIZE-1:0] i_B,
    input wire [3:0] i_alu_ctrl,
    output wire o_zero,
    output wire  [BUS_SIZE-1:0] o_salida
);

    reg [BUS_SIZE-1:0] temporal;
    reg zero_reg;

always @(*) 
    begin
        // Saco los valores de alu_ctrl de la tabla de la pagina 316
        case(i_alu_ctrl)
            // AND
            4'b0000:
                temporal = i_A & i_B;
            // OR
            4'b0001:
                temporal = i_A | i_B;
            // XOR
            4'b0011:
                temporal = i_A ^ i_B;  
            // ADDU - ADD
            4'b0010:
                temporal = i_A + i_B;
            // SUBU - SUB 
            4'b0110:
                temporal = i_A - i_B;   
            // NOR
            4'b1100:
                temporal = ~(i_A | i_B);          
            // SLL Shift left logical (A<<B) es igual que SLLV
            4'b1101: 
                temporal = i_A << i_A;
            // SRL Shift right logical (r1>>r2) es igual que SRLV
            4'b1110:
                temporal =  $signed(i_A)>>>i_B;
            // SRA  Shift right arithmetic (r1>>>r2) es igual que SRAV
            4'b1111:
                temporal =   i_A >>> i_B; 
            // SLT
            4'b0111:
                temporal = i_A < i_B;
            // not EQ          
            4'b0111:
                temporal = i_A != i_B;
            // EQ
            4'b1000:
                temporal = i_A == i_B;
            // LUI
            4'b1001:
                temporal = i_A << 16; 
            default:
                temporal = {4{1'b0}};
        endcase
    end
    
    assign o_zero = temporal == 0;
    assign o_salida[BUS_SIZE-1:0] = temporal[BUS_SIZE-1:0];			    

endmodule
