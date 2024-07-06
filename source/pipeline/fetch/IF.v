`timescale  1ns / 1ps

module IF  #(
    parameter NB = 32
)(
    input   wire                    i_clk,
    input   wire                    i_step,
    input   wire                    i_reset,
    input   wire                    i_PC_write,    
    output  wire    [NB-1:0]        o_IF_pc
);
    
    wire    [NB-1:0]    pc_o;
    
    assign o_IF_pc = pc_o;
    
    PC 
    #(
        .NB     (NB)
    )
    u_PC
    (
        .i_clk      (i_clk),
        .i_step     (i_step),
        .i_reset    (i_reset),
        .i_PC_write (i_PC_write),
        .i_new_pc   (pc_o),
        .o_pc       (pc_o)
    );
    
    instruction_memory
    #(
        .NB         (NB)
    )
    u_instruction_memory
    (
        .i_clk      (i_clk),
        .i_step     (i_step),
        .i_reset    (i_reset)
    );
    
endmodule