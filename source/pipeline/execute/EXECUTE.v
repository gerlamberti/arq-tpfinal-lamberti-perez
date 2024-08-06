`timescale 1ns / 1ps

module EXECUTE #(
    parameter NB        = 32,
    parameter NB_FCODE  = 6,
    parameter NB_OPCODE = 6,
    parameter NB_ALU_OP = 4
) (
    input       [ NB_FCODE-1:0] i_instruction_funct_code,
    input       [NB_OPCODE-1:0] i_instruction_op_code,
    input                       i_alu_src,                 // 0 data_b, 1 immediate
    input       [       NB-1:0] i_data_a,
    input       [       NB-1:0] i_data_b,
    // forwarding data
    input       [       NB-1:0] i_mem_fwd_data,
    input       [       NB-1:0] i_wb_fwd_data,
    // forwarding control
    input       [          1:0] i_fwd_a,
    input       [          1:0] i_fwd_b,
    input       [          1:0] i_forwarding_mux,
    input       [       NB-1:0] i_shamt,
    input       [       NB-1:0] i_extension_result,        // Viene del decode, es el imm extendido
    input       [       NB-1:0] i_pc4,
    output wire [       NB-1:0] o_data_b_to_write,
    output wire                 o_cero,
    output wire [       NB-1:0] o_alu_result,
    output wire [       NB-1:0] o_branch_addr

);

  wire [NB-1:0] w_data_a_or_shamt, w_data_a_or_shamt_or_fwd;
  wire [NB-1:0] w_data_b_or_immediate, w_data_b_or_immediate_or_fwd;
  wire [NB_ALU_OP-1:0] w_operation;
  wire w_shamt_ctrl;

  mux2 #(
      .NB(NB)
  ) mux_shamt_src (
      .i_data_a(i_data_a),
      .i_data_b(i_shamt),
      .i_sel(w_shamt_ctrl),
      .o_data(w_data_a_or_shamt)
  );

  mux3 #(
      .NB(NB)
  ) mem_data_OR_wb_data_OR_data_b (
      .i_data_a(i_mem_fwd_data),
      .i_data_b(i_wb_fwd_data),
      .i_data_c(i_data_b),
      .i_sel(i_forwarding_mux),
      .o_data(o_data_b_to_write)
  );

  mux3 #(
      .NB(NB)
  ) fwd_a (
      .i_data_a(w_data_a_or_shamt),
      .i_data_b(i_mem_fwd_data),
      .i_data_c(i_wb_fwd_data),
      .i_sel(i_fwd_a),
      .o_data(w_data_a_or_shamt_or_fwd)
  );

  mux2 #(
      .NB(NB)
  ) mux_alu_src (
      .i_data_a(i_data_b),
      .i_data_b(i_extension_result),
      .i_sel(i_alu_src),
      .o_data(w_data_b_or_immediate)
  );
  mux3 #(
      .NB(NB)
  ) fwd_b (
      .i_data_a(w_data_b_or_immediate),
      .i_data_b(i_mem_fwd_data),
      .i_data_c(i_wb_fwd_data),
      .i_sel(i_fwd_b),
      .o_data(w_data_b_or_immediate_or_fwd)
  );

  alu_control #() alu_control (
      .i_funct_code(i_instruction_funct_code),
      .i_instruction_opcode(i_instruction_op_code),
      .o_alu_operation(w_operation),
      .o_shamt_ctrl(w_shamt_ctrl)
  );

  ALU #() alu (
      .i_data_a(w_data_a_or_shamt_or_fwd),
      .i_data_b(w_data_b_or_immediate_or_fwd),
      .i_operation(w_operation),
      .o_cero(o_cero),
      .o_result(o_alu_result)
  );

  branch_addr #(
      .NB(NB)
  ) branch_addr (
      .i_extension_result(i_extension_result),
      .i_pc4(i_pc4),
      .o_branch_addr(o_branch_addr)
  );

endmodule
