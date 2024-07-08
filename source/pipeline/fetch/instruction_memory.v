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
    
    reg     [NB-1:0]     memory[TAM-1:0];
    integer              i;

    // Crea el Text Segment
    initial begin
        for (i = 0; i < TAM; i = i + 1) begin
            memory[i] = 0;
        end  
    end

    //Pone a la salida la instruccion del senialada por el PC
    always @(posedge i_clk) begin
        if (i_step)begin
            o_instruction  <= memory[i_pc];
        end
    end

    // Crea el segmento de codigo que va arrecorrer el PC.
    always @(posedge i_write_intruc) begin
        memory[i_address_memory_ins] <= i_instruction; 
    end

endmodule
