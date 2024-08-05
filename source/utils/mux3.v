`timescale 1ps / 1ps

module mux3 #(
    parameter NB = 32
) (
    input wire [NB-1:0] i_data_a,
    input wire [NB-1:0] i_data_b,
    input wire [NB-1:0] i_data_c,
    input wire [1:0] i_sel,
    output reg [NB-1:0] o_data
);

always @(*) begin
    case(i_sel)
        2'b00: o_data = i_data_a;
        2'b01: o_data = i_data_b;
        default: o_data = i_data_c;
    endcase
end
endmodule
