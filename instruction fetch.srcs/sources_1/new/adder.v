`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2024 16:22:03
// Design Name: 
// Module Name: adder
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


module adder #(
        parameter WIDTH = 32
    )(
        input [WIDTH-1:0] i_A,
        input [WIDTH-1:0] i_B,
        output [WIDTH-1:0] o_Result
    );
    
    assign o_Result = i_A + i_B;
endmodule
