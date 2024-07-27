`timescale 1ns / 1ps
`include "memory_constants.vh"

module write_adapter #(
    parameter NB_DATA = 32,
    parameter NB_TYPE = 3
) (
    input [NB_TYPE-1:0] i_word_size,
    input [NB_DATA-1:0] i_data_in,
    output reg [NB_DATA-1:0] o_data_in
);

  always @(*) begin
    case (i_word_size)
      `BYTE_WORD: o_data_in = {24'b0, i_data_in[7:0]};
      `HALF_WORD: o_data_in = {16'b0, i_data_in[15:0]};
      `COMPLETE_WORD: o_data_in = i_data_in;
      default: o_data_in = 32'b0;
    endcase
  end

endmodule
