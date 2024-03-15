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
    wire [WIDTH-1:0] o_pc;
    
    instruction_fetch #(.WIDTH(WIDTH)) uut (
        .i_clock(i_clock),
        .o_pc(o_pc)
    );
    
    always #10 i_clock = ~i_clock;
    initial begin
        i_clock = 1'b0;
    end;
    
    initial begin
        #10
        if (o_pc != 0) begin
            $display("Debería valer 0");
            $finish;
        end
        
        #10
        
        if (o_pc != 4) begin
            $display("Debería valer 4");
            $finish;
        end
        #5
        if (o_pc != 4) begin
            $display("Debería seguir valiendo 4 porque no hubo un nuevo flanco");
            $finish;
        end
        
        #6
        if (o_pc != 8) begin
            $display("Debería valer 8");
            $finish;
        end
        
        $display("Todos los tests exitosos");
        $finish;
    end;
    

endmodule
