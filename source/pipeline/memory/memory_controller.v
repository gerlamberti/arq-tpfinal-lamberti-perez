`timescale 1ns / 1ps
`include "memory_constants.vh"

module memory_controller #(
    parameter NB_DATA = 32,
    parameter NB_TYPE = 3
) (
    input               i_signed,
    input               i_mem_write,
    input               i_mem_read,
    input [NB_TYPE-1:0] i_word_size,

    input [NB_DATA-1:0] i_raw_data_to_write,
    input [NB_DATA-1:0] i_raw_read_data,

    output reg [NB_DATA-1:0] o_formatted_write_data,
    output reg [NB_DATA-1:0] o_formatted_read_data
);

  always @(*) begin
    // Read
    //  Signada o Sin signar
    if (i_mem_read) begin
      // Signed
      if (i_signed) begin
        case (i_word_size)
          `BYTE_WORD: o_formatted_read_data = {{24{i_raw_read_data[7]}}, i_raw_read_data[7:0]};
          `HALF_WORD: o_formatted_read_data = {{16{i_raw_read_data[15]}}, i_raw_read_data[15:0]};
          `COMPLETE_WORD: o_formatted_read_data = i_raw_read_data;

          default: o_formatted_read_data = 32'b0;
        endcase
      end  // Sin signar
      else begin
        case (i_word_size)
          `BYTE_WORD: o_formatted_read_data = {{24'b0}, i_raw_read_data[7:0]};
          `HALF_WORD: o_formatted_read_data = {{16'b0}, i_raw_read_data[15:0]};
          `COMPLETE_WORD: o_formatted_read_data = i_raw_read_data;

          default: o_formatted_read_data = 32'b0;
        endcase
      end
    end else o_formatted_read_data = -1;

    // Write
    if (i_mem_write) begin
      case (i_word_size)
        `BYTE_WORD: o_formatted_write_data = i_raw_data_to_write[7:0];
        `HALF_WORD: o_formatted_write_data = i_raw_data_to_write[15:0];
        `COMPLETE_WORD: o_formatted_write_data = i_raw_data_to_write;

        default: o_formatted_write_data = 32'b0;
      endcase
    end else o_formatted_write_data = -1;
      end

endmodule
