`timescale 1ns / 1ps


module instruction_memory #(
    parameter NB = 32,
    parameter N_OF_INSTRUCTIONS = 64

) (
    input                   i_clock,
    input                   i_reset,
    // TODO: para hacer el paso a paso i_step
    // TODO: que se pueda escribir desde la debug unit (i_address_memory_instruction)
    input   [NB-1:0]        i_pc_address,
    output  reg [NB-1:0]    o_instruction
    );

    reg     [NB-1:0] instruction_memory_bank[N_OF_INSTRUCTIONS-1:0];

endmodule
