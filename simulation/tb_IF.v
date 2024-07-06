`timescale 1ns / 1ps

module tb_IF();

    localparam      NB           =   32; 

    reg                            i_clock;
    reg                            i_reset;
    reg                            i_step;
    reg                            i_pc_write;
    reg         [NB-1:0]           i_new_PC;
    wire        [NB-1:0]           o_pc;

    IF #(.NB(NB)) u_IF(
        .i_clk          (i_clock),
        .i_reset        (i_reset),
        .i_step         (i_step),
        .i_PC_write     (i_pc_write),
//        .i_new_pc(i_new_pc),
        .o_IF_pc        (o_pc)  
    );

    always #10 i_clock = ~i_clock;
    
    initial begin
        i_clock     =   1'b0;
        i_step      =   1'b1;
        i_reset     =   1'b0;
        i_pc_write  =   1'b1;  
    end
    
    initial begin
        #10
        if (o_pc != 32'h0) begin
            $display("Error en el PC deberias ser 0x0");
        end
        
        #10
        if (o_pc != 32'h4) begin
            $display("Error en el PC deberias ser 0x4");
        end
        
        #10
        if (o_pc != 32'h8) begin
            $display("Error en el PC deberias ser 0x8");
        end
        
        #5
        if (o_pc != 32'h8) begin
            $display("Debería seguir valiendo 8 porque no hubo un nuevo flanco");
            $finish;
        end
        
        $display("Todos los tests exitosos");
        $finish;
      
    end
  
endmodule
