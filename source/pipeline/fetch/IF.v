`timescale 1ns / 1ps

module IF #(
    parameter NB    = 32,
    parameter TAM_I = 256
) (
    input          i_clk,
    input          i_step,
    input          i_reset,
    input          i_pc_write,
    input          i_branch,
    input [NB-1:0] i_branch_addr,
    input          i_jump,
    input [NB-1:0] i_jump_addr,
    input          i_instruction_write_enable,  // from debug
    input [NB-1:0] i_instruction_address,       // from debug
    input [NB-1:0] i_instruction_data,          // from debug

    output [NB-1:0] o_IF_pc,
    output [NB-1:0] o_IF_pc4,
    output [NB-1:0] o_IF_pc8,
    output [NB-1:0] o_instruction
);

  wire [NB-1:0] test_pc;
  wire [NB-1:0] pc;
  wire [NB-1:0] pc4;
  wire [NB-1:0] pc8;

  assign o_IF_pc  = pc;
  assign o_IF_pc4 = pc4;
  assign o_IF_pc8 = pc8;

  PC #(
      .NB(NB)
  ) u_PC (
      .i_clk     (i_clk),
      .i_reset   (i_reset),
      .i_step    (i_step),
      .i_pc_write(i_pc_write),
      .i_new_pc  (test_pc),
      .o_pc      (pc),
      .o_pc_4    (pc4),
      .o_pc_8    (pc8)
  );

  instruction_memory #(
      .NB (NB),
      .TAM(TAM_I)
  ) instruction_memory (
      .i_clk                     (i_clk),
      .i_reset                   (i_reset),
      .i_step                    (i_step),
      .i_pc                      (pc),
      .i_instruction_write_enable(i_instruction_write_enable),
      .i_instruction_address     (i_instruction_address),
      .i_instruction_data        (i_instruction_data),
      .o_instruction             (o_instruction)

  );

  mux_pc #(
      .NB(NB)
  ) u_mux_pc (
      .i_sumador_pc4(pc4),
      .i_branch_addr(i_branch_addr),
      .i_jump_addr  (i_jump_addr),

      .i_branch(i_branch),
      .i_jump  (i_jump),

      .o_pc(test_pc)
  );

endmodule
