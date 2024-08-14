`timescale 1ns / 1ps
module TOP_debug #(
    parameter ancho_dato = 8,
    parameter BAUD_RATE = 9600,  //velocidad tipica 
    parameter FREC_CLOCK_MHZ = 10,
    parameter NB = 32
) (
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
  wire w_receptor_reset;
  wire comienzo_transmicion;
  wire [ancho_dato-1:0] salida_receptor;  //?????????????????????????????????????????
  wire [ancho_dato-1:0] entrada_transmisor_wire;  //?????????????????????????????????????????
  wire step;
  wire [NB-1:0] w_mips_pc,
  	 w_if_instruction,
	 w_id_instruction,
	 w_if_id_pc4,
     w_debug_mips_register_number;
  wire [5:0] w_ID_instruction_funct_code, w_ID_instruction_op_code;
  wire [5:0] w_EX_instruction_funct_code, w_EX_instruction_op_code;
  wire w_ID_alu_src, w_EX_alu_src;
  wire [NB-1:0] w_ID_data_a,w_ID_data_b, 
                w_EX_data_a,w_EX_data_b,
                w_ID_extension_result,w_EX_extension_result,
                w_mips_register_data,
                w_mips_alu_result,
                w_mips_mem_data,
                w_mips_wb_halt,
                w_debug_memory_address;
  // Write to instruction memory
  wire w_instruction_write_enable;
  wire [NB-1:0] w_instruction_address;
  wire [NB-1:0] w_instruction_data;
  
    clk_wiz_0 clk_wiz
   (
    .clk_out1(clk_wz),     // output clk_out50MHz
    .reset(reset), // input reset
    .clk_in1(clk)
    );   
  /*-----------------------------------------------------------------------------------*/
  // instanciando el generador de baudio 
  GeneradorDeBaudios #(
      .BAUD_RATE(BAUD_RATE),
      .FREC_CLOCK_MHZ(FREC_CLOCK_MHZ)
  ) generador_ticks (
      .clk(clk_wz),
      .reset(reset),
      .senial_tick(senial_tick)
  );


  /*-----------------------------------------------------------------------------------*/
  //INSTANCIANDO EL RECEPTOR
  Receptor #(
      .ancho_dato(ancho_dato)
  ) receptor (
      //------------------entradas------------------//
      .clk(clk_wz),
      .reset(w_receptor_reset),
      .RX(Entrada_RX),  //linea de recepcion
      .senial_generadorTick(senial_tick),  //entrada que proviene del generador de baudios

      //------------------Salidas------------------//
      .senial_ticks_completos(tick_completos_receptor),
      .salida_receptor(salida_receptor)  //salida de datos hacia la interfaz
  );

  /*-----------------------------------------------------------------------------------*/
  //INSTANCIANDO LA INTERFAZ
  debug #(
      .NB(32),
      .DATA_BITS(8)
  ) debug_unit (
      //------------------entradas------------------//
      .i_clk(clk_wz),
      .i_reset(reset),
      .i_uart_rx_ready(tick_completos_receptor), // EN .salida_receptor     DE LA INSTANCIACION DEL RECEPTOR HAY QUE PONER EL MUSMO PARAMETRO.    
      .i_uart_rx_data(salida_receptor),  //salida del receptor OKEY
      .i_uart_tx_done(tick_completos_transmisor),//EL FIN DE TRANSMISION SE DA CUANDO LOS TICKS ESTAN COMPLETOS POR LO TANTO SE PONE EL MISMO PARAMETRO EN                                                             
      .i_mips_pc(w_mips_pc),
      .i_mips_register(w_mips_register_data),
      .i_mips_mem_data(w_mips_mem_data),
      .i_mips_alu_result(w_mips_alu_result),
      .i_mips_wb_halt(w_mips_wb_halt),
      //------------------salidas------------------//
      .o_uart_tx_ready(comienzo_transmicion), //El comieno de la trasmision es cuando la interfaz alu este vacia      ESTE ES UNICO QUE TENGO DUDA DINOSAURIO
      .o_uart_tx_data(entrada_transmisor_wire),  //se�al que va a salir de la interfaz hacia el modulo que le sigue
      .o_step(step),
      .o_state_debug(o_leds[3:0]),
      .o_mips_register_number(w_debug_mips_register_number),
      .o_mips_memory_address(w_debug_memory_address),
      .o_instruction_write_enable(w_instruction_write_enable),
      .o_instruction_address(w_instruction_address),
      .o_instruction_data(w_instruction_data),
      .o_uart_rx_reset(w_receptor_reset)
  );


  PIPELINE #(
      .NB(NB)
  ) pipeline (
      .i_clk(clk_wz),
      .i_step(step),
      .i_reset(reset),
      .i_debug_mips_register_number(w_debug_mips_register_number),
      .i_debug_address(w_debug_memory_address),
      .i_instruction_write_enable(w_instruction_write_enable),
      .i_instruction_address(w_instruction_address),
      .i_instruction_data(w_instruction_data),
      .o_mips_pc(w_mips_pc),
      .o_mips_alu_result(w_mips_alu_result),
      .o_mips_register_data(w_mips_register_data),
      .o_mips_data_memory(w_mips_mem_data),
      .o_mips_wb_halt(w_mips_wb_halt)
  );

  /*-----------------------------------------------------------------------------------*/
  //INSTANCIANDO EL TRANSMISOR
  Transmisor #(
      .ancho_dato(ancho_dato)
  ) transmisor (
      //------------------entradas------------------//
      .clk(clk_wz),
      .reset(reset),
      .comienzo_TX(comienzo_transmicion),
      .senial_generadorTick(senial_tick),
      .entrada_transmisor(entrada_transmisor_wire),

      //------------------salidas------------------// 
      .senial_ticks_completos(tick_completos_transmisor), //rd_a_tx_done_tick ANTES ESTABA ESTA VARIABLE ELLOS USABAN 2  REG DIFERENTES PARA EL DONE
      .TX(Salida_TX)
  );


endmodule
