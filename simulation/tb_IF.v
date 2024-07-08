`timescale 1ns / 1ps

module tb_IF();

    localparam      NB           =   32; 

    reg                            i_clk;
    reg                            i_step;
    reg                            i_reset;
    reg                            i_pc_write;
    wire        [NB-1:0]           o_IF_pc;
    wire        [NB-1:0]           o_IF_pc4;
    wire        [NB-1:0]           o_IF_pc8;
    wire        [NB-1:0]           o_instruction;

    IF #(.NB(NB)) u_IF(
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_step         (i_step),
        .i_pc_write     (i_pc_write),
        .o_IF_pc        (o_IF_pc),
        .o_IF_pc4       (o_IF_pc4),
        .o_IF_pc8       (o_IF_pc8),
        .o_instruction  (o_instruction) 
    );

    always #10 i_clk = ~i_clk;
        
    initial begin
        i_reset     =   1'b0;
        i_clk       =   1'b0;
        i_step      =   1'b1;
        i_pc_write  =   1'b1;
    end
    
    initial begin
    
        // Reset
        i_reset = 1;
        #20
        i_reset = 0;
        
        #10
        if (o_IF_pc != 32'h0) begin
            $display("Error en el PC deberias ser 0x0");
        end
        
        #10
        if (o_IF_pc != 32'h4) begin
            $display("Error en el PC deberias ser 0x4");
        end
        
        #10
        if (o_IF_pc != 32'h8) begin
            $display("Error en el PC deberias ser 0x8");
        end
        
        #5
        if (o_IF_pc != 32'h8) begin
            $display("Debería seguir valiendo 8 porque no hubo un nuevo flanco");
            $finish;
        end
        
        $display("Todos los tests exitosos");
        $finish;
      
    end
  
endmodule
