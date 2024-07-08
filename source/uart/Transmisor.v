`timescale 1ns / 1ps
module Transmisor
#(
    parameter   ancho_dato = 8
)
(
    /*-----Entradas al modulo-----*/
    input wire clk,
    input wire reset,
    input wire comienzo_TX,
    input wire senial_generadorTick,
    input wire [(ancho_dato-1):0] entrada_transmisor,  
   
   /*-----Salidas al modulo-----*/	 
	output reg senial_ticks_completos, 
	output wire TX
);

    /*---------Estados---------*/
    //CODIFICACION ONE-COLD
    localparam WAIT=    4'b1110;// E     // estado WAIT , espera por el bit de start.
    localparam START=   4'b1101;//D      //START, bit que indica el comienzo de la comunicacion.
    localparam DATA=    4'b1011;// B     //DATA, indica el comiendo del envio de datos, hacia el receptor .
    localparam STOP=    4'b0111;//7      //STOP, indica la finalizacion de la comunicacion.
    
    reg [3:0] estado_actual;                                        //cuando inicializo el primer estado cargado es el idle
    reg [3:0] estado_siguiente;                                   //sigueinte estado va a ser start cuando llegue el 0 logico

    reg [3:0] contadorTicks_actual;                             //cuenta la cantidad de ticks recibidos para saber cuando leer el dato
    reg [3:0] contadorTicks_siguiente; 

    reg [2:0] contadorDatos_actual;                            //cuenta la cantidad de datos recibidos, debe contar hasta 8
    reg [2:0] contadorDatos_siguiente;

    reg [(ancho_dato-1):0] registroDatos_actual;        //datos a la salida 
    reg [(ancho_dato-1):0] registroDatos_siguiente;
    
    reg bit_transmitir_actual; 
    reg bit_transmitir_siguiente;
    
/*--------------------------------------Bloque secuencial--------------------------------------*/        
always @(posedge clk)
    begin   
	   if (reset)  
		  begin  
			 estado_actual <= WAIT;             //volvemos al estado wait
	 
			contadorTicks_actual <= 4'b0000;        //cantidad de ticks contado = 0
 
			contadorDatos_actual <= 3'b000;      //cantidad de datos contados
 
			registroDatos_actual <= 8'b00000000; 
  
			bit_transmitir_actual <= 1'b0;
		  end 
	else  
		begin  
			estado_actual <= estado_siguiente;
			contadorTicks_actual <= contadorTicks_siguiente;  
			contadorDatos_actual <= contadorDatos_siguiente;  
			registroDatos_actual <= registroDatos_siguiente;  
			bit_transmitir_actual <= bit_transmitir_siguiente;  
		end
end

assign TX = bit_transmitir_actual;


/*--------------------------------------Bloque puramente combinacional --------------------------------------*/     
always @(*)  
begin 
	estado_siguiente = estado_actual;  
	senial_ticks_completos 	= 1'b0;  
	contadorTicks_siguiente = contadorTicks_actual;  
    contadorDatos_siguiente = contadorDatos_actual;  
	registroDatos_siguiente = registroDatos_actual;  
	bit_transmitir_siguiente = bit_transmitir_actual; 
	
	case (estado_actual)  
	/*------------------------------------------------------------------------------------------------------------*/
		WAIT: 
			begin
			    contadorTicks_siguiente = 4'b0000;
                contadorDatos_siguiente = 3'b000;			   
				bit_transmitir_siguiente = 1'b1;
				  
				if (comienzo_TX == 1'b1)  
				    begin  
					   estado_siguiente = START;  
					   contadorDatos_siguiente = 0;  
					   registroDatos_siguiente =  entrada_transmisor;  
				    end 
			end 
	/*------------------------------------------------------------------------------------------------------------*/
		START : 
			begin  
				bit_transmitir_siguiente = 1'b0;  
				if (senial_generadorTick) //si llego un tick de generador de baudios
				    begin 
					   if (contadorTicks_actual == 15)  //si se contaron 15 ticks ya
						  begin  
							estado_siguiente = DATA;  //proximo estado va a ser "data"
							contadorTicks_siguiente = 0;  //reseteo el contador de ticks
							contadorDatos_siguiente = 0;  //reseteo el contador de dator reconocidos
						end 
					else 
					   begin 
						  contadorTicks_siguiente = contadorTicks_actual + 1 ;  //sino se llego a los 15 ticks, incremento el contador de ticks
                       end
                end
			end 
	/*------------------------------------------------------------------------------------------------------------*/
		DATA :  
			begin 
				bit_transmitir_siguiente = registroDatos_actual[0]; //en tx_next voy a colocar el primer elemento del registro que contiene los datos reconocidos // trasnsimitr el 7
				if (senial_generadorTick)  //si llego un tick del generador de baudios
					if (contadorTicks_actual == 15)  //si se llego a los 15 ticks
						begin  
							contadorTicks_siguiente = 0 ;  //reseteo el contador de ticks
							registroDatos_siguiente = registroDatos_actual  >> 1;  //despalzo los datos reconocidos una posicion //shift <<
	                          //PRIMER BIT TRANSMITIDO "MSB", ULTIMO BIT TRANSMITIDO "LSB"
							if  (contadorDatos_actual==(ancho_dato-1)) //si ya se reconocieron los 8 datos
							     begin
								    estado_siguiente=  STOP; //siguiente estado "stop"
						          end
							else  
							     begin
								    contadorDatos_siguiente = contadorDatos_actual + 1; //sino se reconocieron todos los datos, incremento el contador de datos reconocidos
							     end
						end 
					else 
					   begin 
						  contadorTicks_siguiente = contadorTicks_actual + 1;  //sino se llego a los 15 ticks, incremento el contador de ticks
					   end
			end 
	/*------------------------------------------------------------------------------------------------------------*/
		STOP : 
			begin  
				bit_transmitir_siguiente = 1'b1;  //indico que en el proximo se pueden transmitir los datos
				if (senial_generadorTick)  //si llega un tick del generador de baudios
					if  (contadorTicks_actual == 15)  //si se llego a la cantidad de ticks necesarias para contar hasta la mitad del bit de stop
						begin
							estado_siguiente=  WAIT;  //vuelve al estado inicial
							senial_ticks_completos 	= 1'b1;  //habilito la señal de salida por tick
						end 
					else  
						contadorTicks_siguiente =contadorTicks_actual + 1; //sino se llego a la cantidad de ticks, incrementa el contador de ticks
			end 
	endcase  
end 

        
endmodule













