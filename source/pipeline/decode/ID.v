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
    input   wire     [NB-1:0]               i_instruction,
    input   wire     [REGS-1:0]             i_select_reg_dir, //desde debug - i_tx_dir_debug
    output  wire     [NB-1:0]               o_data_a,
    output  wire     [NB-1:0]               o_data_b,
    output  wire     [NB-1:0]               o_data_tx_debug,
    // output  wire     [1  : 0]               o_ALUop,
    output  wire                            o_alu_src,
    output  wire     [NB-1:0]               o_extension_result,
    output  wire     [CTRLNB-1:0]           o_intruction_funct_code,
    output  wire     [CTRLNB-1:0]           o_intruction_op_code
);

wire     [REGS-1:0]             w_i_dir_rs; // este - ID
wire     [REGS-1:0]             w_i_dir_rt; // este - ID
wire     [CTRLNB-1:0]           w_i_special; // este UC
wire     [CTRLNB-1:0]           w_id_instr_control; // este UC
wire     [INBITS-1:0]           w_i_id_inmediate; // este - ID

reg     [REGS-1:0]              w_i_tx_dir_debug; // este - ID desde debug
wire     [1:0]                  w_extension_mode;
wire     [1:0]                  w_o_ALUop;

// UC
assign w_id_instr_control  =    i_instruction    [NB-1:NB-CTRLNB];
assign w_i_special         =    i_instruction    [CTRLNB-1:0] ;

// DECODE
assign w_i_id_inmediate         =    i_instruction    [INBITS-1:0];  
assign w_i_dir_rs               =    i_instruction    [INBITS+REGS+REGS-1:INBITS+REGS];//INBITS+RT+RS-1=16+5+5-1=25; INBITS+RT=16+5=21; [25-21]
assign w_i_dir_rt               =    i_instruction    [INBITS+REGS-1:INBITS];//INBITS+RT-1=16+5-1=20; INBITS=16; [20-16]
assign o_intruction_op_code     =    i_instruction    [NB-1:NB-CTRLNB];
assign o_intruction_funct_code  =    i_instruction    [CTRLNB-1:0];

control_unit
#(
    .NB                      (CTRLNB)
)
u_Control_Unidad
(
    .i_Instruction              (w_id_instr_control),
    .i_Special                  (w_i_special),
    .o_ALUSrc                   (o_alu_src),
    .o_ExtensionMode            (w_extension_mode)
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
        .i_dir_rs            (w_i_dir_rs),
        .i_dir_rt            (w_i_dir_rt),
        .i_RegDebug          (i_select_reg_dir),
        .o_data_rs           (o_data_a),
        .o_data_rt           (o_data_b),
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
        .i_id_inmediate         (w_i_id_inmediate),
        .i_extension_mode       (w_extension_mode),
        .o_extensionresult      (o_extension_result)
    );


endmodule