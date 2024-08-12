`timescale 1ns / 1ps

module PC #(
    parameter NB = 32
) (
    input           i_clk,
    input           i_reset,
    input           i_stall_pc,  // From stall unit
    input           i_step,
    input           i_pc_write,
    input  [NB-1:0] i_new_pc,
    output [NB-1:0] o_pc,
    output [NB-1:0] o_pc_4,
    output [NB-1:0] o_pc_8
);

  reg [NB-1:0] pc;

  initial begin
    pc = {NB{1'b0}};
  end

  always @(posedge i_clk) begin
    if (i_reset) pc <= {NB{1'b0}};
    else if (i_stall_pc) pc <= pc;
    else if (i_pc_write & i_step) pc <= i_new_pc;
    else pc <= pc;
  end

  assign o_pc   = pc;  // burbuja       
  assign o_pc_4 = pc + 4;  // incremento normal
  assign o_pc_8 = pc + 8;  // JAL instruccion

endmodule
