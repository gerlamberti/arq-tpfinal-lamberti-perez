`timescale 1ns / 1ps
`include "instruction_constants.vh"

module instruction_memory #(
    parameter NB  = 32,
    parameter TAM = 256
) (
    input  wire          i_clk,
    input  wire          i_reset,
    input  wire          i_step,
    input  wire [NB-1:0] i_pc,
    output reg  [NB-1:0] o_instruction
);

  reg     [NB-1:0] memory[TAM-1:0];
  integer          i;

  initial begin
    for (i = 0; i < TAM; i = i + 1) begin
      memory[i] = 0;
    end
  end

  initial begin
    `include "override_instructions.vh"
  end


  // Leer el valor de la tabla de búsqueda en función de la dirección
  always @(*) begin
    o_instruction = memory[i_pc[31:2]];
  end

endmodule
