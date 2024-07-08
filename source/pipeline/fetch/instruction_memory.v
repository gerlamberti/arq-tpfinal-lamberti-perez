`timescale 1ns / 1ps

module instruction_memory
    #(
        parameter NB     = 32,
        parameter TAM    = 256
    )
    (
        input   wire                        i_clk,
        input   wire                        i_reset,
        input   wire                        i_step,
//      input   wire                        i_instruction_write,
        input   wire    [NB-1:0]            i_pc,
//      input   wire    [NB-1:0]            i_instruction,
//      input   wire    [7 :  0]            i_address_memory_ins,
        output  reg     [NB-1:0]            o_instruction   
    );
    
    reg     [NB-1:0]     memory[TAM-1:0];
    integer              i;

    initial begin
        for (i = 0; i < TAM; i = i + 1) begin
            memory[i] = 0;
        end

        // Fijar codigo de instrucion que saca.
        memory[0]   =   32'h00000000;
        memory[1]   =   32'h00000000001000110000000000100000; //add $0,$1,$3
        memory[2]   =   32'h00000002;
        memory[3]   =   32'h00000003;
        memory[4]   =   32'h00000004;
        memory[5]   =   32'h00000005;
        memory[6]   =   32'h00000006;
        memory[7]   =   32'h00000007;
        memory[8]   =   32'h00000008;
        memory[9]   =   32'h00000009;
        memory[10]   =  32'h0000000A;
        memory[11]   =  32'h0000000B;
        memory[12]   =  32'h0000000C;
        memory[13]   =  32'h0000000D;
        memory[14]   =  32'h0000000F;
    end

    // Leer el valor de la tabla de búsqueda en función de la dirección
    always @(*) begin
        o_instruction = memory[i_pc[31:2]];
    end



    // Crea el Text Segment
    // initial begin
    //     for (i = 0; i < TAM; i = i + 1) begin
    //         memory[i] = 0;
    //     end  
    // end

    //Pone a la salida la instruccion del senialada por el PC
    // always @(posedge i_clk) begin
    //     if (i_step)begin
    //         o_instruction  <= memory[i_pc]; // Creo que agregando [31:2] hacemos que arranque en la posicion del array 0
    //     end
    // end

    // Crea el segmento de codigo que va arrecorrer el PC.
    // always @(posedge i_write_intruc) begin
    //     memory[i_address_memory_ins] <= i_instruction; // Desde la debug unit viene .i_address_memory_ins(count_dir_mem_instr) viene de 4 en 4.
    // end

endmodule
