`timescale 1ns / 1ps

module mux_pc
    #(
        parameter NB     =  32
    )
    (
        input   wire    [NB-1:0]       i_sumador_pc4,
        output  wire    [NB-1:0]       o_pc            
    );
    
    reg             [NB-1:0]    pc;

    always@(*) begin
        pc <= i_sumador_pc4;
    end

    assign o_pc = pc;

endmodule