`timescale 1ns / 1ps
`include "memory_constants.vh"

module read_adapter #(
    parameter NB_DATA = 32,
    parameter NB_TYPE = 3
) (
    input                    i_signed,
    input      [NB_TYPE-1:0] i_word_size,
    input      [NB_DATA-1:0] i_data_out,
    output reg [NB_DATA-1:0] o_data_out
);

  always @(*) begin
    if (i_signed) begin
      case (i_word_size)
        `BYTE_WORD: o_data_out = {{24{i_data_out[7]}}, i_data_out[7:0]};
        `HALF_WORD: o_data_out = {{16{i_data_out[15]}}, i_data_out[15:0]};
        `COMPLETE_WORD: o_data_out = i_data_out;
        default: o_data_out = 0;
      endcase
    end else begin
      case (i_word_size)
        `BYTE_WORD: o_data_out = {{24'b0}, i_data_out[7:0]};
        `HALF_WORD: o_data_out = {{16'b0}, i_data_out[15:0]};
        `COMPLETE_WORD: o_data_out = i_data_out;
        default: o_data_out = 0;
      endcase
    end
  end

endmodule
