`timescale 1ns / 1ps
`include "instruction_constants.vh"
`include "memory_constants.vh"

module tb_PIPELINE_6th_instruction_jump;

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
  wire [NB-1:0] o_mips_register_data;
  wire [NB-1:0] o_mips_data_memory;

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
  wire [25:0] jump_instr_index = memory[6][25:0];

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
      .o_mips_register_data(o_mips_register_data),
      .o_mips_data_memory(o_mips_data_memory)
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
        ESTE TEST ES PARA LA SEXTA INSTRUCCI�N NOM�S
        memory[6] = {`J_OPCODE, 26'd2};  // J 2, deberia saltar a instruccion 2
        J Target
        J 2

    **/
    // Ponemos el step en alto y esperamos 1 clock
    i_step = 1;
    @(o_mips_pc);  // PC = 4; Ciclo 1;
    @(o_mips_pc);  // PC = 8; Ciclo 2;
    @(o_mips_pc);  // PC = 12; Ciclo 3;
    @(o_mips_pc);  // PC = 16; Ciclo 4;
    @(o_mips_pc);  // PC = 20; Ciclo 5;
    @(o_mips_pc);  // PC = 24; Ciclo 6;
    @(o_mips_pc);  // PC = 28; Ciclo 7;
    // Aca esta en el decode de la instruccion 6
    // Aca calcula la direccion de salto, pero no salta
    expected_mips_pc = 28;
    if (o_mips_pc !== expected_mips_pc) $finish;
    @(o_mips_pc);  // PC = 32; Ciclo 8;
    // Aca deberia ejecutarse el jump (EX STage de instruccion 6)
    @(posedge i_clk); // Tengo que esperar que le llegue el posedge al fetch
    expected_mips_pc = {jump_instr_index, 2'b00};
    if (o_mips_pc !== expected_mips_pc) $finish;

    $display("Fin de los tests. Todo exitoso.");
    $finish;
  end

endmodule
