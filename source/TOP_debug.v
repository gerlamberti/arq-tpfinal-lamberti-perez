`timescale 1ns / 1ps
module TOP_debug
#( 
    parameter ancho_dato = 8,
    parameter BAUD_RATE = 9600, //velocidad tipica 
    parameter FREC_CLOCK_MHZ = 100
)
(
    /*-----Entradas al modulo-----*/
    input wire clk,
    input wire reset,
    input wire Entrada_RX,
    
    /*-----Salidas al modulo-----*/	
    output wire Salida_TX,
    output wire [ancho_dato-1:0] o_leds
);

wire senial_tick;
wire tick_completos_receptor;
wire tick_completos_transmisor;
wire comienzo_transmicion;
wire [ancho_dato-1:0] salida_receptor;//?????????????????????????????????????????
wire [ancho_dato-1:0] entrada_transmisor;//?????????????????????????????????????????
/*-----------------------------------------------------------------------------------*/
// instanciando el generador de baudio 
GeneradorDeBaudios #
(
	.BAUD_RATE(BAUD_RATE),  
	.FREC_CLOCK_MHZ(FREC_CLOCK_MHZ)
) 
generador_ticks
(
	.clk(clk),
	.reset(reset),
	.senial_tick(senial_tick)
);


/*-----------------------------------------------------------------------------------*/
//INSTANCIANDO EL RECEPTOR
Receptor #
(
	.ancho_dato(ancho_dato)  
)
receptor_1
(
    //------------------entradas------------------//
	.clk(clk),
	.reset(reset),
	.RX(Entrada_RX),//linea de recepcion
	.senial_generadorTick(senial_tick),//entrada que proviene del generador de baudios
	
	//------------------Salidas------------------//
	.senial_ticks_completos(tick_completos_receptor),
	.salida_receptor(salida_receptor)//salida de datos hacia la interfaz
);
reg [7:0] data;
reg tx_start;
reg [7:0] tx_data;
integer contador;
always @(posedge clk) begin
    if (tick_completos_receptor) begin
        data <= salida_receptor;
        tx_start <= 1'b1;
        tx_data <= salida_receptor;
    end
    else begin
        tx_start <= 1'b0;
        tx_data <= 8'b0;
    end
    if (data) contador <= contador + 1;
end


assign o_leds = data;
assign comienzo_transmicion = tx_start;
assign entrada_transmisor = tx_data;

/*-----------------------------------------------------------------------------------*/
//INSTANCIANDO LA INTERFAZ
/* debug # 
( 
    .NB(32),     
    .DATA_BITS(8)    
)(
     //------------------entradas------------------//
     .i_clk(clk),
	 .i_reset(reset),
	 .i_uart_rx_ready(tick_completos_receptor), // EN .salida_receptor     DE LA INSTANCIACION DEL RECEPTOR HAY QUE PONER EL MUSMO PARAMETRO.    
	 .i_uart_rx_data(salida_receptor),//salida del receptor OKEY
	 .i_uart_tx_done(tick_completos_transmisor),//EL FIN DE TRANSMISION SE DA CUANDO LOS TICKS ESTAN COMPLETOS POR LO TANTO SE PONE EL MISMO PARAMETRO EN                                                             
     .i_mips_pc(32'd65443),
    //------------------salidas------------------//
    .o_uart_tx_ready(comienzo_transmicion), //El comieno de la trasmision es cuando la interfaz alu este vacia      ESTE ES UNICO QUE TENGO DUDA DINOSAURIO
    .o_uart_tx_data(entrada_transmisor),  //señal que va a salir de la interfaz hacia el modulo que le sigue
    .o_state_debug()
);*/


/*-----------------------------------------------------------------------------------*/
//INSTANCIANDO EL TRANSMISOR
Transmisor
#( 
	.ancho_dato(ancho_dato)	
)
transmisor_1
( 
    //------------------entradas------------------//
    .clk(clk), 
	.reset(reset),  
	.comienzo_TX(comienzo_transmicion),
	.senial_generadorTick(senial_tick),  
	.entrada_transmisor(entrada_transmisor),
	
	//------------------salidas------------------// 
	.senial_ticks_completos(tick_completos_transmisor), //rd_a_tx_done_tick ANTES ESTABA ESTA VARIABLE ELLOS USABAN 2  REG DIFERENTES PARA EL DONE
	.TX(Salida_TX)
); 


endmodule