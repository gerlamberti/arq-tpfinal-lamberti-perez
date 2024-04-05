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
    input wire [5:0] i_Op,
    output wire  [BUS_SIZE-1:0] o_salida
);

    reg [BUS_SIZE-1:0] temporal;

always @(*) 
    begin
        case(i_Op)
            // SLL Shift left logical (r1<<r2) es igual que SLLV
            6'b000000, 6'b000100: 
                temporal = i_B << i_A;
            // SRL Shift right logical (r1>>r2) es igual que SRLV
            6'b000010, 6'b000110:
                temporal =  $signed(i_A)>>>i_B;
            // SRA  Shift right arithmetic (r1>>>r2) es igual que SRAV
            6'b000011, 6'b000111:
                temporal =   i_A >>> i_B;
            // ADD - ADDU (100001)
            6'b100000, 6'b100001:
                temporal = i_A + i_B;
            // SUB - SUBU
            6'b100010, 6'b100011:
                temporal = i_A - i_B;
            // AND
            6'b100100:
                temporal = i_A & i_B;
            // OR
            6'b100101:
                temporal = i_A | i_B;
            // XOR
            6'b100110:
                temporal = i_A ^ i_B;
            // NOR
            6'b100111:
                temporal = ~(i_A | i_B);
            // SLT
            6'b101010:
                temporal = i_A < i_B;
            // BEQ: Invertida porque AND a la entrada espera un 1 para saltar
            // ***********************************************
            6'b000100: // ES EL MISMO OPCODE QUE SLLV - OJO!!
            // ***********************************************
                temporal = i_A != i_B;
            // BNEQ: Invertida
            6'b000101:
                temporal =   i_A == i_B; 
            default:
                temporal = {1'b1, {5{1'b0}} };
        endcase
    end
    
    assign o_salida[BUS_SIZE-1:0] = temporal[BUS_SIZE-1:0];			    

endmodule
