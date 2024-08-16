`timescale 1ns / 1ps

module IF_ID #(
    parameter NB = 32
) (
    input          i_clk,
    input          i_step,
    input          i_reset,
    input [NB-1:0] i_pc4,

    // Stall unit
    input i_flush,
    input i_stall,

    input      [NB-1:0] i_instruction,
    output reg [NB-1:0] o_pc4,
    output reg [NB-1:0] o_instruction
);


  always @(negedge i_clk) begin
    if (i_reset) begin
      o_instruction <= {NB{1'b0}};
      o_pc4         <= {NB{1'b0}};
    end else if (i_flush) begin  //i_flush
      o_instruction <= i_instruction;
      o_pc4         <= i_pc4; // Cuando hay un halt no quiero que quede en cero sino en el valor en el que se halteo forever
    end else if (i_stall) begin
      o_instruction <= o_instruction;
      o_pc4         <= o_pc4;
    end else if (i_step) begin  //i_IF_ID_Write & i_step
      o_instruction <= i_instruction;
      o_pc4         <= i_pc4;
    end
    else begin
         o_instruction <= i_instruction;
         o_pc4         <= i_pc4;
    end
  end


endmodule
