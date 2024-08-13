`timescale 1ns / 1ps

module mux_pc #(
    parameter NB = 32
) (
    input       [NB-1:0] i_sumador_pc4,
    input       [NB-1:0] i_branch_addr,
    input       [NB-1:0] i_jump_addr,
    input       [NB-1:0] i_jr_jalr_addr,

    input                i_branch,
    input                i_jump,
    input                i_jr_jalr,
    
    output      [NB-1:0] o_pc
);

  reg [NB-1:0] pc;

  always @(*) begin
    if (i_branch) pc <= i_branch_addr;
    else if(i_jump) pc <= i_jump_addr;
    else if(i_jr_jalr) pc <= i_jr_jalr_addr;
    else pc <= i_sumador_pc4;
  end

  assign o_pc = pc;

endmodule
