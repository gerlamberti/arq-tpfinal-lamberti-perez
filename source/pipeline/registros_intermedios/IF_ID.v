`timescale 1ns / 1ps

module IF_ID
    #(
        parameter NB = 32
    )
    (
        input   wire                        i_clk,
        input   wire                        i_step,
        input   wire                        i_reset,
        input   wire    [NBITS-1:0]         i_pc4,
        input   wire    [NBITS-1:0]         i_instruction,
        output  reg    [NBITS-1:0]          o_pc4,
        output  reg    [NBITS-1:0]          o_instruction
    );

       
    always @(negedge i_clk)begin
        if(i_reset)begin
            o_instruction   <=   {NB{1'b0}};
            o_pc4           <=   {NB{1'b0}};
        end
        else if(i_step)begin //i_IF_ID_Write & i_step
            o_instruction  <=   i_Instruction;
            o_pc4          <=   i_pc4;
        end
    end


endmodule