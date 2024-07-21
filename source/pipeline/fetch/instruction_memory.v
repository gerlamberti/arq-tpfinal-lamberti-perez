`timescale 1ns / 1ps
`include   "instruction_constants.vh"

module instruction_memory
    #(
        parameter NB     = 32,
        parameter TAM    = 256
    )
    (
        input   wire                        i_clk,
        input   wire                        i_reset,
        input   wire                        i_step,
        input   wire    [NB-1:0]            i_pc,
        output  reg     [NB-1:0]            o_instruction   
    );
    
    reg     [NB-1:0]     memory[TAM-1:0];
    integer              i;

    initial begin
        for (i = 0; i < TAM; i = i + 1) begin
            memory[i] = 0;
        end
    end
    
    always @(*) begin
        case (i_pc[31:2])
            0: o_instruction = 32'h00000000;
            1: o_instruction = {`ADDI_OPCODE, 5'd1, 5'd2, 16'hFFF2}; // add $0, $1, $3
            2: o_instruction = {`RTYPE_OPCODE, 5'd5, 5'd3, 5'd4, 5'b0, `ADD_FCODE};
            3: o_instruction = 32'h00000003;
            4: o_instruction = 32'h00000004;
            5: o_instruction = 32'h00000005;
            6: o_instruction = 32'h00000006;
            7: o_instruction = 32'h00000007;
            8: o_instruction = 32'h00000008;
            9: o_instruction = 32'h00000009;
            10: o_instruction = 32'h0000000A;
            11: o_instruction = 32'h0000000B;
            12: o_instruction = 32'h0000000C;
            13: o_instruction = 32'h0000000D;
            14: o_instruction = 32'h0000000F;
            default: o_instruction = 32'h00000000; // default case
        endcase
    end
    

    // Leer el valor de la tabla de búsqueda en función de la dirección
//    always @(*) begin
//        o_instruction = memory[i_pc[31:2]];
//    end

endmodule
