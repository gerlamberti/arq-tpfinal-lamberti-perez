`timescale 1ns / 1ps

module EXECUTE
    #(
        parameter   NBITS           = 32,
        parameter   ALUOP           = 4,
        parameter   NB_OP           = 4,
        parameter   REGS            = 5
    )
    (
        input  wire      [NBITS-1:0]           i_id_extension,
        input  wire      [ALUOP-1:0]           i_operation,
        input  wire      [NBITS-1 :0]          i_reg1,
        input  wire      [NBITS-1:0]           i_id_Ex_reg2,
        input  wire      [REGS-1:0]            i_reg_rd,
        input  wire      [REGS-1:0]            i_reg_rt,
        input  wire                            i_alu_src,
        input  wire                            i_select_reg,
        output wire                            o_cero,
        output wire      [NBITS-1:0]           o_alu_result
    );

endmodule