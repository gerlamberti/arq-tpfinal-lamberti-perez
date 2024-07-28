`timescale 1ns / 1ps
`include "memory_constants.vh"

module PIPELINE #(
    parameter NB = 32,
    parameter NB_SIZE_TYPE = 3
) (
    input i_clk,
    input i_step,
    input i_reset,
    input [4:0] i_debug_mips_register_number,
    input [NB-1:0] i_debug_address,
    output [NB-1:0] o_mips_pc,
    output [NB-1:0] o_mips_alu_result,
    output [NB-1:0] o_mips_register_data,
    output [NB-1:0] o_mips_data_memory
);

  // Wires for inter-stage communication
  wire [NB-1:0] w_if_instruction, w_if_id_pc4;
  wire [NB-1:0] w_id_instruction;
  wire [NB-1:0] w_id_data_a, w_id_data_b, w_id_extension_result;
  wire [5:0] w_id_instruction_funct_code, w_id_instruction_op_code;
  wire w_id_alu_src;
  wire [5:0] w_ex_instruction_funct_code, w_ex_instruction_op_code;
  wire w_ex_alu_src;
  wire [NB-1:0] w_ex_data_a, w_ex_data_b, w_ex_extension_result;
  wire [NB-1:0] w_ex_alu_result;

  // Wires for MEM stage
  wire w_mem_cero;
  wire [NB-1:0] w_mem_alu_result;
  wire [NB-1:0] w_mem_data_b;
  wire w_mem_mem_read;
  wire w_mem_mem_write;
  wire w_mem_reg_write;
  wire [NB_SIZE_TYPE-1:0] w_mem_word_size;
  wire [NB-1:0] w_mem_data_memory;

  // Wires for WB stage
  wire w_wb_reg_write;
  wire w_wb_mem_to_reg;
  wire [NB-1:0] w_wb_data_memory;
  wire [NB-1:0] w_wb_alu_address_result;
  // Instruction Fetch (IF) stage
  IF #(
      .NB(NB),
      .TAM_I(256)
  ) FETCH (
      .i_clk(i_clk),
      .i_step(i_step),
      .i_reset(i_reset),
      .i_pc_write(1'b1),
      .o_instruction(w_if_instruction),
      .o_IF_pc(o_mips_pc),
      .o_IF_pc4(w_if_id_pc4)
  );

  // IF/ID Pipeline Register
  IF_ID #(
      .NB(NB)
  ) intermedio_fetch_decode (
      .i_clk(i_clk),
      .i_step(i_step),
      .i_reset(i_reset),
      .i_pc4(w_if_id_pc4),
      .i_instruction(w_if_instruction),
      .o_pc4(),
      .o_instruction(w_id_instruction)
  );

  // Instruction Decode (ID) stage
  ID #(
      .NB(NB),
      .REGS(5),
      .INBITS(16),
      .CTRLNB(6),
      .TAM_REG(32)
  ) DECODE (
      .i_clk(i_clk),
      .i_step(i_step),
      .i_reset(i_reset),
      .i_instruction(w_id_instruction),
      .i_mips_register_number(i_debug_mips_register_number),
      .o_data_a(w_id_data_a),
      .o_data_b(w_id_data_b),
      .o_mips_register_data(o_mips_register_data),
      .o_alu_src(w_id_alu_src),
      .o_intruction_funct_code(w_id_instruction_funct_code),
      .o_intruction_op_code(w_id_instruction_op_code),
      .o_extension_result(w_id_extension_result)
  );

  // ID/EX Pipeline Register
  ID_EX #(
      .NB(NB),
      .NB_OPCODE(6),
      .NB_FCODE(6)
  ) Intermedio_decode_execute (
      .i_clk(i_clk),
      .i_step(i_step),
      .i_reset(i_reset),
      .i_instruction_funct_code(w_id_instruction_funct_code),
      .i_instruction_op_code(w_id_instruction_op_code),
      .i_alu_src(w_id_alu_src),
      .i_data_a(w_id_data_a),
      .i_data_b(w_id_data_b),
      .i_extension_result(w_id_extension_result),
      .o_instruction_funct_code(w_ex_instruction_funct_code),
      .o_instruction_op_code(w_ex_instruction_op_code),
      .o_alu_src(w_ex_alu_src),
      .o_data_a(w_ex_data_a),
      .o_data_b(w_ex_data_b),
      .o_extension_result(w_ex_extension_result)
  );

  // Execute (EX) stage
  EXECUTE #(
      .NB(NB),
      .NB_FCODE(6),
      .NB_OPCODE(6),
      .NB_ALU_OP(4)
  ) EXECUTE (
      .i_instruction_funct_code(w_ex_instruction_funct_code),
      .i_instruction_op_code(w_ex_instruction_op_code),
      .i_alu_src(w_ex_alu_src),
      .i_data_a(w_ex_data_a),
      .i_data_b(w_ex_data_b),
      .i_extension_result(w_ex_extension_result),
      .o_cero(w_mem_cero),
      .o_alu_result(w_ex_alu_result)
  );

  // Execute/Memory (EX/MEM)
  EX_MEM #(
      .NB(NB),
      .NB_SIZE_TYPE(3)
  ) ex_mem (
      .i_clk(i_clk),
      .i_step(i_step),
      .i_reset(i_reset),
      .i_cero(w_ex_cero),
      .i_alu_result(w_ex_alu_result),
      .i_data_b(w_ex_data_b),
      .i_mem_read(0),  // TODO añadir cuando mergee PR de german
      .i_mem_write(0),  // TODO añadir cuando mergee PR de german
      .i_reg_write(0),  // TODO añadir cuando mergee PR de german
      .i_word_size(`COMPLETE_WORD),  // TODO añadir cuando mergee PR de german
      .o_cero(w_wb_cero),
      .o_alu_result(w_mem_alu_result),
      .o_data_b(w_mem_data_b),
      .o_mem_read(w_mem_mem_read),
      .o_mem_write(w_mem_mem_write),
      .o_reg_write(w_mem_reg_write),
      .o_word_size(w_mem_word_size)
  );

  MEMORY #(
      .NB(NB),
      .TAM(16),
      .NB_SIZE_TYPE(NB_SIZE_TYPE)
  ) memory (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_step(i_step),
      .i_alu_address_result(w_mem_alu_result),
      .i_mem_read(w_mem_mem_read),
      .i_signed(w_mem_i_signed),
      .i_debug_address(i_debug_address),
      .i_data_b_to_write(w_mem_data_b),
      .i_word_size(w_mem_word_size),
      .i_mem_write(w_mem_mem_write),
      .i_reg_write(w_mem_reg_write),
      .o_data_memory(w_mem_data_memory),
      .o_data_debug_memory(o_mips_data_memory)
  );

  MEM_WB #(
      .NB(NB)
  ) mem_wb (
      .i_clk(i_clk),
      .i_step(i_step),
      .i_reset(i_reset),
      .i_reg_write(w_mem_reg_write),
      .i_mem_to_reg(0),  // TODO: esperar que germancito lo haga
      .i_data_memory(w_mem_data_memory),
      .i_alu_address_result(w_mem_alu_result),
      .o_reg_write(w_wb_reg_write),
      .o_mem_to_reg(w_wb_mem_to_reg),
      .o_data_memory(w_wb_data_memory),
      .o_alu_address_result(w_wb_alu_address_result)
  );


  WRITE_BACK #(
      .NB(NB),
      .NB_REG(5)
  ) write_back (
      .i_mem_to_reg(w_wb_mem_to_reg),
      .i_mem_data(w_wb_data_memory),
      .i_alu_result(w_wb_alu_address_result),
      .o_data_to_write_in_register()
  );




  assign o_mips_alu_result = w_ex_alu_result;
endmodule