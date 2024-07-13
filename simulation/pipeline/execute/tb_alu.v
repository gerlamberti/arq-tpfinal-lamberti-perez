`timescale 1ns / 1ps

module tb_ALU;

  parameter NB = 32;
  parameter NB_OP = 4;

  reg [NB-1:0] i_data_a;
  reg [NB-1:0] i_data_b;
  reg [NB_OP-1:0] i_operation;

  wire o_cero;
  wire [NB-1:0] o_result;

  ALU #() uut (
      .i_data_a(i_data_a),
      .i_data_b(i_data_b),
      .i_operation(i_operation),
      .o_cero(o_cero),
      .o_result(o_result)
  );
    reg [NB-1:0] expected;

  // Test cases
  initial begin
    // Monitor signals
    $monitor("time=%0t, i_data_a=%h, i_data_b=%h, i_operation=%h, o_result=%h, o_cero=%b", $time,
             i_data_a, i_data_b, i_operation, o_result, o_cero);

    // Initialize inputs
    i_data_a = 0;
    i_data_b = 0;
    i_operation = 0;
    #10;

    // Test AND operation
    i_data_a = 32'hA5A5A5A5;
    i_data_b = 32'h5A5A5A5A;
    i_operation = `AND;
    #10;
    if (o_result !== (i_data_a & i_data_b) || o_cero !== 1) begin
      $display("Test AND failed: o_result=%h, o_cero=%b", o_result, o_cero);
      $finish;
    end

    // Test OR operation
    i_operation = `OR;
    #10;
    if (o_result !== (i_data_a | i_data_b) || o_cero !== 0) begin
      $display("Test OR failed: o_result=%h, o_cero=%b", o_result, o_cero);
      $finish;
    end

    // Test ADD operation
    i_data_a = 32'h00000001;
    i_data_b = 32'h00000001;
    i_operation = `ADD;
    #10;
    if (o_result !== (i_data_a + i_data_b) || o_cero !== 0) begin
      $display("Test ADD failed: o_result=%h, o_cero=%b", o_result, o_cero);
      $finish;
    end

    // Test SUB operation
    i_data_a = 32'h00000002;
    i_data_b = 32'h00000001;
    i_operation = `SUB;
    #10;
    if (o_result !== (i_data_a - i_data_b) || o_cero !== 0) begin
      $display("Test SUB failed: o_result=%h, o_cero=%b", o_result, o_cero);
      $finish;
    end

    // Test SLT operation
    i_data_a = 32'h00000001;
    i_data_b = 32'h00001234;
    i_operation = `SLT;
    #10;
    if (o_result !== (i_data_a < i_data_b ? 1 : 0) || o_cero !== 0) begin
      $display("Test SLT failed: o_result=%h, o_cero=%b", o_result, o_cero);
      $finish;
    end

    // Test NOR operation
    i_data_a = 32'h23FBA5A5;
    i_data_b = 32'hCA2ACC5A;
    i_operation = `NOR;
    #10;
    if (o_result !== ~(i_data_a | i_data_b) || o_cero !== 0) begin
      $display("Test NOR failed: o_result=%h, o_cero=%b", o_result, o_cero);
      $finish;
    end

    // Test XOR operation
    i_operation = `XOR;
    #10;
    if (o_result !== (i_data_a ^ i_data_b) || o_cero !== 0) begin
      $display("Test XOR failed: o_result=%h, o_cero=%b", o_result, o_cero);
      $finish;
    end

    // Test SLL operation
    i_data_a = 32'h00000002;
    i_data_b = 32'h00010001;
    i_operation = `SLL;
    #10;
    if (o_result !== (i_data_b << i_data_a) || o_cero !== 0) begin
      $display("Test SLL failed: o_result=%h, o_cero=%b", o_result, o_cero);
      $finish;
    end

    // Test SRL operation
    i_operation = `SRL;
    #10;
    if (o_result !== (i_data_b >> i_data_a) || o_cero !== 0) begin
      $display("Test SRL failed: o_result=%h, o_cero=%b", o_result, o_cero);
      $finish;
    end

    // Test SRA operation
    i_data_a = 32'h00000002;
    i_data_b = 32'h80000004;
    i_operation = `SRA;
    #10;
    expected = $signed(i_data_b) >>> i_data_a;
    if (o_result !== expected || o_cero !== 0) begin
      $display("Test SRA failed: o_result=%h, o_cero=%b", o_result, o_cero);
      $finish;
    end

    $display("All tests passed.");
    $finish;
  end

endmodule
