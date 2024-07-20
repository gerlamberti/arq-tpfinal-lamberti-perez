`timescale 1ns / 1ps

module tb_debug;
    // Inputs
    reg         i_clk;
    reg         i_reset;
    reg         i_uart_rx_ready;
    reg [7:0]   i_uart_rx_data;
    reg         i_uart_tx_done;
    reg [31:0]  i_mips_pc,  
                i_mips_register,
                i_mips_alu_result,
                test_uart_accumulator,
                counter;
    // Outputs
    localparam NB_REG_O = $clog2(NUMBER_REGISTERS + 1);
    wire [NB_REG_O-1 : 0] o_mips_register_number;
    wire [7:0]  o_uart_tx_data;
    wire        o_uart_tx_ready;
    wire        o_step;
    localparam NUMBER_REGISTERS = 5;
    // Instantiate the Unit Under Test (UUT)
    debug #(
        .NB(32),
        .DATA_BITS(8),
        .NUMBER_REGISTERS(NUMBER_REGISTERS)
    ) uut (
        // Inputs
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_uart_rx_ready(i_uart_rx_ready),
        .i_uart_rx_data(i_uart_rx_data),
        .i_uart_tx_done(i_uart_tx_done),
        .i_mips_pc(i_mips_pc),
        .i_mips_register(i_mips_register),
        .i_mips_alu_result(i_mips_alu_result),
        // Outputs
        .o_mips_register_number(o_mips_register_number),
        .o_uart_tx_data(o_uart_tx_data),
        .o_uart_tx_ready(o_uart_tx_ready),
        .o_step(o_step)
    );    

    localparam TEST_PC_TO_SEND = 32'h1ba5e93f;

    // Clock generation
    always #10 i_clk = ~i_clk;
    initial i_clk = 0;
    initial i_reset = 1;
    
    reg [31:0] random_registers [0:NUMBER_REGISTERS-1];
    initial begin
        for (counter = 0; counter < NUMBER_REGISTERS; counter = counter + 1)
            random_registers[counter] = $random();  
    end
    always @(posedge i_clk) i_mips_register <= random_registers[o_mips_register_number];

    // Tests 
    initial begin
        // Arranca todo reseteado
        
        i_reset = 1;
        i_uart_rx_ready = 0;
        i_uart_rx_data = 0;
        i_uart_tx_done = 0;
        i_mips_pc = 0;
        i_mips_pc = 0;
        i_mips_register = 0;
        i_mips_alu_result = 0;
        
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
            $display("Test 4: Step tiene que estar en bajo. En este clock ya recolect� los datos.");
            $finish;
        end
        #40
        // En el siguiente clock debería haber una transmisión 
        i_reset = 0;
        i_uart_rx_ready = 0; // Y encima esta ready
        i_uart_rx_data = 8'h00; // Ya para esta altura no deber�a alterar
        i_uart_tx_done = 0;
        i_mips_pc = 32'h0; // Tampoco a esta altura deber�a importar el PC. Ya deber�a estar guardado adentro.
        #10
        if (o_uart_tx_data  !== TEST_PC_TO_SEND[31:24] || // Los primeros 8 bits m�s significativos
            o_uart_tx_ready !== 1                      ||
            o_step          !== 0 // Deberia estar en bajo porque al ser un step es un solo clock
        ) begin
            $display("Test 4: Se envia el PC");
            $finish;
        end
        #10
        i_uart_tx_done = 1; // Le digo al debug que ya envi�
        #20
        if (o_uart_tx_ready !== 0) begin
            $display("Ya recibio el done. Tiene que bajar el flag de tx_ready");
            $finish;
        end
        @(posedge o_uart_tx_ready);
        if (o_uart_tx_data  !== TEST_PC_TO_SEND[23:16] || // Los segundos 8 bits m�s significativos
            o_uart_tx_ready !== 1                      ||
            o_step          !== 0 // Deberia estar en bajo porque al ser un step es un solo clock
        ) begin
            $display("Test 4: Se envian el segundo byte de PC");
            $finish;
        end
        
        @(posedge o_uart_tx_ready);
        if (o_uart_tx_data  !== TEST_PC_TO_SEND[15:8] || // Los terceros 8 bits m�s significativos
            o_uart_tx_ready !== 1                      ||
            o_step          !== 0 // Deberia estar en bajo porque al ser un step es un solo clock
        ) begin
            $display("Se envian el tercer byte de PC");
            $finish;
        end
       
          @(posedge o_uart_tx_ready);
        
        if (o_uart_tx_data  !== TEST_PC_TO_SEND[7:0] || // Los cuartos 8 bits m�s significativos
            o_uart_tx_ready !== 1                      ||
            o_step          !== 0 // Deberia estar en bajo porque al ser un step es un solo clock
        ) begin
            $display("Se envian el cuarto byte de PC");
            $finish;
        end
        // Se testea que se envien los 32 registros
        for (
            counter = 0; 
            counter < NUMBER_REGISTERS;
            counter = counter + 1
        ) begin
            if (o_mips_register_number !== counter) begin
                $display("El nro de registro a buscar deberia ser %s", counter);
                $finish;
            end
            // Test sent uart
            test_uart_accumulator = 0;
            @(posedge o_uart_tx_ready);
            test_uart_accumulator[31:24] = o_uart_tx_data;
            @(posedge o_uart_tx_ready);
            test_uart_accumulator[23:16] = o_uart_tx_data;
            @(posedge o_uart_tx_ready);
            test_uart_accumulator[15:8] = o_uart_tx_data;
            @(posedge o_uart_tx_ready);
            test_uart_accumulator[7:0] = o_uart_tx_data;
           
            if (test_uart_accumulator  !== random_registers[counter] ||
                o_step          !== 0 // Por las dudas, nunca tiene que ser 1
            ) begin
                $display("Deber�a haberse enviado el MIPS register %h", i_mips_register);
                $finish;
            end  
        end
        // Testeo la Alu
        i_mips_alu_result = $random();

        test_uart_accumulator = 0;
        @(posedge o_uart_tx_ready);
        test_uart_accumulator[31:24] = o_uart_tx_data;
        @(posedge o_uart_tx_ready);
        test_uart_accumulator[23:16] = o_uart_tx_data;
        @(posedge o_uart_tx_ready);
        test_uart_accumulator[15:8] = o_uart_tx_data;
        @(posedge o_uart_tx_ready);
        test_uart_accumulator[7:0] = o_uart_tx_data;
        
        if (test_uart_accumulator  !== i_mips_alu_result ||
            o_step          !== 0 // Por las dudas, nunca tiene que ser 1
        ) begin
            $display("Se deberia haber enviado el Alu result %h", i_mips_alu_result);
            $finish;
        end
     
        #200
        $finish;
    end

endmodule
