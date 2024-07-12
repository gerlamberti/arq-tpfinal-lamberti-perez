`timescale 1ns/1ps

module ID #(
    parameter   NB        = 32,
    parameter   REGS      = 5,
    parameter   INBITS    = 16,
    parameter   CTRLNB    = 6;
)(
    input   wire                            i_clk,
    input   wire                            i_reset,
    input   wire                            i_step,
    input   wire     [NB-1:0]               i_Instruction,
    // input   wire                            i_mem_wb_regwrite,
    // input   wire     [REGS-1:0]             i_dir_rs, // este
    // input   wire     [REGS-1:0]             i_dir_rt, // este
    // input   wire     [REGS-1:0]             i_tx_dir_debug, //desde debug
    // input   wire     [CTRLNB-1:0]           i_Special,
    // input   wire     [REGS-1:0]             i_wb_dir_rd,
    // input   wire     [NBITS-1:0]            i_wb_write,
    // input   wire     [NBITSJUMP-1:0]        i_if_id_jump, // este
    // input   wire     [NBITS-1:0]            i_id_expc4,
    // input   wire     [INBITS-1:0]           i_id_inmediate, // este
    // input   wire     [TNBITS-1:0]           i_rctrl_extensionmode,
    output  wire     [NB-1:0]               o_data_rs,
    output  wire     [NB-1:0]               o_data_rt,
    output  wire     [NBITS-1:0]            o_data_tx_debug,
    //output  wire     [NBITS-1:0]            o_id_jump,  
    output  wire     [NBITS-1:0]            o_extensionresult
);

wire     [REGS-1:0]             i_dir_rs; // este
wire     [REGS-1:0]             i_dir_rt; // este
wire     [REGS-1:0]             i_tx_dir_debug; //desde debug
wire     [CTRLNB-1:0]           i_Special;
wire     [CTRLNB-1:0]           ID_InstrControl;
wire     [INBITS-1:0]           i_id_inmediate;

assign ID_InstrControl  =    i_Instruction     [NB-1:NB-CTRLNB];
assign i_Special        =    i_Instruction     [CTRLNB-1:0] ;

Control_Unidad
#(
    .NB                      (CTRLNB)
)
u_Control_Unidad
(
    .i_Instruction              (ID_InstrControl),
    .i_Special                  (i_Special),
    // .o_RegDst                   (ctl_unidad_reg_rd         ),
    // .o_Jump                     (ctl_unidad_jump           ),
    // .o_JAL                      (ctl_unidad_jal            ),
    // .o_Branch                   (ctl_unidad_branch         ),
    // .o_NBranch                  (ctl_unidad_Nbranch        ),
    // .o_MemRead                  (ctl_unidad_mem_read        ),
    // .o_MemToReg                 (ctl_unidad_mem_to_reg),
    .o_ALUOp                    (ctl_unidad_alu_op),
    // .o_MemWrite                 (ctl_unidad_mem_write       ),
    .o_ALUSrc                   (ctl_unidad_alu_src),
    // .o_RegWrite                 (ctl_unidad_regWrite       ),
    // .o_ExtensionMode            (ctl_unidad_extend_mode  ),
    // .o_TamanoFiltro             (ctl_unidad_size_filter   ),
    // .o_TamanoFiltroL            (ctl_unidad_size_filterL  ),
    // .o_ZeroExtend               (ctl_unidad_zero_extend     ),
    // .o_LUI                      (ctl_unidad_lui            ),
    // .o_JALR                     (ctl_unidad_jalR           ),
    // .o_HALT                     (ctl_unidad_halt           )
);


endmodule