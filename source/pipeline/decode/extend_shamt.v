`timescale 1ns / 1ps

module extensor_shamt #(
    parameter NB = 32,
    parameter REGS = 5
)(
    input [REGS - 1 : 0] i_shamt,
    output reg [NB - 1 : 0] o_shamt
);

always @(*) begin
    o_shamt = {27'b0, i_shamt};
end

    
endmodule
