`timescale 1ns / 1ps

module IF #(
	parameter NBITS 	= 32,
	parameter TAM_I     = 256 // 64 lugares
)
(
	input 		wire 						i_clk,
	input 		wire 						i_step,
    input 		wire 						i_reset,
	input       wire                        hazard_pc_Write,
	input       wire    [NBITS-1:0]         i_address_memory_ins,
	input       wire    [NBITS-1:0]         i_instruction,
	input       wire                        i_write_intruc,
	input       wire                        i_Jump,
	input       wire                        i_JALR,
	input       wire                        i_pc_src,
	input       wire    [NBITS-1:0]         i_SumadorBranch,
	input       wire    [NBITS-1:0]         i_SumadorJump,
	input       wire    [NBITS-1:0]         i_rs,
	output      wire    [NBITS-1:0]         IF_PC4_o,
	output      wire    [NBITS-1:0]         IF_PC_o,
	output      wire    [NBITS-1:0]         o_instruction,
	output      wire    [NBITS-1:0]         IF_PC8_o                                
	                  
);
    wire    [NBITS-1:0]                    IF_PC_i;
    wire    [NBITS-1:0]                    pc_o  ;
    wire    [NBITS-1:0]                    pc8  ;
    wire    [NBITS-1:0]                    pc4  ;

assign IF_PC_o  = pc_o;
assign IF_PC4_o = pc4;
    PC
   #(
        .NBITS              (NBITS )
    )
    u_PC
    (
        .i_clk              (i_clk),
        .i_reset            (i_reset),
        .i_step             (i_step),
        .i_NPC              (IF_PC_i),
        .i_pc_write         (hazard_pc_Write),
        .o_pc               (pc_o),
        .o_pc_4             (pc4),
        .o_pc_8             (IF_PC8_o)
    );
    
    Memoria_Instrucciones
    #(
        .NBITS              (NBITS),
        .TAM                (TAM_I)
    )
    u_Memoria_Instrucciones
    (
        .i_clk                  (i_clk),
        .i_reset                (i_reset),
        .i_step                 (i_step),
        .i_pc                   (pc_o),
        .i_address_memory_ins   (i_address_memory_ins),
        .i_instruction         (i_instruction),
        .i_write_intruc         (i_write_intruc),
        .o_instruction          (o_instruction)
    );

    Mux_PC
    #(
        .NBITS              (NBITS)
    )
    u_Mux_PC
    (
        .i_Jump             (i_Jump),
        .i_JALR             (i_JALR),
        .i_pcSrc            (i_pc_src),
        .i_SumadorBranch    (i_SumadorBranch),
        .i_sumador_pc4       (pc4),
        .i_SumadorJump      (i_SumadorJump),
        .i_rs               (i_rs),
        .o_pc               (IF_PC_i)
    );

endmodule