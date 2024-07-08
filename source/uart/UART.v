`timescale 1ns / 1ps
module moduloUART
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


assign o_leds = entrada_transmisor;
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


/*-----------------------------------------------------------------------------------*/
//INSTANCIANDO LA INTERFAZ
Interfaz # 
( 
    .ancho_dato(ancho_dato),     
    .ancho_dato_alu(ancho_dato)    
)
interfaz_1
(
     //------------------entradas------------------//
     .clk(clk) ,
	 .reset(reset) ,
	 .senial_lecturaReceptor(tick_completos_receptor), // EN .salida_receptor     DE LA INSTANCIACION DEL RECEPTOR HAY QUE PONER EL MUSMO PARAMETRO.    
	 .senial_finTransmicion(tick_completos_transmisor),//EL FIN DE TRANSMISION SE DA CUANDO LOS TICKS ESTAN COMPLETOS POR LO TANTO SE PONE EL MISMO PARAMETRO EN                                                             
     .datoEntrada_receptor(salida_receptor),//salida del receptor OKEY
    //------------------salidas------------------//
    .comienzo_transmicion(comienzo_transmicion), //El comieno de la trasmision es cuando la interfaz alu este vacia      ESTE ES UNICO QUE TENGO DUDA DINOSAURIO
    .datoSalida_transmisor(entrada_transmisor)  //señal que va a salir de la interfaz hacia el modulo que le sigue
);


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