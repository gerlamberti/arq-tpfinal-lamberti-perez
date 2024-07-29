// Instrucciones para sobreescribir el pipeline
`define TEST_J_6TH_INSTRUCTION // Perdon por esta cochinada, no encontre una manera de hacer mejor esto

memory[0] = 32'h00000000;
memory[1] = {`ADDI_OPCODE, 5'd7, 5'd2, 16'hFBF2};  // $2 <- $7 + FBF2
memory[2] = {`RTYPE_OPCODE, 5'd5, 5'd3, 5'd4, 5'b0, `ADD_FCODE};  // $4 <- $5 + $3
memory[3] = {`SW_OPCODE, 5'd1, 5'd12, 16'h8};  // SW $2, 15($1)
memory[4] = 32'h00000000;  // TODO meter un LW
`ifdef TEST_J_6TH_INSTRUCTION
memory[5] = 0;  // Para el test del Jump me jode el BEQ entonces lo dejo en nop.
`else
memory[5] = {`BEQ_OPCODE, 5'd4, 5'd8, -16'sd2};  // BEQ $4, $8, -2
`endif
memory[6] = {`J_OPCODE, 26'd2};  // J 2, deberia saltar a instruccion 2
memory[7] = 32'h00000007;  // TODO meter un par de ADDs para rellenar
memory[8] = 32'h00000008;
memory[9] = 32'h00000009;
memory[10] = 32'h0000000A;
memory[11] = 32'h0000000B;
memory[12] = 32'h0000000C;
memory[13] = 32'h0000000D;
memory[14] = 32'h0000000F;
