`timescale 1ns / 1ps

module branch_addr #(
    parameter NB = 32
) (
    input      [NB-1:0] i_extension_result,
    input      [NB-1:0] i_pc4,
    output reg [NB-1:0] o_branch_addr
);

  always @(*) begin
    o_branch_addr <= (i_extension_result << 2) + i_pc4;
  end

endmodule
