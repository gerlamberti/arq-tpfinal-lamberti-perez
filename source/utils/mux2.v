`timescale 1ps / 1ps

module mux2 #(
    parameter NB = 32
) (
    input wire [NB-1:0] i_data_a,
    input wire [NB-1:0] i_data_b,
    input wire i_sel,
    output wire [NB-1:0] o_data
);

  assign o_data = i_sel ? i_data_b : i_data_a;
endmodule
