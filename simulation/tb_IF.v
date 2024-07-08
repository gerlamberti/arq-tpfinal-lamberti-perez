`timescale 1ns / 1ps

module tb_IF();

    localparam      NB           =   32; 

    reg                            i_clk;
    reg                            i_step;
    reg                            i_reset;
    reg                            i_pc_write;
    reg         [NB-1:0]           i_new_write;
    wire        [NB-1:0]           o_IF_pc;

    IF #(.NB(NB)) u_IF(
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_step         (i_step),
        .i_pc_write     (i_pc_write),
        .i_new_write    (i_new_write),
        .o_IF_pc        (o_IF_pc)  
    );

    always #10 i_clk = ~i_clk;
    
    always @(posedge i_clk) begin
        i_new_write <= o_IF_pc;
    end
    
    initial begin
        i_reset     =   1'b0;
        i_clk       =   1'b0;
        i_step      =   1'b1;
        i_pc_write  =   1'b1;
        i_new_write =   32'b0;  
    end
    
    initial begin
    
        // Reset
        i_reset = 1;
        #5
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
