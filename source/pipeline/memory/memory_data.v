`timescale 1ns / 1ps

module memory_data #(
    parameter NB  = 32,
    parameter TAM = 16,
    parameter NB_SIZE_TYPE = 3
) (
    input i_clk,
    input i_reset,
    input i_step,
    input [NB -1 : 0] i_alu_address, // TODO: revisar si Lo implementamos como un selector (no un address)
    input [NB-1 : 0] i_data_to_write,
    input i_mem_write,
    input [NB -1: 0] i_debug_address,
    input i_mem_read,

    output reg [NB-1 : 0] o_alu_address_data,
    output reg [NB-1 : 0] o_debug_address_data
);

  localparam NB_SELECTOR = $clog2(TAM);
  reg     [NB-1 : 0] memory[TAM-1:0];

  integer            i;
  wire [NB_SELECTOR-1:0] address_to_selector = i_alu_address>>2;


  initial begin
    for (i = 0; i < TAM; i = i + 1) begin
      memory[i] <= i;
    end
    o_debug_address_data <= 0;
  end

  always @(posedge i_clk) begin
    if (i_reset) begin
        for (i = 0; i < TAM; i = i + 1) begin
          memory[i] <= i; // TODO: dejar en 0 cuando presentemos
        end
    end
    if (i_step) begin:step_block
      if (i_mem_write) begin
        memory[address_to_selector] <= i_data_to_write;
      end
      if (i_mem_read) begin
        o_alu_address_data <= memory[address_to_selector];
      end else o_alu_address_data <= 0;
    end
  end
  
  always @(*) 
    o_debug_address_data = memory[i_debug_address>>2];


endmodule
