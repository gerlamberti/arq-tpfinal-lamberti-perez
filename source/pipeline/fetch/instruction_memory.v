`timescale 1ns / 1ps

module instruction_memory
    #(
        parameter NB     = 32,
        parameter TAM    = 256
    )
    (
        input   wire                        i_clk,
        input   wire                        i_reset,
        input   wire                        i_step,
        input   wire                        i_instruction_write,
        input   wire    [NB-1:0]            i_pc,
        input   wire    [NB-1:0]            i_instruction,
        input   wire    [NB-1:0]            i_address_memory_ins,
        output  reg     [NB-1:0]            o_instruction   
    );
    
    reg     [NB-1  :0]     memory[TAM-1:0];
    integer                   i;

endmodule
