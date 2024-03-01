`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2024 17:18:48
// Design Name: 
// Module Name: program_counter
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


module program_counter #(
    parameter WIDTH = 32
) (
    input [WIDTH-1:0] i_next_pc,
    input i_clock,
    output reg [WIDTH-1:0] o_pc
    );
    
    initial begin
        // Si no ponemos esto la salida
        // esta indefinida antes de que pase
        // el primer posedge en los tests
        o_pc = 0;
    end
    
    always @(posedge i_clock) begin
        o_pc <= i_next_pc;
    end
endmodule
