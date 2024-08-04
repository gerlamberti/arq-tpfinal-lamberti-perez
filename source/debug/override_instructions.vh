// Instrucciones para sobreescribir el pipeline
// `define TEST_J_6TH_INSTRUCTION // Perdon por esta cochinada, no encontre una manera de hacer mejor esto

// memory[0] = 32'h00000000;
// memory[1] = {`ADDI_OPCODE, 5'd7, 5'd2, 16'hFBF2};  // $2 <- $7 + FBF2
// memory[2] = {`RTYPE_OPCODE, 5'd5, 5'd3, 5'd4, 5'b0, `ADD_FCODE};  // $4 <- $5 + $3
// memory[3] = {`SW_OPCODE, 5'd1, 5'd12, 16'h8};  // SW $2, 15($1)
// memory[4] = {`LW_OPCODE, 5'd8, 5'd1, 16'h9};  // LW $1, 9($8)
// `ifdef TEST_J_6TH_INSTRUCTION
// memory[5] = 0;  // Para el test del Jump me jode el BEQ entonces lo dejo en nop.
// `else
// memory[5] = {`BNE_OPCODE, 5'd4, 5'd1, -16'sd2};  // BEQ $4, $8, -2
// // memory[5] = {`BEQ_OPCODE, 5'd4, 5'd8, -16'sd2};  // BEQ $4, $8, -2
// `endif
// memory[6] = {`J_OPCODE, 26'd2};  // J 2, deberia saltar a instruccion 2
// memory[7] = 32'h00000007;  // TODO meter un par de ADDs para rellenar
// memory[8] = 32'h00000008;
// memory[9] = 32'h00000009;
// memory[10] = 32'h0000000A;
// memory[11] = 32'h0000000B;
// memory[12] = 32'h0000000C;
// memory[13] = 32'h0000000D;
// memory[14] = 32'h0000000F;

// Instrucciones para sobreescribir el pipeline SLL, SRL, SRA

// memory[0] = 32'h00000000;
// memory[1] = {`RTYPE_OPCODE, 5'd0, 5'd7, 5'd3, 5'd2, `SLL_FCODE};  // $3 <- $7 << $2
// memory[2] = 32'h00000003;
// memory[3] = {`RTYPE_OPCODE, 5'd0, 5'd7, 5'd3, 5'd2, `SRL_FCODE}; // $3 <- $7 >> $2
// memory[4] = 32'h00000004;
// memory[5] = {`RTYPE_OPCODE, 5'd0, 5'd7, 5'd3, 5'd2, `SRA_FCODE}; // $3 <- $7 >>> $2
// memory[6] = 32'h00000006;
// memory[7] = 32'h00000007; 
// memory[8] = 32'h00000008;
// memory[9] = 32'h00000009;
// memory[10] = 32'h0000000A;
// memory[11] = 32'h0000000B;
// memory[12] = 32'h0000000C;
// memory[13] = 32'h0000000D;
// memory[14] = 32'h0000000F;


// Instrucciones para sobreescribir el pipeline SLLV, SRLV, SRAV

// memory[0] = 32'h00000000;
// memory[1] = {`RTYPE_OPCODE, 5'd1, 5'd7, 5'd3, 5'd0, `SLLV_FCODE};  // $3 <- $7 << $1
// memory[2] = 32'h00000003;
// memory[3] = {`RTYPE_OPCODE, 5'd2, 5'd7, 5'd3, 5'd0, `SRLV_FCODE}; // $3 <- $7 >> $2
// memory[4] = 32'h00000004;
// memory[5] = {`RTYPE_OPCODE, 5'd1, 5'd15, 5'd3, 5'd0, `SRAV_FCODE}; // $3 <- $15 >>> $1
// memory[6] = 32'h00000006;
// memory[7] = 32'h00000007; 
// memory[8] = 32'h00000008;
// memory[9] = 32'h00000009;
// memory[10] = 32'h0000000A;
// memory[11] = 32'h0000000B;
// memory[12] = 32'h0000000C;
// memory[13] = 32'h0000000D;
// memory[14] = 32'h0000000F;

// Instrucciones para sobreescribir el pipeline ADDI, ANDI, ORI, XORI, LUI

memory[0] = 32'h00000000;
memory[1] = {`ADDI_OPCODE, 5'd1, 5'd7, 16'd3};  // $7 <- $1 + 3             = 4 = 0100
memory[2] = 32'h00000003;
memory[3] = {`ANDI_OPCODE, 5'd6, 5'd8, 16'd15}; // $8 <- $6 & 15            = 6 = 0110
memory[4] = 32'h00000004;
memory[5] = {`ORI_OPCODE, 5'd6, 5'd9, 16'd15}; // $9 <- $6 | 15             = 15 = 1111
memory[6] = 32'h00000006;
memory[7] = {`XORI_OPCODE, 5'd3, 5'd10, 16'd1}; // $10 <- $3 ^ 1            = 2  = 0010
memory[8] = 32'h00000008;
memory[9] = 32'h00000009;
memory[10] = 32'h0000000A;
memory[11] = 32'h0000000B;
memory[12] = 32'h0000000C;
memory[13] = 32'h0000000D;
memory[14] = 32'h0000000F;
