// Instrucciones para sobreescribir el pipeline
memory[0] = 32'h00000000;
memory[1] = {`ADDI_OPCODE, 5'd7, 5'd2, 16'hFBF2};  // $2 <- $7 + FBF2
memory[2] = {`RTYPE_OPCODE, 5'd5, 5'd3, 5'd4, 5'b0, `ADD_FCODE}; // $s <- $5 + $3
memory[3] = 32'h00000003;
memory[4] = 32'h00000004;
memory[5] = 32'h00000005;
memory[6] = 32'h00000006;
memory[7] = 32'h00000007;
memory[8] = 32'h00000008;
memory[9] = 32'h00000009;
memory[10] = 32'h0000000A;
memory[11] = 32'h0000000B;
memory[12] = 32'h0000000C;
memory[13] = 32'h0000000D;
memory[14] = 32'h0000000F;
