`timescale 1ns / 1ps

module memory_data #(
    parameter MEM_CELL_SIZE = 32,
    parameter MAX_ADDRESS = 16,
    parameter ADDRESS_BYTES = 4 // Address size determinado x la cant de direcciones que podemos tener
) (
    input i_clock,
    input i_enable,
    input i_read_enable,
    input i_write_enable,
    input [ADDRESS_BYTES-1:0] i_address,
    input [MEM_CELL_SIZE-1:0] i_value_to_write,
    output reg [MEM_CELL_SIZE-1:0] o_read_value
);

  reg [MEM_CELL_SIZE-1:0] RAM[0:MAX_ADDRESS];

  always @(posedge i_clock) begin
    if (i_enable) begin
      if (i_write_enable) begin
        RAM[i_address] <= i_value_to_write;
      end
      if (i_read_enable) begin
        o_read_value <= RAM[i_address];
      end
    end
  end

endmodule
