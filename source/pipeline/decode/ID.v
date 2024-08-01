`timescale 1ns / 1ps

module ID #(
    parameter NB           = 32,
    parameter REGS         = 5,
    parameter INBITS       = 16,
    parameter CTRLNB       = 6,
    parameter TAM_REG      = 32,
    parameter NB_SIZE_TYPE = 3
) (
    input            i_clk,
    input            i_reset,
    input            i_step,
    input [  NB-1:0] i_instruction,
    input [REGS-1:0] i_mips_register_number, //desde debug - i_tx_dir_debug

    input            i_wb_reg_write,
    input [  NB-1:0] i_wb_reg_write_data,
    input [REGS-1:0] i_wb_reg_dir,
    input [  NB-1:0] i_pc4,

    output [            NB-1:0] o_data_a,
    output [            NB-1:0] o_data_b,
    output [            NB-1:0] o_mips_register_data,
    output [            NB-1:0] o_extension_result,
    output [            NB-1:0] o_shamt,
    output [        CTRLNB-1:0] o_intruction_funct_code,
    output [        CTRLNB-1:0] o_intruction_op_code,
    // From control unit
    output                      o_alu_src,
    output                      o_mem_read,
    output                      o_mem_write,
    output                      o_mem_to_reg,
    output                      o_reg_write,
    output [          REGS-1:0] o_reg_dir_to_write,
    output                      o_branch,
    output                      o_jump,
    output                      o_signed,
    output [            NB-1:0] o_jump_addr,
    output [NB_SIZE_TYPE-1 : 0] o_word_size
);

  wire [  REGS-1:0] w_i_dir_rs;  // este - ID
  wire [  REGS-1:0] w_i_dir_rt;  // este - ID
  wire [  REGS-1:0] w_i_dir_shamt;  // este - ID
  wire [CTRLNB-1:0] w_i_special;  // este UC
  wire [CTRLNB-1:0] w_id_instr_control;  // este UC
  wire [INBITS-1:0] w_i_id_inmediate;  // este - ID

  wire [       1:0] w_extension_mode;
  wire [       1:0] w_o_ALUop;

  // DECODE
  assign w_i_id_inmediate = i_instruction[INBITS-1:0];
  assign w_i_dir_rs               =    i_instruction    [INBITS+REGS+REGS-1:INBITS+REGS];//INBITS+RT+RS-1=16+5+5-1=25; INBITS+RT=16+5=21; [25-21]
  assign w_i_dir_rt               =    i_instruction    [INBITS+REGS-1:INBITS];//INBITS+RT-1=16+5-1=20; INBITS=16; [20-16]
  assign w_i_dir_shamt            =    i_instruction    [INBITS-REGS-1:CTRLNB];
  assign o_intruction_op_code = i_instruction[NB-1:NB-CTRLNB];
  assign o_intruction_funct_code = i_instruction[CTRLNB-1:0];

  //  Calculo de jump address
  //  PC4[31:28] || instr_index || 00
  assign o_jump_addr = {i_pc4[NB-1:28], i_instruction[25:0], 2'b00}; 

  control_unit #(
      .NB(NB)
  ) u_Control_Unidad (
      .i_instruction     (i_instruction),
      .o_ALUSrc          (o_alu_src),
      .o_ExtensionMode   (w_extension_mode),
      .o_mem_read        (o_mem_read),
      .o_mem_write       (o_mem_write),
      .o_mem_to_reg      (o_mem_to_reg),
      .o_reg_write       (o_reg_write),
      .o_reg_dir_to_write(o_reg_dir_to_write),
      .o_branch          (o_branch),
      .o_jump            (o_jump),
      .o_signed          (o_signed),
      .o_word_size       (o_word_size)
  );

  register_file #(
      .REGS(REGS),
      .NB  (NB),
      .TAM (TAM_REG)
  ) u_register_file (
      .i_clk          (i_clk),
      .i_reset        (i_reset),
      .i_step         (i_step),
      .i_wb_reg_write (i_wb_reg_write),
      .i_wb_write_data(i_wb_reg_write_data),
      .i_wb_reg_dir   (i_wb_reg_dir),
      .i_dir_rs       (w_i_dir_rs),
      .i_dir_rt       (w_i_dir_rt),
      .i_RegDebug     (i_mips_register_number),
      .o_data_rs      (o_data_a),
      .o_data_rt      (o_data_b),
      .o_RegDebug     (o_mips_register_data)

  );


  Extensor_Signo #(
      .i_NB(INBITS),
      .e_NB(INBITS),
      .o_NB(NB)
  ) u_Extensor_Signo (
      .i_id_inmediate   (w_i_id_inmediate),
      .i_extension_mode (w_extension_mode),
      .o_extensionresult(o_extension_result)
  );

  extensor_shamt #(
      .NB(NB),
      .REGS(REGS)
  ) u_extensor_shamt (
      .i_shamt   (w_i_dir_shamt),
      .o_shamt   (o_shamt)
  );

endmodule
