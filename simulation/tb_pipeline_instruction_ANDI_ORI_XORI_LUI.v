`timescale 1ns / 1ps
`include "instruction_constants.vh"
`include "memory_constants.vh"

module tb_pipeline_instruction_ANDI_ORI_XORI_LUI;

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
        ESTE TEST ES PARA LA SEGUNDA INSTRUCCI�N NOM�S
        memory[1] = {`ADDI_OPCODE, 5'd1, 5'd7, 16'd3};  // $7 <- $1 + 1             = 2 = 0010
        ADDI rt, rs, inmediate
        ADDI 7, 1, 3
        $3 <- $7 << $1

    **/
    // Ponemos el step en alto y esperamos 1 clock
    i_step = 1;
    @(o_mips_pc);  // PC = 4; Ciclo 1; // fetch
    @(o_mips_pc);  // PC = 8; Ciclo 2; // decode
    @(o_mips_pc);  // PC = 12; Ciclo 3;
    // Aca esta en el execute de la instruccion 2
    
    expected_mips_pc = 12;
    #1;
    i_debug_mips_register_number = 1;
    #1;
    expected_mips_alu_result = o_mips_register_data;
    #1;
    i = 3;
    #1;
    expected_mips_alu_result = expected_mips_alu_result + i;

    if (o_mips_pc !== expected_mips_pc) $finish;
    if (o_mips_alu_result !== expected_mips_alu_result) $finish;

    @(o_mips_pc);  // PC = 16; Ciclo 4;

    i_debug_mips_register_number = 7;
    #1;
    expected_mips_register_data = 7;
    if (o_mips_register_data !== expected_mips_register_data) $finish;

    @(o_mips_pc);  // PC = 20; Ciclo 5;
    // Aca esta en el wb de la instruccion 2

    i_debug_mips_register_number = 7;
    #1;
    expected_mips_register_data = 4;
    #1;  // Espero que se actualice el valor.
    expected_mips_register_data = expected_mips_alu_result;
    if (o_mips_register_data !== expected_mips_register_data) $finish;

    $display("Fin de los tests. Todo exitoso.");
    $finish;
  end

endmodule
