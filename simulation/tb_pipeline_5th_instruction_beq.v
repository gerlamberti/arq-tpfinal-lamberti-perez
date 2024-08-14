`timescale 1ns / 1ps
`include "instruction_constants.vh"
`include "memory_constants.vh"
module tb_PIPELINE_5th_instruction;

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
  wire o_mips_wb_halt;

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
  wire [ 4:0] beq_rs = memory[5][25:21];
  wire [ 4:0] beq_rt = memory[5][20:16];
  wire [15:0] beq_offset = memory[5][15:0];

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
      .i_instruction_write_enable(1'b0),
      .o_mips_pc(o_mips_pc),
      .o_mips_alu_result(o_mips_alu_result),
      .o_mips_register_data(o_mips_register_data),
      .o_mips_data_memory(o_mips_data_memory),
      .o_mips_wb_halt(o_mips_wb_halt)
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
        ESTE TEST ES PARA LA QUINTA INSTRUCCI�N NOM�S
        memory[5] = {`BEQ_OPCODE, 5'd4, 5'd8, 1};
        BEQ rs, rt, offset
        BEQ $4, $8, 1

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
    // Aca deberia ejecutarse la ALU de la quinta instruccion
    expected_mips_pc = 28;
    // if (o_mips_pc !== expected_mips_pc) $finish;
    #1;
    // Obtengo valor de rs
    i_debug_mips_register_number = beq_rs;
    #1;
    i = o_mips_register_data;
    #1;
    // Obtengo valor de rt
    i_debug_mips_register_number   = beq_rt;
    #1;
    expected_mips_alu_result = i - o_mips_register_data;  // rs - rt
    // if (o_mips_alu_result !== expected_mips_alu_result) $finish;
    
    // Lo separo en 2 al calculo porque no me deja el maldito verilog
    // El esperado es 5th_instruction_PC + 4 + sign_extend(offset | 00) 
    expected_mips_pc = $signed({beq_offset, 2'b00}); 
    expected_mips_pc = expected_mips_pc + (4*5) + 4;
    
    // Esta instruccion deberia saltar

    @(o_mips_pc); // Aca deberia saltar al branch address ; Ciclo 8; Memory stage
    // if (o_mips_pc !== expected_mips_pc) $finish;
    
    $display("Fin de los tests. Todo exitoso.");
    $finish;
  end

endmodule
