`timescale 1ns / 1ps

// TODO: renombrar a regiter_memory
module register_file #(
    parameter REGS = 5,
    parameter NB   = 32,
    parameter TAM  = 32
) (
    input wire i_clk,
    input wire i_reset,
    input wire i_step,

    input            i_wb_reg_write,
    input [  NB-1:0] i_wb_write_data,
    input [REGS-1:0] i_wb_reg_dir,

    input  wire [REGS-1:0] i_dir_rs,    //Leer registro 1
    input  wire [REGS-1:0] i_dir_rt,    //Leer registro 2
    input  wire [REGS-1:0] i_RegDebug,  //Leer registro debug
    output reg  [  NB-1:0] o_data_rs,   // Dato leido 1
    output reg  [  NB-1:0] o_data_rt,   // Dato leido 2
    output reg  [  NB-1:0] o_RegDebug
);

  reg     [NB-1:0] memory[TAM-1:0];
  reg     [NB-1:0] rs;
  reg     [NB-1:0] rt;
  integer          i;

  initial begin
    for (i = 0; i < TAM; i = i + 1) begin
      memory[i] = i;
    end
  end


  always @(*) begin
    o_data_rs  = memory[i_dir_rs];
    o_data_rt  = memory[i_dir_rt];
    o_RegDebug = memory[i_RegDebug];
  end


  always @(posedge i_clk) begin
    if (i_reset) begin
      for (i = 0; i < TAM; i = i + 1) begin
        memory[i] <= i; // TODO: Acordarse de dejar esto en 0 cuando presentemos
      end
    end
    if (i_step) begin
      if (i_wb_reg_write) begin
        memory[i_wb_reg_dir] <= i_wb_write_data;
      end
    end
  end
endmodule

