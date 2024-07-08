`timescale 1ns / 1ps

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

    localparam TEST_PC_TO_SEND = 32'h1ba5e93f;
    // Clock generation
    always #10 i_clk = ~i_clk;
    initial i_clk = 0;
    initial i_reset = 1;

    // Tests 
    initial begin
        // Arranca todo reseteado
        
        i_reset = 1;
        i_uart_rx_ready = 0;
        i_uart_rx_data = 0;
        i_uart_tx_done = 0;
        i_mips_pc = 0;
        #10
        if ( o_uart_tx_data !== 0  ||
             o_uart_tx_ready !== 0 ||
             o_step !== 0
         ) begin
            $display("Test 1: Deberia haber tenido todas las salidas en cero");
            $finish;
        end
        #10
        // Arrancamos el sistema
        i_reset = 0;
        i_uart_rx_ready = 0;
        i_uart_rx_data = 8'h44; // Simulemos que llega un caracter, pero no esta ready
        i_uart_tx_done = 0;
        i_mips_pc = 0;
        #10
        if (o_uart_tx_data != 0 || o_uart_tx_ready != 0 || o_step != 0) begin
            $display("Test 2: Si bien cambio el rx data no esta ready asi que no hago nada");
            $finish;
        end
        #10
        #100
        // Recibimos una 's' de step
        #10
        i_reset = 0;
        i_uart_rx_ready = 1; // Y encima esta ready
        i_uart_rx_data = 8'h73; // Simulemos que llega un caracter 's'
        i_uart_tx_done = 0;
        i_mips_pc = 0;
        #10
        if (o_uart_tx_data  !== 0 ||
            o_uart_tx_ready !== 0 ||
            o_step          !== 1 // Deberia estar en alto porque recibio un 's'
        ) begin
            $display("Test 3: Step tiene que estar en alto. Sin transmision de datos");
            $finish;
        end
        #10
        // Recibimos una 's' de step
        i_reset = 0;
        i_uart_rx_ready = 0; // Y encima esta ready
        i_uart_rx_data = 8'h73; // Simulemos que llega un caracter 's'
        i_uart_tx_done = 0;
        i_mips_pc = TEST_PC_TO_SEND;
        #10
        if (o_uart_tx_data  != 0 ||
            o_uart_tx_ready != 0 ||
            o_step          != 0 // Deberia estar en bajo porque al ser un step es un solo clock
        ) begin
            $display("Test 4: Step tiene que estar en bajo. En este clock ya recolectó los datos.");
            $finish;
        end
        #40
        // En el siguiente clock deberÃ­a haber una transmisiÃ³n 
        i_reset = 0;
        i_uart_rx_ready = 0; // Y encima esta ready
        i_uart_rx_data = 8'h00; // Ya para esta altura no debería alterar
        i_uart_tx_done = 0;
        i_mips_pc = 32'h0; // Tampoco a esta altura debería importar el PC. Ya debería estar guardado adentro.
        #10
        if (o_uart_tx_data  !== TEST_PC_TO_SEND[31:24] || // Los primeros 8 bits más significativos
            o_uart_tx_ready !== 1                      ||
            o_step          !== 0 // Deberia estar en bajo porque al ser un step es un solo clock
        ) begin
            $display("Test 4: Se envia el PC");
            $finish;
        end
        #10
        i_uart_tx_done = 1; // Le digo al debug que ya envió
        #20
        if (o_uart_tx_ready !== 0) begin
            $display("Ya recibio el done. Tiene que bajar el flag de tx_ready");
            $finish;
        end
        #20
        if (o_uart_tx_data  !== TEST_PC_TO_SEND[23:16] || // Los segundos 8 bits más significativos
            o_uart_tx_ready !== 1                      ||
            o_step          !== 0 // Deberia estar en bajo porque al ser un step es un solo clock
        ) begin
            $display("Test 4: Se envian el segundo byte de PC");
            $finish;
        end
        
        #10
        i_uart_tx_done = 1; // Le digo al debug que ya envió
        #20
        if (o_uart_tx_ready !== 0) begin
            $display("Ya recibio el done. Tiene que bajar el flag de tx_ready");
            $finish;
        end
        
        #20
        if (o_uart_tx_data  !== TEST_PC_TO_SEND[15:8] || // Los terceros 8 bits más significativos
            o_uart_tx_ready !== 1                      ||
            o_step          !== 0 // Deberia estar en bajo porque al ser un step es un solo clock
        ) begin
            $display("Se envian el tercer byte de PC");
            $finish;
        end
       
         
        i_uart_tx_done = 1; // Le digo al debug que ya envió
        #10
        if (o_uart_tx_ready !== 0) begin
            $display("Ya recibio el done. Tiene que bajar el flag de tx_ready");
            $finish;
        end
        #30
        if (o_uart_tx_data  !== TEST_PC_TO_SEND[7:0] || // Los cuartos 8 bits más significativos
            o_uart_tx_ready !== 1                      ||
            o_step          !== 0 // Deberia estar en bajo porque al ser un step es un solo clock
        ) begin
            $display("Se envian el cuarto byte de PC");
            $finish;
        end
        
        
        #200
        $finish;
    end

endmodule
