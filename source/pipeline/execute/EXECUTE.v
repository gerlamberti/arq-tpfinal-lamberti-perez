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
    input       [       NB-1:0] i_extension_result,        // Viene del decode, es el imm extendido
    output wire                 o_cero,
    output wire [       NB-1:0] o_alu_result
);

  wire [NB-1:0] w_data_a, w_data_b_or_immediate;
  wire [NB_ALU_OP-1:0] w_operation;


  mux2 #(
      .NB(NB)
  ) mux_alu_src (
      .i_data_a(i_data_b),
      .i_data_b(i_extension_result),
      .i_sel(i_alu_src),
      .o_data(w_data_b_or_immediate)
  );

  alu_control #() alu_control (
      .i_funct_code(i_instruction_funct_code),
      .i_instruction_opcode(i_instruction_op_code),
      .o_alu_operation(w_operation)
  );

  ALU #() alu (
      .i_data_a(i_data_a),
      .i_data_b(w_data_b_or_immediate),
      .i_operation(w_operation),
      .o_cero(o_cero),
      .o_result(o_alu_result)
  );

endmodule
