`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2024 18:10:59
// Design Name: 
// Module Name: instruction_fetch
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


module instruction_fetch #(
    parameter WIDTH = 32
) (
    input i_clock,
    output [WIDTH-1:0] o_pc
);
    wire [WIDTH-1:0] i_A;
    wire [WIDTH-1:0] i_B = 32'd4;
    wire [WIDTH-1:0] o_Result;
       
    wire [WIDTH-1:0] i_next_pc;

    

    adder adder (
        .i_A(o_pc),
        .i_B(i_B),
        .o_Result(o_Result)
    );
    
    program_counter program_counter(
        .i_next_pc(o_Result),
        .i_clock(i_clock),
        .o_pc(o_pc)
    );
endmodule
