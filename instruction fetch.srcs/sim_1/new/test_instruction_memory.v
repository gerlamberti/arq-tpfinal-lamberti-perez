`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2024 17:21:55
// Design Name: 
// Module Name: test_instruction_memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_instruction_memory;
    parameter WIDTH = 32;
    parameter MAX_NUM_OF_INSTRUCTIONS = 10;
    
    // Inputs
    reg [WIDTH-1:0] i_instruction_address;
    // Outputs
    wire [WIDTH-1:0] o_instruction;
    
    instruction_memory 
    #(
        .WIDTH(WIDTH),
        .MAX_NUM_OF_INSTRUCTIONS(MAX_NUM_OF_INSTRUCTIONS)
    ) uut (
        .i_instruction_address(i_instruction_address),
        .o_instruction(o_instruction)
    );
    
    initial begin
        #10
        i_instruction_address = 32'h0;
        #1
        if (o_instruction != 32'h5) begin
            $display("Anduvo mal");
            $finish;
        end;
        
        #10
        i_instruction_address = 32'h4;
        #1
        if (o_instruction != 32'h7a) begin
            $display("Anduvo mal");
            $finish;
        end;
        
        #10
        i_instruction_address = 32'h5;
        // En este caso tiene que devolver lo mismo que la instrucction_address 4
        // ya que el modulo no esta preparado para devolver instrucciones cuyo address
        // no sean un múltiplo de 4
        #1
        if (o_instruction != 32'h7a) begin
            $display("Anduvo mal. Tiene que dar el mismo numero que antes.");
            $finish;
        end;
        #10
        
        $finish;
    end;
    
    
endmodule
