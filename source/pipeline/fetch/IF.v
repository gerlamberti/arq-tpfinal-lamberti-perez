`timescale  1ns / 1ps

module IF  #(
    parameter NB    = 32,
    parameter TAM_I = 256
)(
    input   wire                    i_clk,
    input   wire                    i_step,
    input   wire                    i_reset,
    input   wire                    i_pc_write,
    input                           i_branch,
    input   [NB-1:0]                i_branch_addr,
    output  wire    [NB-1:0]        o_IF_pc,
    output  wire    [NB-1:0]        o_IF_pc4,
    output  wire    [NB-1:0]        o_IF_pc8,
    output  wire    [NB-1:0]        o_instruction
);
    
    wire    [NB-1:0]    test_pc;
    wire    [NB-1:0]    pc;
    wire    [NB-1:0]    pc4;
    wire    [NB-1:0]    pc8;

    assign o_IF_pc  = pc;
    assign o_IF_pc4 = pc4;
    assign o_IF_pc8 = pc8;

    PC 
    #(
        .NB         (NB)
    )
    u_PC
    (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_step         (i_step),
        .i_pc_write     (i_pc_write),
        .i_new_pc       (test_pc),
        .o_pc           (pc),
        .o_pc_4         (pc4),
        .o_pc_8         (pc8)
    );

   instruction_memory
   #(
       .NB              (NB),
       .TAM             (TAM_I)
   )
   u_instruction_memory
   (
       .i_clk           (i_clk),
       .i_reset         (i_reset),
       .i_step          (i_step),
    //    .i_instruction_write     (i_instruction_write),
       .i_pc            (pc),
    //    .i_instruction           (i_instruction),
    //    .i_address_memory_ins    (i_address_memory_ins),
        .o_instruction   (o_instruction)
       
   );

    mux_pc
    #(
        .NB             (NB)
    )
    u_mux_pc
    (
        .i_sumador_pc4  (pc4),
        .i_branch       (i_branch),
        .i_branch_addr  (i_branch_addr),
        .o_pc           (test_pc)
    );

endmodule