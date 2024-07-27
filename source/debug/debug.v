`timescale 1ns / 1ps

module debug #(
    parameter NB = 32,
    parameter DATA_BITS = 8,
    parameter NUMBER_REGISTERS = 32,
    parameter NB_REG = $clog2(NUMBER_REGISTERS + 1),
    parameter NB_STATE = 5
) (
    input                      i_clk,
    input                      i_reset,
    input                      i_uart_rx_ready,
    input      [DATA_BITS-1:0] i_uart_rx_data,
    input                      i_uart_tx_done,
    input      [       NB-1:0] i_mips_pc,
    input      [       NB-1:0] i_mips_register,
    input      [       NB-1:0] i_mips_alu_result,
    output     [   NB_REG-1:0] o_mips_register_number,
    output     [DATA_BITS-1:0] o_uart_tx_data,
    output                     o_uart_tx_ready,
    output reg                 o_step,
    output     [ NB_STATE-1:0] o_state_debug
);

  // States of debugger
  localparam IDLE = 1;  // estado inicial
  localparam STEP = 2;  // recibi una 's'
  localparam SEND_DATA_TX = 3;  //  envio 8 bit
  localparam WAIT_TX     =   4; // si en contador es 0 pasa a data_init sino voy al estado para cargar otro dato, deplazo de a 8 para de los 32 solo enviar los 8 que quiero
  localparam FETCH_REG = 5;

  // Fetch commands
  localparam CMD_FETCH_PC = 0;
  localparam CMD_FETCH_REGS = 1;
  localparam CMD_FETCH_ALU = 2;
  localparam CMD_FETCH_FINISHED = 3;
  localparam NUMBER_FETCH_CMDS = $clog2(CMD_FETCH_FINISHED + 1);


  reg [NB_STATE-1:0] state, state_next;
  reg [NB-1:0] tx_data_32, tx_data_32_next;
  // Uart related registers
  reg [DATA_BITS-1:0] uart_tx_data, uart_tx_data_next;
  reg uart_tx_ready, uart_tx_ready_next;
  reg [1:0] tx_count_bytes, tx_count_bytes_next;
  reg [NB_REG-1:0] mips_register_number, mips_register_number_next;
  reg [3:0] fetch_cmd, fetch_cmd_next;


  always @(posedge i_clk or posedge i_reset) begin
    if (i_reset) begin
      state <= IDLE;
      tx_data_32 <= 0;
      uart_tx_data <= 0;
      uart_tx_ready <= 0;
      tx_count_bytes <= 0;
      mips_register_number <= 0;
      fetch_cmd <= CMD_FETCH_PC;
    end else begin
      state                <= state_next;
      tx_data_32           <= tx_data_32_next;
      uart_tx_data         <= uart_tx_data_next;
      uart_tx_ready        <= uart_tx_ready_next;
      tx_count_bytes       <= tx_count_bytes_next;
      mips_register_number <= mips_register_number_next;
      fetch_cmd            <= fetch_cmd_next;
    end
  end

  always @(*) begin
    state_next = state;
    tx_data_32_next = tx_data_32;
    uart_tx_data_next = uart_tx_data;
    uart_tx_ready_next = uart_tx_ready;
    tx_count_bytes_next = tx_count_bytes;
    mips_register_number_next = mips_register_number;
    fetch_cmd_next = fetch_cmd;
    o_step = 0;


    case (state)
      IDLE: begin
        if (i_uart_rx_ready) begin
          case (i_uart_rx_data)
            8'h73: begin
              state_next = STEP;  // Recibi un 's'
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
            end
            else begin
                state_next = FETCH_REG;
                fetch_cmd_next = CMD_FETCH_ALU;
                tx_data_32_next = 0;
                mips_register_number_next = 0; 
            end
          end
          CMD_FETCH_ALU: begin
            tx_data_32_next = i_mips_alu_result;
            state_next = SEND_DATA_TX;
            fetch_cmd_next = CMD_FETCH_FINISHED;
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
      default: begin
        state_next = IDLE;
        uart_tx_data_next = 0;
        uart_tx_ready_next = 0;
        tx_count_bytes_next = 0;
        mips_register_number_next = 0;
        o_step = 0;
        fetch_cmd_next = CMD_FETCH_PC;
      end

    endcase
  end

  assign o_uart_tx_data  = uart_tx_data;
  assign o_uart_tx_ready = uart_tx_ready;
  assign o_mips_register_number = mips_register_number;
  assign o_state_debug   = state;


endmodule
