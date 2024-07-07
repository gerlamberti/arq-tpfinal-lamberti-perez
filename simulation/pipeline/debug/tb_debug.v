`timescale 1ns/1ps

module tb_debug;
    // Inputs
    reg         i_clk;
    reg         i_reset;
    reg         i_uart_rx_ready;
    reg [7:0]   i_uart_rx_data;
    reg         i_uart_tx_done;
    reg [31:0]  i_mips_pc;
    // Outputs
    wire [7:0]  o_uart_tx_data;
    wire        o_uart_tx_ready;
    wire        o_step;
    // Instantiate the Unit Under Test (UUT)
    debug #(
        .NB(32),
        .DATA_BITS(8)
    ) uut (
        // Inputs
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_uart_rx_ready(i_uart_rx_ready),
        .i_uart_rx_data(i_uart_rx_data),
        .i_uart_tx_done(i_uart_tx_done),
        .i_mips_pc(i_mips_pc),
        // Outputs
        .o_uart_tx_data(o_uart_tx_data),
        .o_uart_tx_ready(o_uart_tx_ready),
        .o_step(o_step)
    );    

    // Clock generation
    always #10 i_clk = ~i_clk;
    initial i_clk = 0;

    // Tests 
    initial begin
        // Arranca todo reseteado
        i_reset = 1;
        i_uart_rx_ready = 0;
        i_uart_rx_data = 0;
        i_uart_tx_done = 0;
        i_mips_pc = 0;

        if (o_uart_tx_data == 0 && o_uart_tx_ready == 0 && o_step == 0) begin
            $display("Test 1: Deberia haber tenido todas las salidas en cero");
        end
        #10
        // Arrancamos el sistema
        i_reset = 0;
        i_uart_rx_ready = 0;
        i_uart_rx_data = 8'h44; // Simulemos que llega un caracter, pero no esta ready
        i_uart_tx_done = 0;
        i_mips_pc = 0;

        if (o_uart_tx_data == 0 && o_uart_tx_ready == 0 && o_step == 0) begin
            $display("Test 2: Si bien cambio el rx data no esta ready asi que no hago nada");
        end
        #100
        // Recibimos una 's' de step
        i_reset = 0;
        i_uart_rx_ready = 1; // Y encima esta ready
        i_uart_rx_data = 8'h73; // Simulemos que llega un caracter 's'
        i_uart_tx_done = 0;
        i_mips_pc = 0;
        #10
        if (o_uart_tx_data  == 0 &&
            o_uart_tx_ready == 0 &&
            o_step          == 1 // Deberia estar en alto porque recibio un 's'
        ) begin
            $display("Test 3: Step tiene que estar en alto. Sin transmision de datos");
        end
        #10
        // Recibimos una 's' de step
        i_reset = 0;
        i_uart_rx_ready = 0; // Y encima esta ready
        i_uart_rx_data = 8'h73; // Simulemos que llega un caracter 's'
        i_uart_tx_done = 0;
        i_mips_pc = 1;
        if (o_uart_tx_data  == 0 &&
            o_uart_tx_ready == 0 &&
            o_step          == 0 // Deberia estar en bajo porque al ser un step es un solo clock
        ) begin
            $display("Test 4: Step tiene que estar en alto. Sin transmision de datos");
        end
        #10
        // En el siguiente clock debería haber una transmisión 
        i_reset = 0;
        i_uart_rx_ready = 0; // Y encima esta ready
        i_uart_rx_data = 8'h73; // Simulemos que llega un caracter 's'
        i_uart_tx_done = 0;
        i_mips_pc = 1;
        if (o_uart_tx_data  == 32'h01 && // El PC es 1
            o_uart_tx_ready == 1 &&
            o_step          == 0 // Deberia estar en bajo porque al ser un step es un solo clock
        ) begin
            $display("Test 4: Se envia el PC");
        end
    end

endmodule
