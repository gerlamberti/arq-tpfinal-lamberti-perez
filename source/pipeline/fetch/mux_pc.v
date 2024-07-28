`timescale 1ns / 1ps

module mux_pc
    #(
        parameter NB     =  32
    )
    (
        input   wire    [NB-1:0]       i_sumador_pc4,
        input                          i_branch,
        input                          i_branch_addr,
        output  wire    [NB-1:0]       o_pc            
    );
    
    reg             [NB-1:0]    pc;

    always@(*) begin
        if(i_branch)
            pc <= i_branch_addr;
        else
            pc <= i_sumador_pc4;
    end

    assign o_pc = pc;

endmodule