`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2024 16:47:50
// Design Name: 
// Module Name: instruction_memory
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

/*
* Un requerimiento de este módulo es que las instrucciones estén alineadas de a 4 bytes y comiencen
* en algun address multiplo de 4 (no se pueden poner address que no sean multiplos de 4)
*/
module instruction_memory #(
    parameter WIDTH = 32,
    parameter MAX_NUM_OF_INSTRUCTIONS = 32
)(
    input [WIDTH-1:0] i_instruction_address,
    output reg [WIDTH-1:0] o_instruction
);

    reg [WIDTH-1:0] memory [0:MAX_NUM_OF_INSTRUCTIONS];
    initial begin
        o_instruction = 0;
        memory[0] = 32'h5;
        memory[1] = 32'h7a;
        memory[2] = 32'h9b;
    end;
    always @(*) begin
        // Esto hace o_instruction = memory [i_instruccion_address % 4]
        o_instruction = memory[i_instruction_address >> 2];
    end;

endmodule
