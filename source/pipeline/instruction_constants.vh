
// Opcodes
`define RTYPE_OPCODE 6'h00
`define BEQ_OPCODE   6'h04
`define BNE_OPCODE   6'h05 
`define ADDI_OPCODE  6'h08 
`define SLTI_OPCODE  6'h0a 
`define ANDI_OPCODE  6'h0c 
`define ORI_OPCODE   6'h0d 
`define XORI_OPCODE  6'h0e 
`define LUI_OPCODE   6'h0f 
`define LB_OPCODE    6'h20 
`define LH_OPCODE    6'h21 
`define LHU_OPCODE   6'h22 
`define LW_OPCODE    6'h23 
`define LWU_OPCODE   6'h24 
`define LBU_OPCODE   6'h25 
`define SB_OPCODE    6'h28 
`define SH_OPCODE    6'h29 
`define SW_OPCODE    6'h2b 
`define J_OPCODE     6'h02 
`define JAL_OPCODE   6'h03 
`define JALR_FUNCT   6'h09
`define JR_FUNCT     6'h08

`define HALT_INSTRUCTION  32'hffffffff


// Function codes for R-type instructions
`define ADD_FCODE 6'b100000
`define ADDU_FCODE 6'b100001
`define AND_FCODE 6'b100100
`define JALR_FCODE 6'b001001
`define NOR_FCODE 6'b100111
`define OR_FCODE 6'b100101
`define SLL_FCODE 6'b000000
`define SLLV_FCODE 6'b000100
`define SLT_FCODE 6'b101010
`define SRA_FCODE 6'b000011
`define SRAV_FCODE 6'b000111
`define SRL_FCODE 6'b000010
`define SRLV_FCODE 6'b000110
`define SUB_FCODE 6'b100010
`define SUBU_FCODE 6'b100011
`define XOR_FCODE 6'b100110

`define HALT_INSTRUCTION 32'hffffffff