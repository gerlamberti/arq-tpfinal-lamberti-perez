`timescale 1ns / 1ps

module memory_data #(
    parameter NB  = 32,
    parameter TAM = 16,
    parameter NB_ADDR = $clog2(TAM)
) (
    input i_clk,
    input i_reset,
    input i_step,
    input [NB_ADDR : 0] i_alu_address, // TODO: revisar si Lo implementamos como un selector (no un address)
    input [NB-1 : 0] i_data_to_write,
    input i_mem_write,
    input [NB_ADDR : 0] i_debug_address,
    input i_mem_read,

    output reg [NB-1 : 0] o_alu_address_data,
    output reg [NB-1 : 0] o_debug_address_data
);

  reg     [NB-1 : 0] memory[TAM-1:0];

  integer            i;

  initial begin
    for (i = 0; i < TAM; i = i + 1) begin
      memory[i] <= i;
    end
    o_debug_address_data <= 0;
  end

  always @(posedge i_clk) begin
    if (i_step) begin
      if (i_mem_write) begin
        memory[i_alu_address] <= i_data_to_write;
      end
      if (i_mem_read) begin
        o_alu_address_data <= memory[i_alu_address];
      end else o_alu_address_data <= 0;
    end
  end
  
  always @(*) 
    o_debug_address_data = memory[i_debug_address];


endmodule
