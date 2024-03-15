`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2024 17:35:11
// Design Name: 
// Module Name: test_ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_ALU();

    //LOCAL PARAMETERS
    localparam BUS_SIZE = 32;

    //TB_SIGNALS
    reg	clk;
    reg signed [BUS_SIZE-1:0] dataA;
    reg signed [BUS_SIZE-1:0] dataB;
    reg [5:0] op;
    wire signed [BUS_SIZE-1:0] res;

    reg test_start;

    //INICIALIZACION
    initial begin
        clk = 1'b0;
        dataA = {BUS_SIZE{1'b0}};
        dataB = {BUS_SIZE{1'b0}};
        test_start = 1'b0;

        //#10
        op = 6'b100000; // SUMA A + B
        test_start = 1'b1;
        #100
        op = 6'b100010; //RESTA = A - B;
        #100
        op = 6'b100100; //  AND = A & B;
        #100
        op = 6'b100101; //  OR = A | B;
        #100
        op = 6'b100110; //  XOR = A ^ B;
        #100
        op = 6'b000011; // SRA  = A>>B;
        #100
        op = 6'b000010; //  SRL = A>>>B;
        #100
        op = 6'b100111; // NOR ~(A | B);

        #20
        $display("####TEST OK####");
        $finish;
    end


    // CLOCK_GENERATION
    always #10 clk = ~clk;

    //Random Data
    always @(posedge clk) begin
        dataA <= $urandom();
        dataB <= $urandom();
    end

    // MODULE INSTANCE
    ALU
    #(
    .BUS_SIZE(BUS_SIZE)
    )
    dut
    (
        .i_A(dataA),
        .i_B(dataB),
        .i_Op(op),
        .o_salida(res)
    );
    always @(posedge clk) begin
    if(test_start) begin
        case(op)
        6'b100000:
            if(res != (dataA + dataB)) 
            begin
                $error("Error en la Suma!");
                $display("############# Test FALLO ############");
                $finish();
            end
        // SUB
        6'b100010:
            if(res != (dataA - dataB))
            begin
                $error("Error en la Resta!");
                $display("############# Test FALLO ############");
                $finish();
            end
        // AND
        6'b100100:
            if(res != (dataA & dataB))
            begin
                $error("Error en la AND!");
                $display("############# Test FALLO ############");
                $finish();
            end
        // OR
        6'b100101:
            if(res != (dataA | dataB))
            begin
                $error("Error en la OR!");
                $display("############# Test FALLO ############");
                $finish();
            end
        // XOR
        6'b100110:
            if(res != (dataA ^ dataB))
            begin
                $error("Error en la XOR!");
                $display("############# Test FALLO ############");
                $finish();
            end
        // SRL
        6'b000011:
            if(res != (dataA >> dataB))
            begin
                $error("Error en la SRL!");
                $display("############# Test FALLO ############");
                $finish();
            end
        // SRA
        6'b000010:
            if(res != (dataA >>> dataB))
            begin
                $error("Error en la SRA!");
                $display("############# Test FALLO ############");
                $finish();
            end
        // NOR
        6'b100111:
            if(res != ~(dataA | dataB))
            begin
                $error("Error en la NOR!");
                $display("############# Test FALLO ############");
                $finish();
            end
        //DEFAULT
        default:
        begin
            $error("Error en la OPERACION!");
            $display("############# Test FALLO ############");
            $finish();
        end
        endcase
    end
    end

endmodule
