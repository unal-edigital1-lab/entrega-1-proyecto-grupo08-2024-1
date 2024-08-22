module tamagotchi_fsm (
    input wire btn_salud,
    input wire btn_energia,
    input wire btn_hambre,
    input wire btn_diversion,
    input wire btn_reset,
    input wire btn_test,
    input wire clk,
    input wire [2:0] count_reset,  // Contador que varía entre 0 a 5 segundos para reset
    input wire [2:0] count_test,   // Contador que varía entre 0 a 5 segundos para test mode
    output reg [2:0] display_out
);

    // Definición de estados
    reg [3:0] niveles; // Niveles de cada estado
    reg [7:0] timer_salud, timer_energia, timer_hambre, timer_diversion; // Contadores de tiempo
    reg [1:0] btn_press_count; // Contador de presiones del botón
    reg test_mode; // Señal interna para modo de prueba

    // Inicialización de valores
    initial begin
        niveles = 4'b1000; // Todos los niveles en 8
        timer_salud = 0;
        timer_energia = 0;
        timer_hambre = 0;
        timer_diversion = 0;
        display_out = 3'b000; // Mostrar Salud y cara feliz por defecto
        btn_press_count = 2'b00; // Contador de presiones del botón
        test_mode = 1'b0; // Iniciar en modo normal
    end

    // Manejo del reset
    always @(posedge clk) begin
        if (count_reset == 3'b101) begin // 5 segundos en binario es 101
            niveles <= 4'b1000; // Reiniciar todos los niveles a 8
            display_out[2] <= 1'b1; // Cara feliz
            btn_press_count <= 2'b00; // Reiniciar contador de botones
            test_mode <= 1'b0; // Salir del modo de prueba
        end
    end

    // Manejo de la activación del modo test mediante el botón dedicado
    always @(posedge clk) begin
        if (btn_test && count_test == 3'b101) begin // 5 segundos en binario es 101
            test_mode <= 1'b1; // Activar modo de prueba
            btn_press_count <= 2'b00; // Reiniciar contador de botones
        end
    end

    // Manejo de los botones en modo normal o test
    always @(posedge clk) begin
        if (test_mode) begin
            // Modo test: Solo permitir niveles 1 o 10
            if (btn_salud) begin
                display_out[1:0] <= 2'b00; // Mostrar Salud
                if (btn_press_count == 2'b01) begin
                    niveles[3:2] <= (niveles[3:2] == 4'b0001) ? 4'b1010 : 4'b0001; // Alternar entre 1 y 10
                end
                btn_press_count <= btn_press_count + 1;
            end
            if (btn_energia) begin
                display_out[1:0] <= 2'b01; // Mostrar Energía
                if (btn_press_count == 2'b01) begin
                    niveles[3:2] <= (niveles[3:2] == 4'b0001) ? 4'b1010 : 4'b0001; // Alternar entre 1 y 10
                end
                btn_press_count <= btn_press_count + 1;
            end
            if (btn_hambre) begin
                display_out[1:0] <= 2'b10; // Mostrar Hambre
                if (btn_press_count == 2'b01) begin
                    niveles[3:2] <= (niveles[3:2] == 4'b0001) ? 4'b1010 : 4'b0001; // Alternar entre 1 y 10
                end
                btn_press_count <= btn_press_count + 1;
            end
            if (btn_diversion) begin
                display_out[1:0] <= 2'b11; // Mostrar Diversión
                if (btn_press_count == 2'b01) begin
                    niveles[3:2] <= (niveles[3:2] == 4'b0001) ? 4'b1010 : 4'b0001; // Alternar entre 1 y 10
                end
                btn_press_count <= btn_press_count + 1;
            end
        end else begin
            // Modo normal: Incrementar el nivel como antes, con límite de 10
            if (btn_salud) begin
                display_out[1:0] <= 2'b00; // Mostrar Salud
                if (display_out[1:0] == 2'b00 && niveles[3:2] < 4'b1010) begin
                    niveles[3:2] <= niveles[3:2] + 1; // Aumentar nivel Salud
                end
            end
            if (btn_energia) begin
                display_out[1:0] <= 2'b01; // Mostrar Energía
                if (display_out[1:0] == 2'b01 && niveles[3:2] < 4'b1010) begin
                    niveles[3:2] <= niveles[3:2] + 1; // Aumentar nivel Energía
                end
            end
            if (btn_hambre) begin
                display_out[1:0] <= 2'b10; // Mostrar Hambre
                if (display_out[1:0] == 2'b10 && niveles[3:2] < 4'b1010) begin
                    niveles[3:2] <= niveles[3:2] + 1; // Aumentar nivel Hambre
                end
            end
            if (btn_diversion) begin
                display_out[1:0] <= 2'b11; // Mostrar Diversión
                if (display_out[1:0] == 2'b11 && niveles[3:2] < 4'b1010) begin
                    niveles[3:2] <= niveles[3:2] + 1; // Aumentar nivel Diversión
                end
            end
        end
    end

    // Manejo del decremento de los niveles en modo normal
    always @(posedge clk) begin
        if (!test_mode) begin
            if (timer_salud == 120) begin
                niveles[3:2] <= niveles[3:2] - 1;
                timer_salud <= 0;
            end else timer_salud <= timer_salud + 1;

            if (timer_energia == 100) begin
                niveles[3:2] <= niveles[3:2] - 1;
                timer_energia <= 0;
            end else timer_energia <= timer_energia + 1;

            if (timer_hambre == 70) begin
                niveles[3:2] <= niveles[3:2] - 1;
                timer_hambre <= 0;
            end else timer_hambre <= timer_hambre + 1;

            if (timer_diversion == 50) begin
                niveles[3:2] <= niveles[3:2] - 1;
                timer_diversion <= 0;
            end else timer_diversion <= timer_diversion + 1;
        end
    end

    // Actualizar cara feliz/triste basado en el nivel del estado actual
    always @(posedge clk) begin
        case (display_out[1:0])
            2'b00: display_out[2] <= (niveles[3:2] >= 4'd5) ? 1'b1 : 1'b0; // Salud
            2'b01: display_out[2] <= (niveles[3:2] >= 4'd5) ? 1'b1 : 1'b0; // Energía
            2'b10: display_out[2] <= (niveles[3:2] >= 4'd5) ? 1'b1 : 1'b0; // Hambre
            2'b11: display_out[2] <= (niveles[3:2] >= 4'd5) ? 1'b1 : 1'b0; // Diversión
        endcase
    end

endmodule
