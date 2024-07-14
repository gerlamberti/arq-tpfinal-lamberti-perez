`timescale 1ns / 1ps
`include "instruction_constants.vh"
`include "execute_constants.vh"

module tb_EXECUTE;

  parameter NB = 32;
  parameter NB_FCODE = 6;
  parameter NB_OPCODE = 6;
  parameter NB_ALU_OP = 4;

  // Entradas
  reg  [ NB_FCODE-1:0] i_instruction_funct_code;
  reg  [NB_OPCODE-1:0] i_instruction_op_code;
  reg                  i_alu_src;
  reg  [       NB-1:0] i_data_a;
  reg  [       NB-1:0] i_data_b;
  reg  [       NB-1:0] i_immediate_extended;

  // Salidas
  wire                 o_cero;
  wire [       NB-1:0] o_alu_result;

  // Valores esperados
  reg  [       NB-1:0] expected_alu_result;
  reg                  expected_o_cero;

  // Instanciamos el módulo EXECUTE
  EXECUTE #() uut (
      .i_instruction_funct_code(i_instruction_funct_code),
      .i_instruction_op_code(i_instruction_op_code),
      .i_alu_src(i_alu_src),
      .i_data_a(i_data_a),
      .i_data_b(i_data_b),
      .i_immediate_extended(i_immediate_extended),
      .o_cero(o_cero),
      .o_alu_result(o_alu_result)
  );

  // Casos de prueba
  initial begin
    // Monitor de señales
    $monitor(
        "time=%0t, i_instruction_funct_code=%h, i_instruction_op_code=%h, i_alu_src=%b, i_data_a=%h, i_data_b=%h, i_immediate_extended=%h, o_alu_result=%h, o_cero=%b",
        $time, i_instruction_funct_code, i_instruction_op_code, i_alu_src, i_data_a, i_data_b,
        i_immediate_extended, o_alu_result, o_cero);

    // Inicialización de entradas
    i_instruction_funct_code = 0;
    i_instruction_op_code = 0;
    i_alu_src = 0;
    i_data_a = 0;
    i_data_b = 0;
    i_immediate_extended = 0;
    expected_alu_result = 0;
    expected_o_cero = 0;
    #10;

    // Prueba de operación ADD con data_b
    i_instruction_funct_code = `ADD_FCODE;
    i_instruction_op_code = `RTYPE_OPCODE;
    i_alu_src = 0;
    i_data_a = 32'h00000001;
    i_data_b = 32'h00000001;
    i_immediate_extended = 32'h00000000;
    expected_alu_result = 32'h00000002;
    expected_o_cero = 0;
    #10;
    if (o_alu_result !== expected_alu_result || o_cero !== expected_o_cero) begin
      $display(
          "Prueba ADD con data_b fallida: o_alu_result=%h, expected_alu_result=%h, o_cero=%b, expected_o_cero=%b",
          o_alu_result, expected_alu_result, o_cero, expected_o_cero);
      $finish;
    end

    // Prueba de operación ADD con immediate
    i_alu_src = 1;
    i_data_a = 32'h00000001;
    i_immediate_extended = 32'h00000004;
    expected_alu_result = 32'h00000005;
    expected_o_cero = 0;
    #10;
    if (o_alu_result !== expected_alu_result || o_cero !== expected_o_cero) begin
      $display(
          "Prueba ADD con immediate fallida: o_alu_result=%h, expected_alu_result=%h, o_cero=%b, expected_o_cero=%b",
          o_alu_result, expected_alu_result, o_cero, expected_o_cero);
      $finish;
    end

    // Prueba de operación SUB con data_b
    i_instruction_funct_code = `SUB_FCODE;
    i_instruction_op_code = `RTYPE_OPCODE;
    i_alu_src = 0;
    i_data_a = 32'd50;
    i_data_b = 32'd15;
    i_immediate_extended = 32'h00000000;
    expected_alu_result = i_data_a - i_data_b;
    expected_o_cero = 0;
    #10;
    if (o_alu_result !== expected_alu_result || o_cero !== expected_o_cero) begin
      $display(
          "Prueba SUB con data_b fallida: o_alu_result=%h, expected_alu_result=%h, o_cero=%b, expected_o_cero=%b",
          o_alu_result, expected_alu_result, o_cero, expected_o_cero);
      $finish;
    end

    // Prueba de operación SUB con immediate
    i_alu_src = 1;
    i_data_a = 32'd30;
    i_immediate_extended = 32'd4;
    expected_alu_result = i_data_a - i_immediate_extended ;
    expected_o_cero = 0;
    #10;
    if (o_alu_result !== expected_alu_result || o_cero !== expected_o_cero) begin
      $display(
          "Prueba SUB con immediate fallida: o_alu_result=%h, expected_alu_result=%h, o_cero=%b, expected_o_cero=%b",
          o_alu_result, expected_alu_result, o_cero, expected_o_cero);
      $finish;
    end

    $display("Todas las pruebas pasaron.");
    $finish;
  end

endmodule
