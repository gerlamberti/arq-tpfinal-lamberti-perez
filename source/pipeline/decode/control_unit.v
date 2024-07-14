`timescale 1ns/1ps

module control_unit #(
        parameter NB = 6
    )(
        input   wire    [NB-1:0]        i_Instruction,
        input   wire    [NB-1:0]        i_Special,
        output  reg                     o_ALUSrc,
        output  reg    [1   :   0]      o_ExtensionMode
    );

    localparam ADDI   = 6'b001000;
    localparam ANDI   = 6'b001100;

    always @(*) begin
        case(i_Instruction)
            ADDI:
            begin
                o_ALUSrc          <=  1'b1    ;
                o_ExtensionMode   <=  2'b00   ;
            end

            ANDI:
            begin
                o_ALUSrc          <=  1'b1    ;
                o_ExtensionMode   <=  2'b01   ;
            end
            default:
            begin    
                o_ALUSrc          <=  1'b0    ;
                o_ExtensionMode   <=  2'b00   ;
            end
        endcase
    end
endmodule