`timescale 1ns/1ps

module ID #(
    parameter   NB        = 32,
    parameter   REGS      = 5,
    parameter   INBITS    = 16,
    parameter   CTRLNB    = 6,
    parameter   TAM_REG   = 32
)(
    input   wire                            i_clk,
    input   wire                            i_reset,
    input   wire                            i_step,
    input   wire     [NB-1:0]               i_Instruction,
    input   wire     [REGS-1:0]             i_select_reg_dir, //desde debug - i_tx_dir_debug
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
    // output  wire     [NBITS-1:0]            o_id_jump,  
    output  wire     [NB-1:0]               o_data_rs,
    output  wire     [NB-1:0]               o_data_rt,
    output  wire     [NB-1:0]               o_data_tx_debug,
    output  wire     [1  : 0]               o_ALUop,
    output  wire                            o_ALUSrc,
    output  wire     [NB-1:0]               o_extensionresult
);

wire     [REGS-1:0]             i_dir_rs; // este - ID
wire     [REGS-1:0]             i_dir_rt; // este - ID
wire     [CTRLNB-1:0]           i_Special; // este UC
wire     [CTRLNB-1:0]           ID_InstrControl; // este UC
wire     [INBITS-1:0]           i_id_inmediate; // este - ID
// wire     [NB-1:0]               ID_Reg_Debug;

reg     [REGS-1:0]              i_tx_dir_debug; // este - ID desde debug
wire     [1:0]                  ExtensionMode;
wire     [1:0]                  o_ALUop;

// UC
assign ID_InstrControl  =    i_Instruction    [NB-1:NB-CTRLNB];
assign i_Special        =    i_Instruction    [CTRLNB-1:0] ;

// DECODE
assign i_id_inmediate   =    i_Instruction    [INBITS-1:0];  
assign i_dir_rs         =    i_Instruction    [INBITS+REGS+REGS-1:INBITS+REGS];//INBITS+RT+RS-1=16+5+5-1=25; INBITS+RT=16+5=21; [25-21]
assign i_dir_rt         =    i_Instruction    [INBITS+REGS-1:INBITS];//INBITS+RT-1=16+5-1=20; INBITS=16; [20-16]
// assign ID_Reg_rd_i         =    i_Instruction    [INBITS-1:INBITS-REGS]; //INBITS-1=16-1=15; INBITS-RD=16-5=11; [15-11]
// assign o_data_reg_file     =    ID_Reg_Debug; Salida del TOP Mips a la DEBUG UNIT


control_unit
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
    .o_ALUop                    (o_ALUop),
    // .o_MemWrite                 (ctl_unidad_mem_write       ),
    .o_ALUSrc                   (o_ALUSrc),
    .o_ExtensionMode            (ExtensionMode)
    // .o_RegWrite                 (ctl_unidad_regWrite       ),
    // .o_ExtensionMode            (ctl_unidad_extend_mode  ),
    // .o_TamanoFiltro             (ctl_unidad_size_filter   ),
    // .o_TamanoFiltroL            (ctl_unidad_size_filterL  ),
    // .o_ZeroExtend               (ctl_unidad_zero_extend     ),
    // .o_LUI                      (ctl_unidad_lui            ),
    // .o_JALR                     (ctl_unidad_jalR           ),
    // .o_HALT                     (ctl_unidad_halt           )
);

    register_file
    #(
        .REGS        (REGS),
        .NB          (NB),
        .TAM         (TAM_REG)
    )
    u_register_file
    (
        .i_clk               (i_clk),
        .i_reset             (i_reset),
        .i_step              (i_step),
        // .i_RegWrite          (i_mem_wb_regwrite),
        .i_dir_rs            (i_dir_rs),
        .i_dir_rt            (i_dir_rt),
        .i_RegDebug          (i_select_reg_dir),
        // .i_RD                (i_wb_dir_rd),
        // .i_DatoEscritura     (i_wb_write),
        .o_data_rs           (o_data_rs),
        .o_data_rt           (o_data_rt),
        .o_RegDebug          (o_data_tx_debug)

    );
  
  
    Extensor_Signo
    #(
        .i_NB                 (INBITS),
        .e_NB                 (INBITS),
        .o_NB                 (NB)
    )
    u_Extensor_Signo
    (
        .i_id_inmediate         (i_id_inmediate),
        .i_extension_mode       (ExtensionMode),
        .o_extensionresult      (o_extensionresult)
    );


endmodule