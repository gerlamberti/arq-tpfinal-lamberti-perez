`timescale 1ns/1ps

module control_unit #(
        parameter NB = 6
    )(
        input   wire    [NBITS-1:0]   i_Instruction,
        input   wire    [NBITS-1:0]   i_Special,
        output  wire    [1   :   0]   o_ALUop,
        output  wire                  o_ALUSrc,
        output  wire    [1   :   0]   o_ExtensionMode
    );

    localparam ADDI   = 6'b001000;
    localparam ANDI   = 6'b001100;

    reg     [1:0]   ALUOp_Reg;
    reg             ALUSrc_Reg;

    always @(*) begin
        case(i_Instruction)
            ADDI:
            begin
                ALUOp_Reg           <=  2'b00   ;
                ALUSrc_Reg          <=  1'b1    ;
                ExtensionMode_Reg   <=  2'b00   ;
            end

            ANDI:
            begin
                ALUOp_Reg           <=  2'b11   ;
                ALUSrc_Reg          <=  1'b1    ;
                ExtensionMode_Reg   <=  2'b01   ;
            end
        endcase
    end

    assign  o_ALUSrc        =   ALUSrc_Reg;
    assign  o_ALUOp         =   ALUOp_Reg;
    assign  o_ExtensionMode =   ExtensionMode_Reg;

endmodule