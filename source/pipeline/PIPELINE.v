`timescale 1ns / 1ps
`include "memory_constants.vh"
`include "instruction_constants.vh"

module PIPELINE #(
    parameter NB = 32,
    parameter NB_SIZE_TYPE = 3,
    parameter NB_REGS = 5
) (
    input           i_clk,
    input           i_step,
    input           i_reset,
    input  [   4:0] i_debug_mips_register_number,
    input  [NB-1:0] i_debug_address,
    input           i_instruction_write_enable,
    input  [NB-1:0] i_instruction_address,
    input  [NB-1:0] i_instruction_data,
    output [NB-1:0] o_mips_pc,
    output [NB-1:0] o_mips_alu_result,
    output [NB-1:0] o_mips_register_data,
    output [NB-1:0] o_mips_data_memory,
    output          o_mips_wb_halt
);
  // Wires for inter-stage communication
  wire [NB-1:0] w_if_instruction, w_if_id_pc4;
  wire [NB-1:0] w_id_instruction;
  wire w_flush_if_id, w_flush_id, w_stall_if_id, w_stall_pc;
  wire [NB-1:0] w_id_data_a, w_id_data_b, w_id_extension_result, w_id_shamt;
  wire [5:0] w_id_instruction_funct_code, w_id_instruction_op_code;
  wire w_id_alu_src;
  wire [5:0] w_ex_instruction_funct_code, w_ex_instruction_op_code;
  wire w_ex_alu_src;
  wire [NB-1:0] w_ex_data_a, w_ex_data_b, w_ex_extension_result, w_ex_shamt;
  wire [NB-1:0] w_ex_alu_result;
  wire [NB-1:0] w_id_pc4;
  // Wires for ID stage
  wire w_id_mem_read;
  wire w_id_mem_write;
  wire w_id_mem_to_reg;
  wire w_id_reg_write;
  wire w_id_branch;
  wire w_id_jump, w_id_halt, w_id_jr_jalr;
  wire [NB-1:0] w_id_jump_addr;
  wire [NB_SIZE_TYPE-1:0] w_id_word_size;
  wire [NB_REGS-1:0] w_id_reg_dir_to_write;
  wire [NB_REGS-1:0] w_id_reg_dir_rs, w_id_reg_dir_rt;


  // Wires for EX stage
  wire [NB-1:0] w_ex_pc4;
  wire w_ex_mem_read;
  wire w_ex_mem_write;
  wire w_ex_signed;
  wire w_ex_mem_to_reg;
  wire w_ex_reg_write;
  wire w_ex_branch, w_ex_jump, w_ex_halt, w_ex_jr_jalr;
  wire [NB-1:0] w_ex_jump_addr;
  wire [NB_SIZE_TYPE-1:0] w_ex_word_size;
  wire [NB-1:0] w_ex_branch_addr, w_ex_data_b_to_write;
  wire [NB_REGS-1:0] w_ex_reg_dir_to_write, w_select_reg_dir_to_write, w_fwd_reg_dir_rs, w_fwd_reg_dir_rt;

  wire [1:0] w_fwd_ex_a, w_fwd_ex_b, w_fwd_ex_mux;
  wire w_flush_ex_mem;
  wire w_ex_last_register_ctrl;

  // Wires for MEM stage
  wire w_mem_cero;
  wire [NB-1:0] w_mem_alu_result;
  wire [NB-1:0] w_mem_data_b_to_write;
  wire w_mem_mem_read;
  wire w_mem_mem_write;
  wire w_mem_signed;
  wire w_mem_mem_to_reg;
  wire w_mem_reg_write, w_mem_halt, w_mem_jump, w_mem_jr_jalr;
  wire [NB_SIZE_TYPE-1:0] w_mem_word_size;
  wire [NB-1:0] w_mem_data_memory;
  wire [NB-1:0] w_mem_pc4;
  wire w_branch_zero;
  wire [NB-1:0] w_mem_branch_addr;
  wire w_mem_branch;
  wire w_mem_last_register_ctrl;
  wire [NB_REGS-1:0] w_mem_reg_dir_to_write;

  // Wires for WB stage
  wire w_wb_reg_write;
  wire w_wb_mem_to_reg;
  wire w_wb_signed;
  wire w_wb_last_register_ctrl;
  wire [NB-1:0] w_wb_pc4;
  wire [NB-1:0] w_wb_data_memory;
  wire [NB-1:0] w_wb_alu_address_result;
  wire [NB-1:0] w_wb_data_to_register;
  wire [NB_REGS-1:0] w_wb_reg_dir_to_write;
  wire w_mips_wb_halt;
  // Instruction Fetch (IF) stage

  IF #(
      .NB(NB),
      .TAM_I(256)
  ) FETCH (
      .i_clk(i_clk),
      .i_step(i_step),
      .i_stall_pc(w_stall_pc),
      .i_reset(i_reset),
      .i_pc_write(1'b1),
      .i_branch(w_branch_zero),
      .i_jump(w_ex_jump),
      .i_jr_jalr(w_ex_jr_jalr),
      .i_jump_addr(w_ex_jump_addr),
      .i_jr_jalr_addr(w_ex_data_a),
      .i_branch_addr(w_mem_branch_addr),
      .i_instruction_write_enable(i_instruction_write_enable),
      .i_instruction_address(i_instruction_address),
      .i_instruction_data(i_instruction_data),
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
      .i_flush(w_flush_if_id),
      .i_stall(w_stall_if_id),
      .o_pc4(w_id_pc4),
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
      .i_flush(w_flush_id),
      .i_instruction(w_id_instruction),
      .i_mips_register_number(i_debug_mips_register_number),
      .i_wb_reg_write_data(w_wb_data_to_register),
      .i_wb_reg_write(w_wb_reg_write),
      .i_wb_reg_dir(w_wb_reg_dir_to_write),
      .i_pc4(w_id_pc4),
      .o_data_a(w_id_data_a),
      .o_data_b(w_id_data_b),
      .o_shamt(w_id_shamt),
      .o_mips_register_data(o_mips_register_data),
      .o_intruction_funct_code(w_id_instruction_funct_code),
      .o_intruction_op_code(w_id_instruction_op_code),
      .o_extension_result(w_id_extension_result),
      // Control unit
      .o_alu_src(w_id_alu_src),
      .o_mem_read(w_id_mem_read),
      .o_mem_write(w_id_mem_write),
      .o_signed(w_id_signed),
      .o_mem_to_reg(w_id_mem_to_reg),
      .o_reg_write(w_id_reg_write),
      .o_reg_dir_to_write(w_id_reg_dir_to_write),
      .o_branch(w_id_branch),
      .o_jump(w_id_jump),
      .o_jr_jalr(w_id_jr_jalr),
      .o_jump_addr(w_id_jump_addr),
      .o_word_size(w_id_word_size),
      .o_dir_rs(w_id_reg_dir_rs),
      .o_dir_rt(w_id_reg_dir_rt),
      .o_halt(w_id_halt)
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
      .i_data_a(w_id_data_a),
      .i_data_b(w_id_data_b),
      .i_shamt(w_id_shamt),
      .i_extension_result(w_id_extension_result),
      .i_pc4(w_id_pc4),
      .i_alu_src(w_id_alu_src),
      .i_mem_read(w_id_mem_read),
      .i_mem_write(w_id_mem_write),
      .i_signed(w_id_signed),
      .i_mem_to_reg(w_id_mem_to_reg),
      .i_reg_write(w_id_reg_write),
      .i_reg_dir_to_write(w_id_reg_dir_to_write),
      .i_branch(w_id_branch),
      .i_jump(w_id_jump),
      .i_jr_jalr(w_id_jr_jalr),
      .i_jump_addr(w_id_jump_addr),
      .i_word_size(w_id_word_size),
      .i_dir_rs(w_id_reg_dir_rs),
      .i_dir_rt(w_id_reg_dir_rt),
      .i_halt(w_id_halt),

      .o_instruction_funct_code(w_ex_instruction_funct_code),
      .o_instruction_op_code(w_ex_instruction_op_code),
      .o_alu_src(w_ex_alu_src),
      .o_data_a(w_ex_data_a),
      .o_data_b(w_ex_data_b),
      .o_shamt(w_ex_shamt),
      .o_extension_result(w_ex_extension_result),

      .o_pc4(w_ex_pc4),
      .o_mem_read(w_ex_mem_read),
      .o_mem_write(w_ex_mem_write),
      .o_signed(w_ex_signed),
      .o_mem_to_reg(w_ex_mem_to_reg),
      .o_reg_write(w_ex_reg_write),
      .o_reg_dir_to_write(w_ex_reg_dir_to_write),
      .o_branch(w_ex_branch),
      .o_jr_jalr(w_ex_jr_jalr),
      .o_jump(w_ex_jump),
      .o_jump_addr(w_ex_jump_addr),
      .o_word_size(w_ex_word_size),
      .o_dir_rs(w_fwd_reg_dir_rs),
      .o_dir_rt(w_fwd_reg_dir_rt),
      .o_halt(w_ex_halt)
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
      //.i_reg_dir_to_write(w_ex_reg_dir_to_write),
      .i_shamt(w_ex_shamt),
      .i_extension_result(w_ex_extension_result),
      .i_pc4(w_ex_pc4),
      .i_mem_fwd_data(w_mem_alu_result),
      .i_wb_fwd_data(w_wb_data_to_register),
      .i_fwd_a(w_fwd_ex_a),
      .i_fwd_b(w_fwd_ex_b),
      .i_forwarding_mux(w_fwd_ex_mux),
      .o_last_register_ctrl(w_ex_last_register_ctrl),
      //.o_select_reg_dir_to_write(w_select_reg_dir_to_write),
      .o_data_b_to_write(w_ex_data_b_to_write),
      .o_cero(w_ex_cero),
      .o_branch_addr(w_ex_branch_addr),
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
      .i_flush(w_flush_ex_mem),
      .i_cero(w_ex_cero),
      .i_pc4(w_ex_pc4),
      .i_jump(w_ex_jump),
      .i_jr_jalr(w_ex_jr_jalr),
      .i_alu_result(w_ex_alu_result),
      .i_data_b_to_write(w_ex_data_b_to_write),
      .i_mem_read(w_ex_mem_read),
      .i_mem_write(w_ex_mem_write),
      .i_mem_to_reg(w_ex_mem_to_reg),
      .i_signed(w_ex_signed),
      .i_reg_write(w_ex_reg_write),
      .i_reg_dir_to_write(w_ex_reg_dir_to_write),
      .i_last_register_ctrl(w_ex_last_register_ctrl),
      .i_word_size(w_ex_word_size),
      .i_branch(w_ex_branch),
      .i_branch_addr(w_ex_branch_addr),
      .i_halt(w_ex_halt),

      .o_alu_result(w_mem_alu_result),
      .o_jump(w_mem_jump),
      .o_jr_jalr(w_mem_jr_jalr),
      .o_pc4(w_mem_pc4),
      .o_last_register_ctrl(w_mem_last_register_ctrl),
      .o_data_b_to_write(w_mem_data_b_to_write),
      .o_mem_read(w_mem_mem_read),
      .o_mem_write(w_mem_mem_write),
      .o_mem_to_reg(w_mem_mem_to_reg),
      .o_signed(w_mem_signed),
      .o_reg_write(w_mem_reg_write),
      .o_reg_dir_to_write(w_mem_reg_dir_to_write),
      .o_word_size(w_mem_word_size),
      .o_branch(w_mem_branch),
      .o_cero(w_mem_cero),
      .o_branch_addr(w_mem_branch_addr),
      .o_halt(w_mem_halt)
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
      .i_signed(w_mem_signed),
      .i_debug_address(i_debug_address),
      .i_data_b_to_write(w_mem_data_b_to_write),
      .i_word_size(w_mem_word_size),
      .i_mem_write(w_mem_mem_write),
      .i_branch(w_mem_branch),
      .i_cero(w_mem_cero),
      .o_data_memory(w_mem_data_memory),
      .o_data_debug_memory(o_mips_data_memory),
      .o_branch_zero(w_branch_zero)
  );

  MEM_WB #(
      .NB(NB)
  ) mem_wb (
      .i_clk(i_clk),
      .i_step(i_step),
      .i_reset(i_reset),
      .i_pc4(w_mem_pc4),
      .i_last_register_ctrl(w_mem_last_register_ctrl),
      .i_reg_write(w_mem_reg_write),
      .i_reg_dir_to_write(w_mem_reg_dir_to_write),
      .i_mem_to_reg(w_mem_mem_to_reg),
      .i_data_memory(w_mem_data_memory),
      .i_alu_address_result(w_mem_alu_result),
      .i_halt(w_mem_halt),
      .o_pc4(w_wb_pc4),
      .o_last_register_ctrl(w_wb_last_register_ctrl),
      .o_reg_write(w_wb_reg_write),
      .o_reg_dir_to_write(w_wb_reg_dir_to_write),
      .o_mem_to_reg(w_wb_mem_to_reg),
      .o_data_memory(w_wb_data_memory),
      .o_alu_address_result(w_wb_alu_address_result),
      .o_halt(w_mips_wb_halt)
  );


  WRITE_BACK #(
      .NB(NB),
      .NB_REG(5)
  ) write_back (
      .i_mem_to_reg(w_wb_mem_to_reg),
      .i_last_register_ctrl(w_wb_last_register_ctrl),
      .i_mem_data(w_wb_data_memory),
      .i_alu_result(w_wb_alu_address_result),
      .i_pc4(w_wb_pc4),
      .o_data_to_write_in_register(w_wb_data_to_register)
  );

  forwarding_unit #(
      .REGS(5)
  ) forwarding_unit (
      .i_EX_MEM_rd(w_mem_reg_dir_to_write),  // RD corresnpondiente a la etapa EXECUTE/MEMORY
      .i_MEM_WB_rd(w_wb_reg_dir_to_write),  // RD corresnpondiente a la etapa MEMORY/WRITE-BACK
      .is_rt_a_destination(
        w_ex_instruction_op_code == `ADDI_OPCODE ||
        w_ex_instruction_op_code == `SLTI_OPCODE ||
        w_ex_instruction_op_code == `ANDI_OPCODE ||
        w_ex_instruction_op_code == `ORI_OPCODE  ||
        w_ex_instruction_op_code == `XORI_OPCODE ||
        w_ex_instruction_op_code == `LUI_OPCODE
      ),  // Si es una instruccion R-Type
      .i_rs(w_fwd_reg_dir_rs),  // data_a
      .i_rt(w_fwd_reg_dir_rt),  // data_b
      .i_EX_mem_write(w_ex_mem_write),  // Si se quiere escribir en memoria, corresponde a STOREs
      .i_MEM_write_reg(w_mem_reg_write),     // Si se quiere escribir en un Registro, valor desde la etapa MEMORY
      .i_WB_write_reg(w_wb_reg_write),     // Si se quiere escribir en un Registro, valor desde la etapa WRITE-BACK

      .o_forwarding_a  (w_fwd_ex_a),   // Si se forwardea el valor de A
      .o_forwarding_b  (w_fwd_ex_b),   // Si se forwardea el valor de B
      .o_forwarding_mux(w_fwd_ex_mux)
  );

  stall_unit #(
      .REGS(5)
  ) stall_unit (
      .i_ID_EX_rt(w_id_reg_dir_rt),
      .i_IF_ID_rs(w_id_instruction[25:21]),
      .i_IF_ID_rt(w_id_instruction[20:16]),
      .i_ID_EX_mem_read(w_ex_mem_read),
      .i_branch_taken(w_branch_zero),
      .i_EX_jump_or_jalr(w_ex_jump || w_ex_jr_jalr),
      .i_MEM_jump_or_jalr(w_mem_jump || w_mem_jr_jalr),
      .i_MEM_halt(w_mem_halt),
      .i_WB_halt(w_mips_wb_halt),

      .o_flush_IF_ID(w_flush_if_id),
      .o_flush_ID(w_flush_id),
      .o_flush_EX_MEM(w_flush_ex_mem),

      .o_stall_IF_ID(w_stall_if_id),
      .o_stall_pc(w_stall_pc)  // Previene que se incremente
  );

  assign o_mips_alu_result = w_ex_alu_result;
  assign o_mips_wb_halt = w_mips_wb_halt;
endmodule
