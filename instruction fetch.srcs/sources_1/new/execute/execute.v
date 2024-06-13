`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2024 16:16:18
// Design Name: 
// Module Name: execute
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


module execute #(
    parameter   WIDTH              = 32,
    parameter   WIDTH_FCODE        = 6,
    parameter   WIDTH_OPCODE       = 6,
    parameter   WIDTH_ALU_CTRLI    = 4
)(
    input [WIDTH-1:0] i_memA,
    input [WIDTH-1:0] i_memB,
    input [WIDTH_OPCODE-1:0] i_op_code,
    input [WIDTH_FCODE-1:0] i_func_code,
    output [WIDTH-1:0] o_alu_result
    );
    
    wire [WIDTH_ALU_CTRLI-1:0] alu_ctrl;
    
    alu_control #(
        .WIDTH_FCODE(WIDTH_FCODE),
        .WIDTH_OPCODE(WIDTH_OPCODE),
        .WIDTH_ALU_CTRLI(WIDTH_ALU_CTRLI)
    ) alu_control(
        .i_funct_code(i_func_code),
        .i_op_code(i_op_code),
        .o_alu_ctrl(alu_ctrl)
    );
    
    ALU #(
        .BUS_SIZE(WIDTH)
    ) ALU (
        .i_A(i_memA), 
        .i_B(i_memB),
        .i_alu_ctrl(alu_ctrl),
        .o_salida(o_alu_result)
    );
endmodule
