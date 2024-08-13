`timescale 1ns / 1ps

module WRITE_BACK #(
    parameter NB = 32,
    parameter NB_REG = 5
) (
    input i_mem_to_reg,  // MUX selector de ALU RESULT y VALOR OBTENIDO DE LA MEMORIA
    input i_last_register_ctrl,
    input [NB-1:0] i_mem_data,  // i_mem_to_reg = 1
    input [NB-1:0] i_alu_result,  // i_mem_to_reg = 0
    input [NB-1:0] i_pc4,

    output [NB-1:0] o_data_to_write_in_register  // Valor que se escribe
);

    wire [NB-1:0] w_data_to_write_in_register;

  mux2 mux2_10 (
      .i_sel(i_mem_to_reg),
      .i_data_a(i_alu_result),
      .i_data_b(i_mem_data),
      .o_data(w_data_to_write_in_register)
  );

  mux2 mux2_11 (
      .i_sel(i_last_register_ctrl),
      .i_data_a(w_data_to_write_in_register),
      .i_data_b(i_pc4 + 4),
      .o_data(o_data_to_write_in_register)
  );


endmodule

