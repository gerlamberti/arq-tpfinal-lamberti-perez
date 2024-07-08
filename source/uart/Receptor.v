`timescale 1ns / 1ps
module Receptor
#(
parameter   ancho_dato = 8
)
(
/*-----Entradas al modulo-----*/
	input wire clk, 
	input wire reset,                              //linea de reset
	input wire RX,                                 //linea de recepcion
	input wire senial_generadorTick,      //entrada que proviene del generador de baudios
	
/*-----Salidas al modulo-----*/	
	output reg senial_ticks_completos,  
	output wire [(ancho_dato-1):0] salida_receptor//salida de datos hacia la interfaz
);

/*---------Estados---------*/
    //CODIFICACION ONE-COLD
    localparam WAIT=    4'b1110;      // estado WAIT , espera por el bit de start.
    localparam START=   4'b1101;      //START, bit que indica el comienzo de la comunicacion.
    localparam DATA=    4'b1011;      //DATA, indica el comiendo del envio de datos, hacia el receptor .
    localparam STOP=    4'b0111;      //STOP, indica la finalizacion de la comunicacion.
    
    reg [3:0] estado_actual;                                        //cuando inicializo el primer estado cargado es el idle
    reg [3:0] estado_siguiente;                                   //sigueinte estado va a ser start cuando llegue el 0 logico

    reg [3:0] contadorTicks_actual;                             //cuenta la cantidad de ticks recibidos para saber cuando leer el dato
    reg [3:0] contadorTicks_siguiente; 

    reg [2:0] contadorDatos_actual;                            //cuenta la cantidad de datos recibidos, debe contar hasta 8
    reg [2:0] contadorDatos_siguiente;

    reg [(ancho_dato-1):0] registroDatos_actual;        //datos a la salida 
    reg [(ancho_dato-1):0] registroDatos_siguiente;
    
/*--------------------------------------Bloque secuencial--------------------------------------*/    
always @(posedge clk) begin// Memory - bloque secuencial
	if (reset)  
        begin  
			 estado_actual <= WAIT;             //volvemos al estado wait
			 
			 contadorTicks_actual <= 4'b0000;        //cantidad de ticks contado = 0
			 
			 contadorDatos_actual <= 3'b000;      //cantidad de datos contados
			 
			 registroDatos_actual <= 8'b00000000; 
		  end 
	else  
		begin  
			estado_actual <= estado_siguiente;
			contadorTicks_actual <= contadorTicks_siguiente; 
			contadorDatos_actual <= contadorDatos_siguiente;   
			registroDatos_actual <= registroDatos_siguiente;  
		end 
end

/*--------------------------------------Bloque puramente combinacional --------------------------------------*/    
always @(*) // Next-state logic  - bloque puramente combinacional   -  CAMBIAR LA LISTA DE SENSIBILIZACION SI ES NECESARIO DINOSAURIO
begin
    
	estado_siguiente=estado_actual; 
	senial_ticks_completos = 1'b0;  //señal de salida del modulo en 0
	contadorTicks_siguiente = contadorTicks_actual;
	contadorDatos_siguiente = contadorDatos_actual;   //nreg: cuenta la cantidad de bits
	registroDatos_siguiente = registroDatos_actual;  
	
	case (estado_actual)
	/*------------------------------------------------------------------------------------------------------------*/
		WAIT : //si estamos en el estado "WAIT"
			begin
				if (RX==0)//si se recibe un 0 logico
					estado_siguiente = START; //cambiamos el estado a START
					contadorTicks_siguiente=0;//cantidad de ticks contados
			end
	/*------------------------------------------------------------------------------------------------------------*/
		START : //si estamos en el estado "start"
			begin 
			registroDatos_siguiente=8'b0000000000;
				if (senial_generadorTick)//indica que llego un tick desde el generador de baudios
					if(contadorTicks_actual==7)//si llegaron 7 ticks, estamos a la mitad del bit de start
						begin
							contadorTicks_siguiente=0;//cantidad de bits contados = 0
							contadorDatos_siguiente=0;//reseteo a 0 el contador de datos reconocidos
							estado_siguiente = DATA; 
						end
					else
						contadorTicks_siguiente=contadorTicks_actual+1;//si aun no llegamos a la mitad del bit de start, incrementa la cantidad de ticks realizados
			end
	/*------------------------------------------------------------------------------------------------------------*/
		DATA : //si estamos en el estado "data"
			begin
				if (senial_generadorTick)//indica que llego un tick desde el generador de baudios
				
					if(contadorTicks_actual==15)//si ya llegue a la mitad del sigueinte bit
						begin
						    contadorTicks_siguiente = 0;//en el proximo tick debo resetear el contador de ticks, s_next va a ser proximo valor que va a tener el contador de ticks (s_reg)
                            registroDatos_siguiente={RX,registroDatos_actual[(ancho_dato-1):1]}; //guarda los datos reconocidos
						      //SE CARGA PRIMERO EL BIT MSB Y ULTIMO EL LSB
						      if (contadorDatos_actual == (ancho_dato-1))//si ya lei todos los bytes de de datos
							     estado_siguiente = STOP;//el siguente estado es "stop"
						      else
						         contadorDatos_siguiente=contadorDatos_actual+1;//n_next va el siguente valor a cargar en el contador de datos leidos
						 end	
					else
						contadorTicks_siguiente=contadorTicks_actual+1;//nuevo valor de contador de ticks
			end
	/*------------------------------------------------------------------------------------------------------------*/
		STOP : //si estamos en el estado "stop"
			begin 
				if (senial_generadorTick)//indica que llego un tick desde el generador de baudios
				begin
					if (contadorTicks_actual==15)//si se llego a la cantidad de ticks necesarias para contar hasta la mitad del bit de stop
						begin
						senial_ticks_completos=1'b1;//habilito la señal de salida por tick
						estado_siguiente = WAIT; //vuelvo al estado inicial
						end
					else
					   begin
						  contadorTicks_siguiente=contadorTicks_actual+1;//sigo contando ticks
					   end
               end 
			end
	/*------------------------------------------------------------------------------------------------------------*/
		default : // Fault Recovery - modo seguro
			begin
				estado_siguiente = WAIT; //volvemos al estado WAIT
				contadorTicks_siguiente=4'b0000;
				contadorDatos_siguiente=3'b000;
				registroDatos_siguiente=8'b0000000000;
			end
	/*------------------------------------------------------------------------------------------------------------*/
	endcase	
end

assign salida_receptor = registroDatos_actual;
endmodule