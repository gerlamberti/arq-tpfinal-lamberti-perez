// Make an ALU
`timescale 1ns / 1ps
`include "execute_constants.vh"

module ALU #(
        parameter   NB      =   32,
        parameter   NB_OP   =   4      
    )
    (
        input   wire    [NB-1    :0]     i_data_a,
        input   wire    [NB-1    :0]     i_data_b,
        input   wire    [NB_OP-1    :0]  i_operation,
        output  wire                     o_cero,
        output  wire    [NB-1    :0]     o_result
    );
    


    reg [NB-1:0]     result;
      
    always @(*)
        begin : operations
            case(i_operation)
                `AND:
                result  =   i_data_a   &   i_data_b;
                `OR:
                result  =   i_data_a   |   i_data_b;
                `ADD:
                result  =   i_data_a   +   i_data_b;
                `SUB:
                result  =   i_data_a   -   i_data_b;
                `SLT:
                result  =   i_data_a   <   i_data_b ? 1:0;
                `NOR:
                result  =   ~(i_data_a |   i_data_b);
                `XOR:
                result  =   i_data_a   ^   i_data_b;
                `SLL:
                result  =   i_data_b << i_data_a;
                `SRL:
                result  =   i_data_b >> i_data_a;
                `SRA:
                result  =    $signed(i_data_b) >>> i_data_a;
                default:
                result  =   -1;
            endcase
        end

    assign o_result =   result;
    assign o_cero   =   (result==0);

endmodule
