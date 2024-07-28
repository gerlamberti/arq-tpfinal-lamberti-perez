`timescale 1ns / 1ps
`include "memory_constants.vh"
`define OVERRIDE_INSTRUCTIONS

module tb_PIPELINE_2nd_instruction;

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
  reg [NB-1:0] expected_mips_pc;
  reg signed [NB-1:0] expected_mips_alu_result;
  reg [NB-1:0] expected_mips_register_data;
  reg [NB-1:0] expected_mips_data_memory;

  integer i;

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

  initial begin
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
        ESTE TEST ES PARA LA SEGUNDA INSTRUCCI�N NOM�S
        memory[2] = {`RTYPE_OPCODE, 5'd5, 5'd3, 5'd4, 5'b0, `ADD_FCODE};
        ADD rd, rs, rt
        ADD $4, $5, $3
        $4 <- $5 + $3

    **/
    // Ponemos el step en alto y esperamos 1 clock
    i_step = 1;
    @(o_mips_pc);  // PC = 4; Ciclo 1;
    @(o_mips_pc);  // PC = 8; Ciclo 2;
    @(o_mips_pc);  // PC = 12; Ciclo 3;
    @(o_mips_pc);  // PC = 16; Ciclo 4;
    // Aca deberia ejecutarse la ALU de la segunda instruccion
    expected_mips_pc = 16;
    #1;
    i_debug_mips_register_number = 5;
    #1;
    expected_mips_alu_result = o_mips_register_data;
    #1;
    i_debug_mips_register_number = 3;
    #1;
    expected_mips_alu_result = expected_mips_alu_result + o_mips_register_data;
    if (o_mips_pc !== expected_mips_pc) $finish;
    if (o_mips_alu_result !== expected_mips_alu_result) $finish;
    // Memory stage
    @(o_mips_pc);  // PC = 20; Ciclo 5;
    i_step = 0;  // Dejo en bajo para no alterar nada
    // No deberia haber cambios
    for (i = 0; i < TAM_DATA_MEMORY; i = i + 1) begin
      #1;
      i_debug_address = i * 4;
      if (o_mips_data_memory !== 0) $finish;
      #1;
    end
    i_step = 1;

    @(o_mips_pc);  // PC = 24; Ciclo 6;
    // Write back
    // Aún no debería haber cambios en el registro
    i_debug_mips_register_number = 4;
    #1;
    expected_mips_register_data = 4;
    if (o_mips_register_data !== expected_mips_register_data) $finish;

    @(o_mips_pc);  // PC = 28; Ciclo 7;
    // Ahora si se deberia haber escrito el rt register
    #1;  // Espero que se actualice el valor.
    expected_mips_register_data = expected_mips_alu_result;
    if (o_mips_register_data !== expected_mips_register_data) $finish;


    $display("Fin de los tests. Todo exitoso.");
    $finish;
  end

endmodule
