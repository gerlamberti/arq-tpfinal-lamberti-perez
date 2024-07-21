`timescale 1ns / 1ps
module TOP_debug #(
    parameter ancho_dato = 8,
    parameter BAUD_RATE = 9600,  //velocidad tipica 
    parameter FREC_CLOCK_MHZ = 100,
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
                w_mips_alu_result;
  /*-----------------------------------------------------------------------------------*/
  // instanciando el generador de baudio 
  GeneradorDeBaudios #(
      .BAUD_RATE(BAUD_RATE),
      .FREC_CLOCK_MHZ(FREC_CLOCK_MHZ)
  ) generador_ticks (
      .clk(clk),
      .reset(reset),
      .senial_tick(senial_tick)
  );


  /*-----------------------------------------------------------------------------------*/
  //INSTANCIANDO EL RECEPTOR
  Receptor #(
      .ancho_dato(ancho_dato)
  ) receptor (
      //------------------entradas------------------//
      .clk(clk),
      .reset(reset),
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
      .i_clk(clk),
      .i_reset(reset),
      .i_uart_rx_ready(tick_completos_receptor), // EN .salida_receptor     DE LA INSTANCIACION DEL RECEPTOR HAY QUE PONER EL MUSMO PARAMETRO.    
      .i_uart_rx_data(salida_receptor),  //salida del receptor OKEY
      .i_uart_tx_done(tick_completos_transmisor),//EL FIN DE TRANSMISION SE DA CUANDO LOS TICKS ESTAN COMPLETOS POR LO TANTO SE PONE EL MISMO PARAMETRO EN                                                             
      .i_mips_pc(w_mips_pc),
      .i_mips_register(w_mips_register_data),
      .i_mips_alu_result(w_mips_alu_result),
      //------------------salidas------------------//
      .o_uart_tx_ready(comienzo_transmicion), //El comieno de la trasmision es cuando la interfaz alu este vacia      ESTE ES UNICO QUE TENGO DUDA DINOSAURIO
      .o_uart_tx_data(entrada_transmisor_wire),  //se�al que va a salir de la interfaz hacia el modulo que le sigue
      .o_step(step),
      .o_state_debug(o_leds[3:0]),
      .o_mips_register_number(w_debug_mips_register_number)

  );

  IF #(
      .NB(32),
      .TAM_I(256)
  ) FETCH (
      .i_clk(clk),
      .i_step(step),
      .i_reset(reset),
      .i_pc_write(1),
      .o_instruction(w_if_instruction),
      .o_IF_pc(w_mips_pc),
      .o_IF_pc4(w_if_id_pc4)
  );

  IF_ID #(
      .NB(32)
  ) intermedio_fetch_decode (
      .i_clk(clk),
      .i_step(step),
      .i_reset(reset),
      .i_pc4(w_if_id_pc4),
      .i_instruction(w_if_instruction),
      .o_pc4(),
      .o_instruction(w_id_instruction)
  );


  ID #(
      .NB     (32),
      .REGS   (5),
      .INBITS (16),
      .CTRLNB (6),
      .TAM_REG(32)
  ) DECODE (
      .i_clk(clk),
      .i_step(step),
      .i_reset(reset),
      .i_instruction(w_id_instruction),
      .i_mips_register_number(w_debug_mips_register_number),
      .o_data_a(w_ID_data_a),
      .o_data_b(w_ID_data_b),
      .o_mips_register_data(w_mips_register_data),
      .o_alu_src(w_ID_alu_src),
      .o_intruction_funct_code(w_ID_instruction_funct_code),
      .o_intruction_op_code(w_ID_instruction_op_code),
      .o_extension_result(w_ID_extension_result)
  );

  ID_EX #(
      .NB(32),
      .NB_OPCODE(6),
      .NB_FCODE(6)
  ) Intermedio_decode_execute (
      .i_clk(clk),
      .i_step(step),
      .i_reset(reset),
      .i_instruction_funct_code(w_ID_instruction_funct_code),
      .i_instruction_op_code(w_ID_instruction_op_code),
      .i_alu_src(w_ID_alu_src),  // 0 data_b, 1 immediate
      .i_data_a(w_ID_data_a),
      .i_data_b(w_ID_data_b),
      .i_extension_result(w_ID_extension_result),

      .o_instruction_funct_code(w_EX_instruction_funct_code),
      .o_instruction_op_code   (w_EX_instruction_op_code),
      .o_alu_src               (w_EX_alu_src),                 // 0 data_b, 1 immediate
      .o_data_a                (w_EX_data_a),
      .o_data_b                (w_EX_data_b),
      .o_extension_result      (w_EX_extension_result)
  );
  EXECUTE #(
      .NB(32),
      .NB_FCODE(6),
      .NB_OPCODE(6),
      .NB_ALU_OP(4)
  ) EXECUTE (
      .i_instruction_funct_code(w_EX_instruction_funct_code),
      .i_instruction_op_code(w_EX_instruction_op_code),
      .i_alu_src(w_EX_alu_src),  // 0 data_b, 1 immediate
      .i_data_a(w_EX_data_a),
      .i_data_b(w_EX_data_b),
      .i_extension_result(w_EX_extension_result),  // Viene del decode, es el imm extendido
      .o_cero(),
      .o_alu_result(w_mips_alu_result)
  );

  /*-----------------------------------------------------------------------------------*/
  //INSTANCIANDO EL TRANSMISOR
  Transmisor #(
      .ancho_dato(ancho_dato)
  ) transmisor (
      //------------------entradas------------------//
      .clk(clk),
      .reset(reset),
      .comienzo_TX(comienzo_transmicion),
      .senial_generadorTick(senial_tick),
      .entrada_transmisor(entrada_transmisor_wire),

      //------------------salidas------------------// 
      .senial_ticks_completos(tick_completos_transmisor), //rd_a_tx_done_tick ANTES ESTABA ESTA VARIABLE ELLOS USABAN 2  REG DIFERENTES PARA EL DONE
      .TX(Salida_TX)
  );


endmodule
