`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2024 17:39:21
// Design Name: 
// Module Name: test_program_counter
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


module test_program_counter;

    // Parameters
    parameter WIDTH = 32;
    // Inputs
    reg [WIDTH-1:0] i_next_pc;
    reg i_clock;
    // Outputs
    wire [WIDTH-1:0] o_pc;

    // Unit under test
    program_counter #(.WIDTH(WIDTH)) uut(
        .i_next_pc(i_next_pc),
        .i_clock(i_clock),
        .o_pc(o_pc)
    );
    
    initial begin
        i_clock = 1'b0;
        i_next_pc = 32'd0;
    end
    always #10 i_clock = ~i_clock;
    
    initial begin
        if (o_pc != 0) begin
            $display("Valor esperado: 0 - valor obtenido: %b", o_pc);
            $finish;
        end
        
        #10;
        i_next_pc = 32'd1;
        #10;
        if (o_pc != 1) begin
            $display("Valor esperado: 1 - valor obtenido: %b", o_pc);
            $finish;
        end
        
        #10;
        #10;
        if (o_pc != 1) begin
            $display("Valor esperado: 1 - valor obtenido: %b", o_pc);
            $finish;
        end
       
        i_next_pc = 324;
        #20;
        if (o_pc != 324) begin
            $display("Valor esperado: 324 - valor obtenido: %b", o_pc);
            $finish;
        end
        
        
        $display("Tests ok");
        $finish;
    end


endmodule
