`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2024 16:28:48
// Design Name: 
// Module Name: test_instruction_fetch
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


module test_instruction_fetch;

    parameter WIDTH = 32;
    
    reg i_clock;
    wire [WIDTH-1:0] o_instruction;
    
    instruction_fetch #(.WIDTH(WIDTH)) uut (
        .i_clock(i_clock),
        .o_instruction(o_instruction)
    );
    
    always #10 i_clock = ~i_clock;
    initial begin
        i_clock = 1'b0;
    end;
    
    initial begin
        #10
        if (o_instruction != 32'h5) begin
            $display("Debería valer 5 por que es el valor del address 0x0");
            $finish;
        end
        
        #10
        
        if (o_instruction != 32'h7a) begin
            $display("Debería valer 7a porque es el valor del address 0x4");
            $finish;
        end
        #5
        if (o_instruction != 32'h7a) begin
            $display("Debería seguir valiendo 7a porque no hubo un nuevo flanco");
            $finish;
        end
        
        #6
        if (o_instruction != 32'h9b) begin
            $display("Debería valer 80 porque es el valor del address 0x8");
            $finish;
        end
        
        $display("Todos los tests exitosos");
        $finish;
    end;
    

endmodule
