`timescale 1ns / 1ps

module EX_MEM #(
    parameter NB = 32,
    parameter NB_SIZE_TYPE = 3,
    parameter NB_REGS = 5
) (
    input                    i_clk,
    input                    i_step,
    input                    i_reset,
    input                    i_cero,
    input                    i_branch,
    input                    i_jump,
    input                    i_jr_jalr,
    input                    i_last_register_ctrl,
    input [          NB-1:0] i_alu_result,
    input [          NB-1:0] i_branch_addr,
    input [          NB-1:0] i_data_b_to_write,
    input [          NB-1:0] i_pc4,
    input                    i_mem_read,
    input                    i_mem_write,
    input                    i_reg_write,
    input                    i_mem_to_reg,
    input                    i_signed,
    input [     NB_REGS-1:0] i_reg_dir_to_write,
    input [NB_SIZE_TYPE-1:0] i_word_size,
    input                    i_flush,
    input                    i_halt,

    output reg                    o_cero,
    output reg [          NB-1:0] o_pc4,
    output reg [          NB-1:0] o_alu_result,
    output reg [          NB-1:0] o_data_b_to_write,
    output reg                    o_mem_read,
    output reg                    o_mem_write,
    output reg                    o_mem_to_reg,
    output reg                    o_signed,
    output reg                    o_reg_write,
    output reg [     NB_REGS-1:0] o_reg_dir_to_write,
    output reg [NB_SIZE_TYPE-1:0] o_word_size,
    output reg                    o_branch,
    output reg [          NB-1:0] o_branch_addr,
    output reg                    o_halt,
    output reg                    o_jump,
    output reg                    o_jr_jalr,
    output reg                    o_last_register_ctrl
);

  always @(negedge i_clk) begin
    if (i_reset) begin
      o_cero             <= 0;
      o_pc4             <= 0;
      o_alu_result       <= 0;
      o_mem_read         <= 0;
      o_mem_write        <= 0;
      o_mem_to_reg       <= 0;
      o_reg_write        <= 0;
      o_reg_dir_to_write <= 0;
      o_word_size        <= 0;
      o_branch           <= 0;
      o_branch_addr      <= 0;
      o_data_b_to_write  <= 0;
      o_jump             <= 0;
      o_jr_jalr          <= 0;
      o_last_register_ctrl<= 0;
      o_signed           <= 0;
      o_halt             <= 0;
    end else begin
      if (i_flush) begin // Buscar respuesta en el libro. 
        o_cero             <= 0;
        o_pc4              <= 0;
        o_alu_result       <= i_alu_result;
        o_mem_read         <= 0;
        o_mem_write        <= 0;
        o_mem_to_reg       <= 0;
        o_reg_write        <= 0;
        o_reg_dir_to_write <= i_reg_dir_to_write;
        o_word_size        <= 0;
        o_branch           <= 0;
        o_jump             <= 0;
        o_jr_jalr          <= 0;
        o_last_register_ctrl<= 0;
        o_branch_addr      <= i_branch_addr;
        o_data_b_to_write  <= i_data_b_to_write;
        o_signed           <= 0;
        o_halt             <= 0;
      end else if (i_step) begin
        o_cero             <= i_cero;
        o_pc4              <= i_pc4;
        o_alu_result       <= i_alu_result;
        o_mem_read         <= i_mem_read;
        o_mem_write        <= i_mem_write;
        o_mem_to_reg       <= i_mem_to_reg;
        o_reg_write        <= i_reg_write;
        o_reg_dir_to_write <= i_reg_dir_to_write;
        o_word_size        <= i_word_size;
        o_branch           <= i_branch;
        o_jump             <= i_jump;
        o_jr_jalr          <= i_jr_jalr;
        o_last_register_ctrl <= i_last_register_ctrl;
        o_branch_addr      <= i_branch_addr;
        o_data_b_to_write  <= i_data_b_to_write;
        o_signed           <= i_signed;
        o_halt             <= i_halt;
      end
    end
  end

endmodule
