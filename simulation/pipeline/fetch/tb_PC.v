`timescale 1ns / 1ps

module tb_PC();

    localparam      NB           =   32; 

    reg                            i_clock;
    reg                            i_reset;
    reg                            i_step;
    reg                            i_pc_write;
    reg         [NB-1:0]           i_new_PC;
    wire        [NB-1:0]           o_pc;

    PC #(.NB(NB)) u_PC(
        .i_clk          (i_clock),
        .i_reset        (i_reset),
        .i_step         (i_step),
        .i_pc_write     (i_pc_write),
        .i_new_pc       (o_pc),
        .o_pc           (o_pc)  
    );

    always #10 i_clock = ~i_clock;
    
    initial begin
        i_reset     =   1'b0;
        i_clock     =   1'b0;
        i_step      =   1'b1;
        i_pc_write  =   1'b1; 
        i_new_PC    =   32'b0; 
    end
           
    initial begin
    
        // Reset
        i_reset = 1;
        #20
        i_reset = 0;
        
        #10
        if (o_pc != 32'h4) begin
            $display("Error en el PC deberias ser 0x4");
            $finish;
        end
        
        #10
        if (o_pc != 32'h8) begin
            $display("Error en el PC deberias ser 0x8");
            $finish;
        end
        
        #10
        if (o_pc != 32'hC) begin
            $display("Error en el PC deberias ser 0xC");
            $finish;
        end
        
        #5
        if (o_pc != 32'hC) begin
            $display("Debería seguir valiendo 8 porque no hubo un nuevo flanco");
            $finish;
        end
        
        $display("Todos los tests exitosos");
        $finish;
      
    end
  
endmodule
