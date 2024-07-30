`timescale 1ns / 1ps
`include "instruction_constants.vh"
`include "memory_constants.vh"
`define OVERRIDE_INSTRUCTIONS

module tb_pipeline_4th_instruction_lw;

  parameter NB = 32;
  parameter NB_SIZE_TYPE = 3;
  parameter TAM_DATA_MEMORY = 16;


  // Inputs
  reg i_clk;
  reg i_reset;
  reg i_step;
  reg [4:0] i_debug_mips_register_number;
  reg [NB-1:0] i_debug_address;

  // Outputs
  wire [NB-1:0] o_mips_pc;
  wire [NB-1:0] o_mips_alu_result;
  wire [NB-1:0] o_debug_reg_data;
  wire [NB-1:0] o_debug_address_data;

  // Expected values
  reg signed [NB-1:0] expected_mips_pc;
  reg signed [NB-1:0] expected_mips_alu_result;
  reg [NB-1:0] expected_mips_register_data;
  reg [NB-1:0] expected_mips_data_memory;

  integer i;
  reg [31:0] memory[0:16];
  initial begin
    `include "override_instructions.vh"
  end
  wire [ 4:0] lw_base = memory[4][25:21];
  wire [ 4:0] lw_rt = memory[4][20:16];
  wire [15:0] lw_offset = memory[4][15:0];

  // Instantiate the PIPELINE module
  PIPELINE #(
      .NB(NB),
      .NB_SIZE_TYPE(NB_SIZE_TYPE)
  ) uut (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_step(i_step),
      .i_debug_mips_register_number(i_debug_mips_register_number),
      .i_debug_address(i_debug_address),
      .o_mips_pc(o_mips_pc),
      .o_mips_alu_result(o_mips_alu_result),
      .o_mips_register_data(o_debug_reg_data),
      .o_mips_data_memory(o_debug_address_data)
  );

  // Clock generation
  always #10 i_clk = ~i_clk;

  initial begin : test
    i_clk = 0;
    i_reset = 1;
    i_step = 0;
    i_debug_mips_register_number = 0;
    i_debug_address = 0;
    @(posedge i_clk);
    @(posedge i_clk);

    i_reset = 0;

    // Setup initial values for expected results
    expected_mips_pc = 0;
    expected_mips_alu_result = 0;
    expected_mips_register_data = 0;
    expected_mips_data_memory = 0;
    @(posedge i_clk);


    $display("Initial setup complete.");
    /***
        ESTE TEST ES PARA LA CUARTA INSTRUCCI�N NOM�S
        LW rt, offset(base)
        LW $1, 9($8)
        rt <- memory[base+offset]

    **/
    // Ponemos el step en alto y esperamos 1 clock
    i_step = 1;
    @(o_mips_pc);  // PC = 4; Ciclo 1;
    @(o_mips_pc);  // PC = 8; Ciclo 2;
    @(o_mips_pc);  // PC = 12; Ciclo 3;
    @(o_mips_pc);  // PC = 16; Ciclo 4;
    @(o_mips_pc);  // PC = 20; Ciclo 5;
    @(o_mips_pc);  // PC = 24; Ciclo 6;
    // Aca deberia ejecutarse la ALU de la CUARTA instruccion
    expected_mips_pc = 24;
    if (o_mips_pc !== expected_mips_pc) $finish;
    #1;
    // Obtengo valor de base
    i_debug_mips_register_number = lw_base;
    #1;
    i = o_debug_reg_data;
    // Calculo el sign_extend(offset) + GPR[base]
    expected_mips_alu_result = $signed({lw_offset});
    expected_mips_alu_result = expected_mips_alu_result + i;
    if (o_mips_alu_result !== expected_mips_alu_result) $finish;
    // Ahora me guardo en expected_mips_register_data = memory[base+offset]
    i_debug_address = expected_mips_alu_result;
    #1;
    expected_mips_register_data = o_debug_address_data;
    
    @(o_mips_pc);  // PC = 28; Ciclo 7;
    @(o_mips_pc);  // PC = 32; Ciclo 8;
    i_debug_mips_register_number = lw_rt;    
    @(posedge i_clk) // Tengo que esperar un posedge del clock para que le llegue la se�al al decode
    // Ahora deberia haber escrito en registro rt
    if(expected_mips_register_data !== o_debug_reg_data) $finish;

    $display("Fin de los tests. Todo exitoso.");
    $finish;
  end

endmodule
