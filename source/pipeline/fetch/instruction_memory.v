`timescale 1ns / 1ps
`include "instruction_constants.vh"

module instruction_memory #(
    parameter NB  = 32,
    parameter TAM = 256
) (
    input               i_clk,
    input               i_reset,
    input               i_step,
    input      [NB-1:0] i_pc,
    input               i_instruction_write_enable,
    input      [NB-1:0] i_instruction_address,
    input      [NB-1:0] i_instruction_data,
    output reg [NB-1:0] o_instruction
);

  reg     [NB-1:0] memory[TAM-1:0];
  integer          i;



  initial begin
    for (i = 0; i < TAM; i = i + 1) begin
      memory[i] = 0;
    end
  end

  
// `ifndef SYNTHESIS TODO: volver a como estaba antes
  initial begin
    `include "override_instructions.vh"
  end
// `endif


  always @(negedge i_clk) begin
    if (i_instruction_write_enable) begin
      memory[i_instruction_address[31:2]] <= i_instruction_data;
    end
  end

  // Leer el valor de la tabla de búsqueda en función de la dirección
  always @(*) begin
    o_instruction = memory[i_pc[31:2]];
  end

endmodule
