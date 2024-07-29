`timescale 1ns / 1ps

module tb_IF();

    localparam      NB           =   32; 

    reg                            i_clk;
    reg                            i_step;
    reg                            i_reset;
    reg                            i_pc_write;
    reg                            i_branch;
    reg         [NB-1:0]           i_branch_addr;
    wire        [NB-1:0]           o_IF_pc;
    wire        [NB-1:0]           o_IF_pc4;
    wire        [NB-1:0]           o_IF_pc8;
    wire        [NB-1:0]           o_instruction;

    IF #(.NB(NB)) u_IF(
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_step         (i_step),
        .i_pc_write     (i_pc_write),
        .i_branch       (i_branch),
        .i_branch_addr  (i_branch_addr),
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
        i_branch = 0;
        i_branch_addr = 0;
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
        
        #10;
        i_branch = 1;
        i_branch_addr = 32'hAF;
        
        #10
        if (o_IF_pc != 32'hAF) begin
            $finish;
        end
        
        $display("Todos los tests exitosos");
        $finish;
      
    end
  
endmodule
