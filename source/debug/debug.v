`timescale 1ns / 1ps
`include "instruction_constants.vh"

module debug #(
    parameter NB = 32,
    parameter DATA_BITS = 8,
    parameter NUMBER_REGISTERS = 32,
    parameter NUMBER_MEM_WORDS = 16,
    parameter NB_REG = $clog2(NUMBER_REGISTERS + 1),
    parameter NB_STATE = 5
) (
    input i_clk,
    input i_reset,
    input i_uart_rx_ready,
    input [DATA_BITS-1:0] i_uart_rx_data,
    input i_uart_tx_done,
    input [NB-1:0] i_mips_pc,
    input [NB-1:0] i_mips_register,
    input [NB-1:0] i_mips_mem_data,
    input [NB-1:0] i_mips_alu_result,
    input i_mips_wb_halt,

    output     [   NB_REG-1:0] o_mips_register_number, // TODO: quitarle un bit a esto para que quede mas prolijo
    output [NB-1:0] o_mips_memory_address,
    output [DATA_BITS-1:0] o_uart_tx_data,
    output o_uart_tx_ready,
    output reg o_uart_rx_reset,
    output reg o_step,
    output [NB_STATE-1:0] o_state_debug,
    // outputs para escribir el instruction memory
    output reg o_instruction_write_enable,
    output reg [NB-1:0] o_instruction_address,
    output reg [NB-1:0] o_instruction_data
);

  // States of debugger
  localparam IDLE = 1;  // estado inicial
  localparam STEP = 2;  // recibi una 's'
  localparam SEND_DATA_TX = 3;  //  envio 8 bit
  localparam WAIT_TX     =   4; // si en contador es 0 pasa a data_init sino voy al estado para cargar otro dato, deplazo de a 8 para de los 32 solo enviar los 8 que quiero
  localparam WAIT_RX = 5;
  localparam FETCH_REG = 6;
  localparam WRITE_INSTRUCTION = 7;
  localparam CONTINOUOUS_MODE = 8;

  // Fetch commands
  localparam CMD_FETCH_PC = 0;
  localparam CMD_FETCH_REGS = 1;
  localparam CMD_FETCH_ALU = 2;
  localparam CMD_FETCH_MEM = 3;
  localparam CMD_FETCH_FINISHED = 4;

  // UART ASCII COMMANDS
  localparam ASCII_STEP_MODE = 8'h73;  // 's'
  localparam ASCII_WRITE_IM_MODE = 8'h69;  // 'i'
  localparam ASCII_CONTINUOUS_MODE = 8'h63;  // 'c'

  // HALT INSTRUCTION


  reg [NB_STATE-1:0] state, state_next;
  reg [NB-1:0] tx_data_32, tx_data_32_next;
  reg [NB-1:0] instruction_data_buffer_next;  // *** Buffer para guardar la instruccion a escribir ***

  // Uart related registers
  reg [DATA_BITS-1:0] uart_tx_data, uart_tx_data_next;
  reg uart_tx_ready, uart_tx_ready_next;
  reg [1:0] tx_count_bytes, tx_count_bytes_next;
  reg [1:0] instruction_byte_counter, instruction_byte_counter_next;
  reg [NB_REG-1:0] mips_register_number, mips_register_number_next;
  reg [3:0] fetch_cmd, fetch_cmd_next;
  reg [NB-1:0] mips_memory_address, mips_memory_address_next;
  reg [NB-1:0] instruction_address_next;
  reg instruction_write_enable_next;
  reg uart_rx_reset_next;


  always @(posedge i_clk or posedge i_reset) begin
    if (i_reset) begin
      state <= IDLE;
      tx_data_32 <= 0;
      uart_tx_data <= 0;
      uart_tx_ready <= 0;
      tx_count_bytes <= 0;
      mips_register_number <= 0;
      mips_memory_address <= 0;
      fetch_cmd <= CMD_FETCH_PC;
      o_instruction_data <= 0;
      instruction_byte_counter <= 0;
      o_instruction_address <= 0;
      o_instruction_write_enable <= 0;
      o_uart_rx_reset <= 0;
    end else begin
      state                      <= state_next;
      tx_data_32                 <= tx_data_32_next;
      uart_tx_data               <= uart_tx_data_next;
      uart_tx_ready              <= uart_tx_ready_next;
      tx_count_bytes             <= tx_count_bytes_next;
      mips_register_number       <= mips_register_number_next;
      mips_memory_address        <= mips_memory_address_next;
      fetch_cmd                  <= fetch_cmd_next;
      o_instruction_data         <= instruction_data_buffer_next;
      instruction_byte_counter   <= instruction_byte_counter_next;
      o_instruction_address      <= instruction_address_next;
      o_instruction_write_enable <= instruction_write_enable_next;
      o_uart_rx_reset            <= uart_rx_reset_next;
    end
  end

  always @(*) begin
    state_next = state;
    tx_data_32_next = tx_data_32;
    uart_tx_data_next = uart_tx_data;
    uart_tx_ready_next = uart_tx_ready;
    tx_count_bytes_next = tx_count_bytes;
    mips_register_number_next = mips_register_number;
    mips_memory_address_next = mips_memory_address;
    fetch_cmd_next = fetch_cmd;
    o_step = 0;
    instruction_data_buffer_next = o_instruction_data;
    instruction_byte_counter_next = instruction_byte_counter;
    instruction_address_next = o_instruction_address;
    instruction_write_enable_next = 0;
    uart_rx_reset_next = 0;
    case (state)
      IDLE: begin
        if (i_uart_rx_ready) begin
          case (i_uart_rx_data)
            ASCII_STEP_MODE: begin
              state_next = STEP;
            end
            ASCII_WRITE_IM_MODE: begin
              instruction_address_next = 0;
              instruction_data_buffer_next = 0;
              instruction_byte_counter_next = 0;
              uart_rx_reset_next = 1;
              state_next = WAIT_RX;
            end
            ASCII_CONTINUOUS_MODE: begin
              state_next = CONTINOUOUS_MODE;
            end
            default: begin
              state_next = IDLE;
            end
          endcase
        end
      end
      STEP: begin
        o_step = 1;
        state_next = FETCH_REG;
      end
      SEND_DATA_TX: begin
        // Me quedo con los 8 bits superiores, despues en el siguiente estado se shiftean
        uart_tx_data_next = tx_data_32[NB-1:NB-DATA_BITS];
        uart_tx_ready_next = 1;
        state_next = WAIT_TX;
      end
      WAIT_RX: begin
        // La ultima instruccion deberia ser un HALT
        if (o_instruction_data == `HALT_INSTRUCTION) begin
          state_next = IDLE;
          instruction_write_enable_next = 0;
        end else begin
          if (o_instruction_write_enable) begin
            // Si ya escribi el address ahora si lo aumento
            // si no hago esto va a arrancar en address 0x4 siempre (defasado) 
            instruction_address_next = o_instruction_address + 4;
          end
          instruction_write_enable_next = 0;
          if (i_uart_rx_ready) begin
            instruction_data_buffer_next  = {o_instruction_data[23:0], i_uart_rx_data};
            instruction_byte_counter_next = instruction_byte_counter + 1;
            if (instruction_byte_counter_next == 0) state_next = WRITE_INSTRUCTION;
            else state_next = WAIT_RX;
          end
        end
      end
      WAIT_TX: begin
        if (i_uart_tx_done) begin
          tx_data_32_next = tx_data_32 << DATA_BITS;  // shifteo 8 bits
          uart_tx_ready_next = 0;
          tx_count_bytes_next = tx_count_bytes + 1;
          if (tx_count_bytes_next == 0)  // Termin� de contar 4. Vuelvo a IDLE 
            state_next = FETCH_REG;
          else state_next = SEND_DATA_TX;
        end
      end
      FETCH_REG: begin
        case (fetch_cmd)
          CMD_FETCH_PC: begin
            tx_data_32_next = i_mips_pc;
            state_next = SEND_DATA_TX;
            fetch_cmd_next = CMD_FETCH_REGS;
          end
          CMD_FETCH_REGS: begin
            if (mips_register_number < NUMBER_REGISTERS) begin
              state_next = SEND_DATA_TX;
              fetch_cmd_next = CMD_FETCH_REGS;
              tx_data_32_next = i_mips_register;
              mips_register_number_next = mips_register_number + 1;
            end else begin
              state_next = FETCH_REG;
              fetch_cmd_next = CMD_FETCH_ALU;
              tx_data_32_next = 0;
              mips_register_number_next = 0;
            end
          end
          CMD_FETCH_ALU: begin
            tx_data_32_next = i_mips_alu_result;
            state_next = SEND_DATA_TX;
            fetch_cmd_next = CMD_FETCH_MEM;
          end
          CMD_FETCH_MEM: begin
            if (mips_memory_address < (NUMBER_MEM_WORDS * 4)) begin
              state_next = SEND_DATA_TX;
              fetch_cmd_next = CMD_FETCH_MEM;
              tx_data_32_next = i_mips_mem_data;
              mips_memory_address_next = mips_memory_address + 4;
            end else begin
              state_next = FETCH_REG;
              fetch_cmd_next = CMD_FETCH_FINISHED;
              tx_data_32_next = 0;
              mips_memory_address_next = 0;
            end
          end
          CMD_FETCH_FINISHED: begin
            tx_data_32_next = 0;
            state_next = IDLE;
            fetch_cmd_next = CMD_FETCH_PC;
          end
          default: begin
            state_next = IDLE;
            fetch_cmd_next = CMD_FETCH_FINISHED;
          end
        endcase
      end
      WRITE_INSTRUCTION: begin
        instruction_write_enable_next = 1;
        state_next = WAIT_RX;
      end
      CONTINOUOUS_MODE: begin
        if (i_mips_wb_halt) begin
          o_step = 0;
          state_next = FETCH_REG;
        end else begin
          o_step = 1;
          state_next = CONTINOUOUS_MODE;
        end
      end
      default: begin
        state_next = IDLE;
        uart_tx_data_next = 0;
        uart_tx_ready_next = 0;
        tx_count_bytes_next = 0;
        mips_register_number_next = 0;
        mips_memory_address_next = 0;
        o_step = 0;
        fetch_cmd_next = CMD_FETCH_PC;
        instruction_data_buffer_next = 0;
        instruction_byte_counter_next = 0;
        instruction_address_next = 0;
        instruction_write_enable_next = 0;
        uart_rx_reset_next = 0;
      end

    endcase
  end

  assign o_uart_tx_data = uart_tx_data;
  assign o_uart_tx_ready = uart_tx_ready;
  assign o_mips_register_number = mips_register_number;
  assign o_mips_memory_address = mips_memory_address;
  assign o_state_debug = state;


endmodule
