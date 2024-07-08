`timescale 1ns / 1ps
module GeneradorDeBaudios#(
        //Parametros
        parameter BAUD_RATE    = 9600, //velocidad tipica 
        parameter FREC_CLOCK_MHZ  = 100
    )
    (
        input wire clk,     
        input wire reset, 
        output  reg senial_tick
    );
    
    localparam integer contador_modulo = (FREC_CLOCK_MHZ * 1000000) / (BAUD_RATE * 16);
    reg [ $clog2 (contador_modulo) - 1 : 0 ] contador; //contador va a tener los bits necesarios para contar hasta modulo contador

    always@( posedge clk) begin
        if (reset)
            begin
                contador <= 0;
                 senial_tick <= 0;
            end 
        else 
            begin
                if (contador < contador_modulo) 
                    begin
                        senial_tick <= 0;//no enviamos tick, hasta que no se haya llegado al valor del modulo contador
                        contador <= contador + 1; //incrementamod contador
                    end
                else 
                    begin
                        senial_tick <= 1;//enviamos un tick
                        contador <= 0;//reseteamos el contador
                end
        end
    end
endmodule
