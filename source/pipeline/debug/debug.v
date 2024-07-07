`timescale 1ns / 1ps



module debug #(
    parameter NB = 32,
    parameter DATA_BITS = 8
)   (
        input                                   i_clk,
        input                                   i_reset,
        input                                   i_uart_rx_ready,
        input           [DATA_BITS-1:0]         i_uart_rx_data,
        input                                   i_uart_tx_done,
        input           [NB-1:0]                i_mips_pc,
        output          [DATA_BITS-1:0]         o_uart_tx_data,
        output                                  o_uart_tx_ready,
        output          wire                    o_step
    );
    localparam IDLE           =   4'b0000; // estado inicial
    localparam STEP           =   4'b0001; // recibi una 's'
    localparam SEND_PC_TX     =   4'b0100; //  envio el PC
    localparam SEND_DATA_TX   =   4'b0100; //  envio 8 bit
    localparam WAIT_TX        =   4'b0110; // si en contador es 0 pasa a data_init sino voy al estado para cargar otro dato, deplazo de a 8 para de los 32 solo enviar los 8 que quiero


    reg [3:0]                               state, state_next;
    reg [NBITS-1:0]                         tx_data_32, tx_data_32_next;
    // Uart related registers
    reg [DATA_BITS-1:0]                     uart_tx_data, uart_tx_data_next;
    reg                                     uart_tx_ready, uart_tx_ready_next;
    reg [1:0]                               tx_count_bytes, tx_count_bytes_next;

    
    always@(posedge i_clk) begin
        if (i_reset) begin
            state <= IDLE;
            tx_data_32 <= 0;
            uart_tx_data <= 0;
            uart_tx_data_next <= 0;
            uart_tx_ready <= 0;
            uart_tx_ready_next <= 0;
        end
        else begin
            state <= state_next;
            tx_data_32 <= tx_data_32_next;
        end
    end

    always @(*) begin
        state_next = state;
        tx_data_32_next = tx_data_32;
        uart_tx_data_next = uart_tx_data;
        uart_tx_ready_next = uart_tx_ready;


        case(state)
        // explain this
            IDLE: begin
                if (i_uart_rx_ready) begin
                    case(i_uart_rx_data)
                        8'h73: begin
                            state_next = SEND_PC_TX; // Recibi un 's'
                        end
                        default: begin
                            state_next = IDLE;
                        end
                    endcase
                end
            end
            SEND_PC_TX: begin
                tx_data_32_next = i_mips_pc;
                state_next = SEND_DATA_TX;
            end
            SEND_DATA_TX: begin
                // Me quedo con los 8 bits superiores, despues en el siguiente estado se shiftean
                uart_tx_data_next = tx_data_32[NBITS-1: NBITS - DATA_BITS];
                uart_tx_ready_next = 1;
                state_next = WAIT_TX;
            end
            WAIT_TX: begin
                if (i_uart_tx_done) begin
                    tx_data_32_next = tx_data_32 << DATA_BITS; // shifteo 8 bits
                    uart_tx_ready_next = 0;
                    tx_count_bytes_next = tx_count_bytes + 1;
                    if (tx_count_bytes_next == 0) begin
                        state_next = SEND_DATA_TX;
                    end
                    else begin
                        state_next = IDLE;
                    end
                end
            end
            default: begin
                state_next = IDLE;
                uart_tx_data = 0;
                uart_tx_data_next = 0;
                uart_tx_ready = 0;
                uart_tx_ready_next = 0;
            end

        endcase
    end



endmodule