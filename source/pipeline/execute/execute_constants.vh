// Definciones de constantes para la ALU
// Ver pag 316 patterson
`define AND 4'b0000
`define OR 4'b0001
`define ADD 4'b0010
`define SUB 4'b0110
`define XOR 4'b1101
`define SLT 4'b0111 // Set on less than (A is less than B)
`define SRA 4'b0101 // A>>>B
`define SRL 4'b0100 // A>>B (shamt)
`define NOR 4'b1100
`define SLL 4'b0011 // A<<B (shamt)
`define BNE 4'b1001