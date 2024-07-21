`timescale 1ns / 1ps

`include "instruction_constants.vh"
`include "decode_constants.vh"

module tb_ID;

  parameter NB = 32;
  parameter REGS = 5;
  parameter INBITS = 16;
  parameter CTRLNB = 6;
  parameter TAM_REG = 32;

  // Entradas
  reg                            i_clk;
  reg                            i_reset;
  reg                            i_step;
  reg  [NB-1:0]                  i_instruction;
  reg  [REGS-1:0]                i_mips_register_number; 

  // Salidas
  wire [NB-1:0]                  o_data_a;
  wire [NB-1:0]                  o_data_b;
  wire [NB-1:0]                  o_data_tx_debug;
  wire                           o_alu_src;
  wire [NB-1:0]                  o_extension_result;
  wire [CTRLNB-1:0]              o_intruction_funct_code;
  wire [CTRLNB-1:0]              o_intruction_op_code;

  // Valores esperados
  reg [NB-1:0]                   expected_data_a;
  reg [NB-1:0]                   expected_data_b;
  reg [NB-1:0]                   expected_data_tx_debug;
  reg                            expected_alu_src;
  reg [NB-1:0]                   expected_extension_result;
  reg [CTRLNB-1:0]               expected_intruction_funct_code;
  reg [CTRLNB-1:0]               expected_intruction_op_code;

  // Instanciamos el módulo ID
  ID #(
    .NB(NB),
    .REGS(REGS),
    .INBITS(INBITS),
    .CTRLNB(CTRLNB),
    .TAM_REG(TAM_REG)
  ) uut (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_step(i_step),
    .i_instruction(i_instruction),
    .i_mips_register_number(i_mips_register_number),
    .o_data_a(o_data_a),
    .o_data_b(o_data_b),
    .o_data_tx_debug(o_data_tx_debug),
    .o_alu_src(o_alu_src),
    .o_extension_result(o_extension_result),
    .o_intruction_funct_code(o_intruction_funct_code),
    .o_intruction_op_code(o_intruction_op_code)
  );

  // Inicialización del reloj
  initial begin
    i_clk = 0;
    forever #10 i_clk = ~i_clk;
  end

  // Casos de prueba
  initial begin
    // Monitor de señales
    $monitor(
        "time=%0t, i_instruction=%h, i_mips_register_number=%h, o_data_a=%h, o_data_b=%h, o_data_tx_debug=%h, o_alu_src=%b, o_extension_result=%h, o_intruction_funct_code=%h, o_intruction_op_code=%h",
        $time, i_instruction, i_mips_register_number, o_data_a, o_data_b, o_data_tx_debug, o_alu_src, o_extension_result, o_intruction_funct_code, o_intruction_op_code);

    // Inicialización de entradas
    i_reset = 1;
    i_step = 0;
    i_instruction = 0;
    i_mips_register_number = 0;
    expected_data_a = 0;
    expected_data_b = 0;
    expected_data_tx_debug = 0;
    expected_alu_src = 0;
    expected_extension_result = 0;
    expected_intruction_funct_code = 0;
    expected_intruction_op_code = 0;
    
    @(posedge i_clk);

    // Salir del reset
    i_reset = 0;

    // Prueba 1: instrucción de ejemplo ADDI
    i_instruction = {`ADDI_OPCODE, 5'd1, 5'd2, 16'hFFF2}; // ejemplo
    i_mips_register_number = 4'b0001;
    expected_intruction_op_code = 6'b001000; // ejemplo
    expected_alu_src = 1; // según control_unit
    expected_extension_result = -14; // según extensor_signo
    expected_data_a = 32'h00000001;
    expected_data_b = 32'h00000002;

    #10;
    if (o_intruction_op_code !== expected_intruction_op_code ||
        o_alu_src !== expected_alu_src || 
        o_extension_result !== expected_extension_result
    ) begin
      $display("Prueba 1 fallida: o_intruction_op_code=%h, expected_intruction_op_code=%h, o_intruction_funct_code=%h, expected_intruction_funct_code=%h, o_alu_src=%b, expected_alu_src=%b, o_extension_result=%h, expected_extension_result=%h",
          o_intruction_op_code, expected_intruction_op_code, o_intruction_funct_code, expected_intruction_funct_code, o_alu_src, expected_alu_src, o_extension_result, expected_extension_result);
      $finish;
    end

    // Prueba 2: otra instrucción de ejemplo ADD
    i_instruction = {`RTYPE_OPCODE, 5'd5, 5'd3, 5'd4, 5'b0, `ADD_FCODE};
    i_mips_register_number = 4'b0010;
    expected_intruction_op_code = `RTYPE_OPCODE; // ejemplo
    expected_intruction_funct_code = `ADD_FCODE; // ejemplo
    expected_alu_src = `RT_ALU_SRC; // según control_unit
    expected_extension_result = 32'h00002020; // según 
    expected_data_a = 5;
    expected_data_b = 3;

    #10;
    if (o_intruction_op_code !== expected_intruction_op_code || o_intruction_funct_code !== expected_intruction_funct_code || o_alu_src !== expected_alu_src || o_extension_result !== expected_extension_result) begin
      $display("Prueba 2 fallida: o_intruction_op_code=%h, expected_intruction_op_code=%h, o_intruction_funct_code=%h, expected_intruction_funct_code=%h, o_alu_src=%b, expected_alu_src=%b, o_extension_result=%h, expected_extension_result=%h",
          o_intruction_op_code, expected_intruction_op_code, o_intruction_funct_code, expected_intruction_funct_code, o_alu_src, expected_alu_src, o_extension_result, expected_extension_result);
      $finish;
    end

    $display("Todas las pruebas pasaron.");
    $finish;
  end

endmodule
