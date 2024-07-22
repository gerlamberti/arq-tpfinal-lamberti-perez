`timescale 1ns / 1ps
`include "memory_constants.vh"

module tb_MEMORY;

  parameter NB = 32;
  parameter TAM = 16;
  parameter NB_ADDR = $clog2(TAM);
  parameter NB_SIZE_TYPE = 3;

  // Inputs
  reg i_clk;
  reg i_reset;
  reg i_step;
  reg [NB-1:0] i_alu_address_result;
  reg [NB-1:0] i_debug_address;
  reg [NB-1:0] i_data_b_to_write;
  reg [NB_SIZE_TYPE-1:0] i_word_size;
  reg i_mem_read;
  reg i_mem_write;
  reg i_reg_write;
  reg i_signed;

  // Outputs
  wire [NB-1:0] o_data_memory;
  wire [NB-1:0] o_data_debug_memory;

  // Expected values
  reg [NB-1:0] expected_data_memory;

  // Instantiate the MEMORY module
  MEMORY #() uut (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_step(i_step),
      .i_alu_address_result(i_alu_address_result),
      .i_debug_address(i_debug_address),
      .i_data_b_to_write(i_data_b_to_write),
      .i_word_size(i_word_size),
      .i_mem_read(i_mem_read),
      .i_mem_write(i_mem_write),
      .i_reg_write(i_reg_write),
      .i_signed(i_signed),
      .o_data_memory(o_data_memory),
      .o_data_debug_memory(o_data_debug_memory)
  );

  // Clock generation
  always #10 i_clk = ~i_clk;

  initial begin
    i_clk = 0;
    i_reset = 1;
    i_step = 0;
    i_alu_address_result = 0;
    i_debug_address = 0;
    i_data_b_to_write = 0;
    i_word_size = 0;
    i_mem_read = 0;
    i_mem_write = 0;
    i_reg_write = 0;
    i_signed = 0;
    #10;

    i_reset = 0;

    // Test case 1: Write a word to memory and read back
    i_alu_address_result = 32'h00000004;
    i_data_b_to_write = 32'hA5A5A5A5;
    i_word_size = `COMPLETE_WORD;  // Word size
    i_step = 1;
    @(posedge i_clk);
    i_mem_write = 1;
    @(posedge i_clk);
    i_mem_write = 0;
    @(posedge i_clk);
    i_mem_read = 1;

    expected_data_memory = 32'hA5A5A5A5;
    @(posedge i_clk);
    if (o_data_memory !== expected_data_memory) begin
      $display("Test case 1 failed: o_data_memory = %h, expected = %h", o_data_memory,
               expected_data_memory);
      $finish;
    end else begin
      $display("Test case 1 passed: o_data_memory = %h", o_data_memory);
    end

    // Test case 2: Write a halfword to memory and read back
    i_alu_address_result = 32'h00000008;
    i_data_b_to_write = 32'h0000BEEF;
    i_word_size = `HALF_WORD;  // Halfword size
    i_mem_write = 1;
    i_step = 1;
    @(posedge i_clk);
    i_mem_write = 0;
    i_step = 0;
    @(posedge i_clk);

    i_mem_read = 1;
    i_step = 1;
    @(posedge i_clk);
    i_mem_read = 0;
    i_step = 0;
    @(posedge i_clk);

    expected_data_memory = 32'h0000BEEF;
    if (o_data_memory !== expected_data_memory) begin
      $display("Test case 2 failed: o_data_memory = %h, expected = %h", o_data_memory,
               expected_data_memory);
      $finish;
    end else begin
      $display("Test case 2 passed: o_data_memory = %h", o_data_memory);
    end

    // Test case 3: Write a byte to memory and read back
    i_alu_address_result = 32'h0000000C;
    i_data_b_to_write = 32'h0000007F;
    i_word_size = `BYTE_WORD;  // Byte size
    i_mem_write = 1;
    i_step = 1;
    @(posedge i_clk);
    i_mem_write = 0;
    i_step = 0;
    @(posedge i_clk);

    i_mem_read = 1;
    i_step = 1;
    @(posedge i_clk);
    i_mem_read = 0;
    i_step = 0;
    @(posedge i_clk);

    expected_data_memory = 32'h0000007F;
    if (o_data_memory !== expected_data_memory) begin
      $display("Test case 3 failed: o_data_memory = %h, expected = %h", o_data_memory,
               expected_data_memory);
      $finish;
    end else begin
      $display("Test case 3 passed: o_data_memory = %h", o_data_memory);
    end

    $display("All tests passed.");
    $finish;
  end

endmodule
