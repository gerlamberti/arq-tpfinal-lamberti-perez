`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2024 16:30:06
// Design Name: 
// Module Name: test_adder
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


module test_adder;

    // Inputs
    reg [7:0] i_A;
    reg [7:0] i_B;
    
    // Output
    wire [7:0] o_Result;
    
    adder #(8) uut(
        .i_A(i_A),
        .i_B(i_B),
        .o_Result(o_Result)
    );
    
    initial begin
        i_A = 0;
        i_B = 0;
        
        if (o_Result != 8'b00000000) begin
            $display("Error en el caso de prueba 1: %b + %b != %b", i_A, i_B, o_Result);
            $finish;
        end

        
        #10;
        
        i_A = 8'b00000010;
        i_B = 8'b00000011;
        
        #1;
        if (o_Result != 8'b00000101) begin
            $display("Error en el caso de prueba 2: %b + %b != %b", i_A, i_B, o_Result);
            $finish;
        end        

        #10;
        
        i_A = 8'b11111111;
        i_B = 8'b11111111;
        
        #1;
        if (o_Result != 8'b11111110) begin
            // Hay un overflow que no vamos a poder ver porque no es el objetivo del módulo
            $display("Error en el caso de prueba 3: %b + %b != %b", i_A, i_B, o_Result);
            $finish;
       end 

       #10;        
       $finish;
    end
endmodule
