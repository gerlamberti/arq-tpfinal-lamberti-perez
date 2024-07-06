`timescale 1ns / 1ps


module program_counter #(
    parameter   NB = 32
) (
    input   i_clock,
    input   i_reset, // Si viene en 1 resetea a 0 el PC
    input   i_write_new_pc, // Decide si se guarda el nuevo PC 
    input   [NB-1: 0] i_new_pc, // Si i_write_new_pc = 1 se queda con este PC, sino se queda con el previo.
    output reg [NB-1: 0] o_pc
    // TODO: falta la posibilidad de saltar (o_pc_4, o_pc_8)
);

    always@(posedge i_clock) begin
        if(i_reset) begin
            o_pc <= {NB{1'b0}};
        end
        if (i_write_new_pc) begin
            o_pc <= i_new_pc;
        end else begin
            o_pc <= o_pc;
        end
    end

endmodule