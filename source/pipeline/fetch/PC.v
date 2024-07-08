`timescale 1ns / 1ps

module PC 
    #(
        parameter NB = 32
    )
    (
        input   wire                i_clk,
        input   wire                i_reset,
        input   wire                i_step,
        input   wire                i_pc_write,
        input   wire    [NB-1:0]    i_new_pc,
        output  wire    [NB-1:0]    o_pc,
        output  wire    [NB-1:0]    o_pc_4,
        output  wire    [NB-1:0]    o_pc_8
    );

    reg [NB-1:0]    pc;

    initial begin
        pc = {NB{1'b0}};
    end
    
    always @(posedge i_clk) begin
        if (i_reset) begin
            pc <= {NB{1'b0}};
        end
        else if (i_pc_write & i_step) begin
            pc <= i_new_pc;
        end
    end
    
    assign  o_pc     =   pc;// burbuja       
    assign  o_pc_4   =   pc + 4;// incremento normal
    assign  o_pc_8   =   pc + 8;// JAL instruccion

endmodule
