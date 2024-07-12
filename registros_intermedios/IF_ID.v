`timescale 1ns / 1ps

module IF_ID
    #(
        parameter NB = 32
    )
    (
        input   wire                        i_clk,
        input   wire                        i_step,
        input   wire                        i_reset,
        //input   wire                        i_IF_ID_Write, // hazard unit
        input   wire    [NBITS-1:0]         i_pc4,
        //input   wire    [NBITS-1:0]         i_pc8,
        input   wire    [NBITS-1:0]         i_Instruction,
        output  wire    [NBITS-1:0]         o_pc4,
        //output  wire    [NBITS-1:0]         o_pc8,
        output  wire    [NBITS-1:0]         o_instruction
    );


    reg     [NB-1:0] instruction;
    reg     [NB-1:0] pc_4;
    //reg     [NBITS-1:0] pc_8;
       
    always @(negedge i_clk)begin
        if(i_reset)begin
            instruction  <=   {NB{1'b0}};
            pc_4         <=   {NB{1'b0}};
            //pc_8         <=   {NBITS{1'b0}};
        end
        else if(i_step)begin //i_IF_ID_Write & i_step
            instruction  <=   i_Instruction;
            pc_4         <=   i_pc4;
            //pc_8         <=   i_pc8;
        end
    end


    assign o_instruction    =   instruction;
    assign o_pc4            =   pc_4;
    //assign o_pc8            =   pc_8;

endmodule
