// Instrucciones para sobreescribir el pipeline
memory[0] = 32'h00000000;
memory[1] = {`ADDI_OPCODE, 5'd7, 5'd2, 16'hFBF2};  // $2 <- $7 + FBF2
memory[2] = {`RTYPE_OPCODE, 5'd5, 5'd3, 5'd4, 5'b0, `ADD_FCODE};  // $4 <- $5 + $3
memory[3] = {`SW_OPCODE, 5'd1, 5'd12, 16'h8};  // SW $2, 15($1)
memory[4] = 32'h00000000;  // TODO meter un LW
memory[5] = {`BEQ_OPCODE, 5'd4, 5'd8, -16'sd2};  // BEQ $4, $8, 1
memory[6] = 32'h00000006;  // TODO meter un J
memory[7] = 32'h00000007;  // TODO meter un par de ADDs para rellenar
memory[8] = 32'h00000008;
memory[9] = 32'h00000009;
memory[10] = 32'h0000000A;
memory[11] = 32'h0000000B;
memory[12] = 32'h0000000C;
memory[13] = 32'h0000000D;
memory[14] = 32'h0000000F;
