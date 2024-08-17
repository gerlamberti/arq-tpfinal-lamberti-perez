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



memory[0] =  32'b0000000000000;  // nop              | 0x00000000
memory[1] =  32'b00000000000000000000000000000000;  // addi $5,$0,32    | 0x20050020
memory[2] =  32'b00100000000001110000000000100100;  // j 7              | 0x08000007
memory[3] =  32'b00100000000000010000000000000100;  // nop              | 0x00000000
memory[4] =  32'b00100000001000100000000000000100;  // addi $6,$0,2     | 0x20060002
memory[5] =  32'b00000000111000001111100000001001;  // addi $7,$0,17    | 0x20070011
memory[6] =  32'b00000000000000000000000000000000;  // addi $8,$0,18    | 0x20080012
memory[7] =  32'b00100000000001100000000000000010;  // addi $9,$0,29    | 0x2009001D
memory[8] =  32'b00100000000001110000000000010001;  // addi $10,$0,100  | 0x200A0064
memory[9] =  32'b00100000000010000000000000010010;  // addi $11,$0,211  | 0x200B00D3
memory[10] = 32'b00100000000010010000000000011101;  // halt            | 0xFFFFFFFF
memory[11] = 32'b00100000000010100000000001100100;  // sw $1,20($0)   | 0xAC010014
memory[12] = 32'b00100000000010110000000011010011;  // addi $1,$0,23  | 0x20010017
memory[13] = 32'b11111111111111111111111111111111;  // sw $1,24($0)   | 0xAC010018
memory[14] = 32'b00100000000000010000000010100101;  // addi $1,$0,165 | 0x200100A5
memory[15] = 32'b10101100000000010000000000011100;  // sw $1,28($0)   | 0xAC01001C
memory[16] = 32'b00100000000010100000000000000000;  // addi $10,$0,0  | 0x200A0000
memory[17] = 32'b00100000000010110000000000000100;  // addi $11,$0,4  | 0x200B0004
memory[18] = 32'b00100000000011000000000000100000;  // addi $12,$0,32 | 0x200C0020
memory[19] = 32'b10001101011000010000000000000000;  // lw $1,0($11)    #76 | 0x8D610000 
memory[20] = 32'b00000001010000010001000000101010;  // slt $2,$10,$1   #80 | 0x0141102A 
memory[21] = 32'b00010000010000000000000000000010;  // beq $2,$0,2     #84 | 0x10400002 
memory[22] = 32'b00000000000000000000000000000000;  // nop             #88 | 0x00000000 
memory[23] = 32'b00000000001000000101000000100000;  // add $10,$1,$0   #92 | 0x00205020 
memory[24] = 32'b00100001011010110000000000000100;  // addi $11,$11,4  #96 | 0x216B0004 
memory[25] = 32'b00000001011011000001000000101010;  // slt $2,$11,$12  #100 | 0x016c102a 
memory[26] = 32'b00010100010000001111111111111000;  // bne $2,$0,65528 #104 | 0x1480FFF8 
memory[27] = 32'b00000000000000000000000000000000;  // nop             #108 | 0x00000000 
memory[28] = 32'b11111111111111111111111111111111;  // halt            #112 | 0xFFFFFFFF 
memory[29] = 32'b11111111111111111111111111111111;  //                 #116 | 0xFFFFFFFF 
































// Instrucciones para sobreescribir el pipeline ADDI, ANDI, ORI, XORI, LUI

// memory[0] = 32'h00000000;
//memory[1] = {`ADDI_OPCODE, 5'd1, 5'd7, 16'd3};  // $7 <- $1 + 3             = 4 = 0100
//memory[2] = 32'h00000003;
//memory[3] = {`ANDI_OPCODE, 5'd6, 5'd8, 16'd15}; // $8 <- $6 & 15            = 6 = 0110
//memory[4] = 32'h00000004;
//memory[5] = {`ORI_OPCODE,  5'd6, 5'd9, 16'd15}; // $9 <- $6 | 15             = 15 = 1111
//memory[6] = 32'h00000006;
//memory[7] = {`XORI_OPCODE, 5'd3, 5'd10, 16'd1}; // $10 <- $3 ^ 1            = 2  = 0010
//memory[8] = 32'h00000008;
//memory[9] = {`LUI_OPCODE,  5'd0, 5'd11, 16'd61440};  // $11 <- 61440 << 16            = 4026531840  
//memory[10] = 32'h0000000A;
//memory[11] = {`SLTI_OPCODE,  5'd5, 5'd12, 16'd7967}; // $12 <- ( $5 < 7967)? 1:0
//memory[12] = 32'h0000000C;
//memory[13] = 32'h0000000D;
//memory[14] = 32'h0000000F;

// Instrucciones para sobreescribir el pipeline LH, LB, LWU, LBU, LHU y SB, SH

//memory[0] = 32'h00000000;
//memory[1] = {`LB_OPCODE, 5'd1, 5'd7, 16'd7};  // $7 <- Memory[base:$1 + offset:7]
//memory[2] = 32'h00000003;
//memory[3] = {`LBU_OPCODE, 5'd2, 5'd8, 16'd3}; // $8 <- Memory[base:$2 + offset:3]
//memory[4] = 32'h00000004;
//memory[5] = {`LH_OPCODE,  5'd3, 5'd9, 16'd3}; // $9 <- Memory[base:$3 + offset:3]
//memory[6] = 32'h00000006;
//memory[7] = {`LHU_OPCODE, 5'd4, 5'd10, 16'd3}; // $10 <- Memory[base:$4 + offset:3]
//memory[8] = 32'h00000008;
//memory[9] = {`LWU_OPCODE,  5'd5, 5'd11, 16'd3};  // $11 <- Memory[base:$5 + offset:3]
//memory[10] = 32'h0000000A;
//memory[11] = {`LW_OPCODE,  5'd6, 5'd12, 16'd3}; // $12 <- Memory[base:$6 + offset:3]
//memory[12] = 32'h0000000C;
//memory[13] = {`SB_OPCODE,  5'd2, 5'd7, 16'd3}; // Memory[base:$2 + offset:3] <- $7
//memory[14] = {`SH_OPCODE,  5'd5, 5'd8, 16'd3}; // Memory[base:$5 + offset:3] <- $8

// Instrucciones para sobreescribir el pipeline JAL, JR y JALR
// HAY QUE TENER CUIDADO PORQUE CUANDO TENGO JAL or JUMP en el MEM y DESCARTA EL DECODE y EXECUTE... REVISAR UNIT STALL ...

// memory[0] = 32'h00000000;
// //memory[1] = {`JAL_OPCODE, 26'd4};;  // JAL 4, deberia saltar a instruccion 4
// //memory[1] = {`RTYPE_OPCODE, 5'd4, 15'd0, `JR_FUNCT};  // JR $4, deberia saltar a instruccion 4 por el registro 4
// memory[1] = {`RTYPE_OPCODE, 5'd4, 15'd0, `JALR_FUNCT};  // JALR $4, $2 deberia saltar a instruccion 4 por el registro 4
// memory[2] = 32'h00000000;
// memory[3] = 32'h00000000;
// memory[4] = 32'h00000000;
// memory[5] = {`ADDI_OPCODE, 5'd7, 5'd2, 16'd4}; // tuve que moverlo de la posicion memory[4] al memory[5] porque el flush me descartaba la operacion
// memory[6] = 32'h00000000;
// memory[7] = 32'h00000000; 
// memory[8] = 32'h00000000;
// memory[9] = 32'h00000000;
// memory[10] = 32'h00000000;
// memory[11] = 32'h00000000;
// memory[12] = 32'h00000000;
// memory[13] = 32'h00000000;
// memory[14] = 32'h00000000;

