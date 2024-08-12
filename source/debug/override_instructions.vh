// Instrucciones para sobreescribir el pipeline
// `define TEST_J_6TH_INSTRUCTION // Perdon por esta cochinada, no encontre una manera de hacer mejor esto

// memory[0] = 32'h00000000;
// memory[1] = {`ADDI_OPCODE, 5'd7, 5'd2, 16'h2};  // $2 <- $7 + FBF2
// memory[2] = 0;//{`RTYPE_OPCODE, 5'd5, 5'd3, 5'd4, 5'b0, `ADD_FCODE};  // $4 <- $7 + $3
// memory[3] = 0;//{`SW_OPCODE, 5'd1, 5'd12, 16'h8};  // SW $2, 15($1)
// memory[4] = 0;//{`LW_OPCODE, 5'd8, 5'd1, 16'h9};  // LW $1, 9($8)
// // memory[5] = 0;  // Para el test del Jump me jode el BEQ entonces lo dejo en nop.
// // memory[5] = {`BNE_OPCODE, 5'd4, 5'd1, -16'sd2};  // BEQ $4, $8, -2
// memory[5] = {`BEQ_OPCODE, 5'd0, 5'd0, 16'd2};  // BEQ $4, $8, -2
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



// Este caso lo hago especificamente para el 5th instruction beq 
memory[0] = 0;
memory[1] = 32'b10001100000000100000000000000101; // lw $2,5($0)
memory[2] = 32'b00000000101000101010100000100000; // add $21,$5,$2
memory[3] = 32'b00010000010000010000000000000111; // beq $2,$1,7
memory[4] = 32'b00100000010101000000000000000100; // addi $20,$2,4
memory[5] = 32'b10101100000011100000000000101010; // sw $14,42($0)
memory[6] = 32'b00000000101010100110100000100000; // add $13,$5,$10
memory[7] = 32'b00100000000000010000000000000000; // addi $1,$0,0
memory[8] = 32'b00100000000000100000000000000000; // addi $2,$0,0
memory[9] = 32'b00100000000000110000000000000000; // addi $3,$0,0
memory[10] = 32'b00100000000001000000000000000000; // addi $4,$0,0
memory[11] = 32'b00100000000001010000000000000001; // addi $5,$0,1
memory[12] = 32'b00100000000001100000000000000010; // addi $6,$0,2
memory[13] = 32'b00100000000001110000000000000000; // addi $7,$0,0
memory[14] = 32'b00100000000010000000000000000000; // addi $8,$0,0
memory[15] = 32'b00100000000010010000000000000000; // addi $9,$0,0
memory[16] = 32'b11111111111111111111111111111111; // 
