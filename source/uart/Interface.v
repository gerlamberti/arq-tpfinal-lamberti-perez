`timescale 1ns / 1ps
module Interfaz
#(   
        parameter   ancho_dato      = 8,
        parameter   ancho_dato_alu  = 8 //,
    )
    (
        /*-----Entradas al modulo-----*/
        input wire clk,
        input wire reset,  
        input wire senial_lecturaReceptor,                      //Señal si termino la recepcion, seria la señal "senial_ticks_completos" de nuestro receptor
        input wire senial_finTransmicion,                       //Señal si termino la transmision
        input wire [(ancho_dato-1):0] datoEntrada_receptor,   // Entrada de los 8 bits que van a ser el dato A,B o la Operacion, seria la señal "salida_receptor" de nuestro receptor                           
        
        /*-----Salidas al modulo-----*/	     
        output  reg comienzo_transmicion,                       // Señal para decir que empieza la transmicion, va a comenzar cuando se mande un 0 por aqui  
        output  wire [(ancho_dato-1):0] datoSalida_transmisor
    );

    /*---------Estados---------*/
    //CODIFICACION ONE-COLD
    localparam OPERANDO_A =                    5'b11110;//1E     // cargar dato A en ALU
    localparam OPERANDO_B =                    5'b11101;//1D      //cargar dato B en ALU
    localparam OPERACION =                       5'b11011;//1B     //cargar Operacion en ALU
    localparam INICIAR_TRANSMISION=       5'b10111;//17    //indicar al transmisor que transmita
    localparam WAIT_FIN_TRANSMISION=    5'b01111;//0F   //indicar al transmisor que transmita
    
    //registros internos
    reg     [4:0]  estado_actual; //Registro de estado
    reg     [4:0]  estado_siguiente;
    
    reg     [(ancho_dato_alu-1):0] dato_A_actual; // Registro que va a ir al dato A de la ALU    
    reg     [(ancho_dato_alu-1):0] dato_A_siguiente;  
    
    reg     [(ancho_dato_alu-1):0] dato_B_actual; // Registro que va a ir al dato B de la ALU             
    reg     [(ancho_dato_alu-1):0] dato_B_siguiente;
     
    reg     [5:0]    dato_Op_actual;    // Registro que va a ir a la operacion de la ALU
    reg     [5:0] dato_Op_siguiente;   
    
    reg flag_actual;
    reg flag_siguiente;
    
    //Instanciacion de modulos
 Alu ALU_1
 (
    .i_A(dato_A_actual), 
    .i_B(dato_B_actual), 
    .i_Op(dato_Op_actual), 
    .o_salida(datoSalida_transmisor)//antes entre () esta (salida_alu)
 );

    
 /*--------------------------------------Bloque secuencial--------------------------------------*/     
    always@(posedge clk) begin 
       if (reset) begin 
           estado_actual <= OPERANDO_A; 
           dato_A_actual <= 0;
           dato_B_actual <= 0;
           dato_Op_actual <= 0;
           flag_actual <= 0;
       end 
       else 
        begin
           estado_actual <= estado_siguiente;
           dato_A_actual <= dato_A_siguiente;
           dato_B_actual <= dato_B_siguiente;
           dato_Op_actual <= dato_Op_siguiente;
           flag_actual <= flag_siguiente;
           
       end
   end
    
    
 /*--------------------------------------Bloque puramente combinacional --------------------------------------*/     
   always@(*) begin
    dato_A_siguiente = dato_A_actual;
    dato_B_siguiente = dato_B_actual;
    dato_Op_siguiente = dato_Op_actual;
    comienzo_transmicion = 1'b0;
    flag_siguiente = flag_actual;
    
    case (estado_actual)
     /*------------------------------------------------------------------------------------------------------------*/
        OPERANDO_A : begin //Esta en el estado de poner el datoA en la ALU
           if (senial_lecturaReceptor == 1) 
                begin 
                    dato_A_siguiente = datoEntrada_receptor;
                    flag_siguiente = 1;  //flag_actual=1, cuando el dato A este completo con los 8 bits
                    estado_siguiente = OPERANDO_A; // no esta compelto el dato A
                end
           else 
                begin                         
                    estado_siguiente = OPERANDO_A;// SI NO ESTA 
                    if(flag_actual)
                        begin   //ingresa porque el dato A se cargo en su totalidad
                            estado_siguiente = OPERANDO_B;
                            flag_siguiente = 0;
                        end
                end
       end
    /*------------------------------------------------------------------------------------------------------------*/
       OPERANDO_B : begin //Esta en el estado de poner el datoB en la ALU
           if (senial_lecturaReceptor == 1) 
                begin
                    dato_B_siguiente = datoEntrada_receptor;
                    estado_siguiente = OPERANDO_B;
                    flag_siguiente = 1;
                end
           else 
                begin
                    estado_siguiente = OPERANDO_B;
                    if(flag_actual)                                                     //CUANDO flag_actual ESTE EN 1 EL DATO_B SE CARGO
                        begin
                            estado_siguiente = OPERACION;
                            flag_siguiente = 0;
                        end
              end        
       end
    /*------------------------------------------------------------------------------------------------------------*/   
       OPERACION : begin //Esta en el estado de pasar la operacion a la ALU
          if (senial_lecturaReceptor == 1) 
                begin  
                    dato_Op_siguiente = datoEntrada_receptor;
                    estado_siguiente = INICIAR_TRANSMISION;                              
                end
           else 
                begin                                                                              
                    estado_siguiente = OPERACION;
                end  
       end
       
     /*------------------------------------------------------------------------------------------------------------*/  
     INICIAR_TRANSMISION : begin
           comienzo_transmicion = 1'b1; //se habilita el comienzo de la transmision
           estado_siguiente = WAIT_FIN_TRANSMISION;       
       end
     /*------------------------------------------------------------------------------------------------------------*/  
     WAIT_FIN_TRANSMISION: begin
        if(senial_finTransmicion == 1'b1)
        estado_siguiente = OPERANDO_A;
     end
     /*------------------------------------------------------------------------------------------------------------*/  
       default 
            begin
                estado_siguiente = OPERANDO_A;
            end
            
   endcase 
   
  end
    
endmodule