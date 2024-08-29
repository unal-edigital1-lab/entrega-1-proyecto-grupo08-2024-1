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
    output reg [2:0] display_out,
    output reg [6:0] seg_display  // Salida para la regleta de 7 segmentos
);

    // Definición de niveles separados para cada estado
    reg [3:0] nivel_salud;
    reg [3:0] nivel_energia;
    reg [3:0] nivel_hambre;
    reg [3:0] nivel_diversion;

    reg [7:0] timer_salud, timer_energia, timer_hambre, timer_diversion; // Contadores de tiempo
    reg [1:0] btn_press_count; // Contador de presiones del botón
    reg test_mode; // Señal interna para modo de prueba

    // Inicialización de valores
    initial begin
        nivel_salud = 4'b1000;   // Nivel de Salud inicial en 8
        nivel_energia = 4'b1000; // Nivel de Energía inicial en 8
        nivel_hambre = 4'b1000;  // Nivel de Hambre inicial en 8
        nivel_diversion = 4'b1000; // Nivel de Diversión inicial en 8
        timer_salud = 0;
        timer_energia = 0;
        timer_hambre = 0;
        timer_diversion = 0;
        display_out = 3'b000; // Mostrar Salud y cara feliz por defecto
        btn_press_count = 2'b00; // Contador de presiones del botón
        test_mode = 1'b0; // Iniciar en modo normal
        seg_display = 7'b0000000; // Inicializar la regleta de 7 segmentos en 0
    end

    // Manejo del reset
    always @(posedge clk) begin
        if (btn_reset) begin // 5 segundos en binario es 101
            nivel_salud <= 4'b1000;   // Reiniciar nivel de Salud a 8
            nivel_energia <= 4'b1000; // Reiniciar nivel de Energía a 8
            nivel_hambre <= 4'b1000;  // Reiniciar nivel de Hambre a 8
            nivel_diversion <= 4'b1000; // Reiniciar nivel de Diversión a 8
            display_out[2] <= 1'b1; // Cara feliz
            btn_press_count <= 2'b00; // Reiniciar contador de botones
            test_mode <= 1'b0; // Salir del modo de prueba
        end
    end

    // Manejo de la activación del modo test mediante el botón dedicado
    always @(posedge clk) begin
        if (btn_test) begin // 5 segundos en binario es 101
            test_mode <= 1'b1; // Activar modo de prueba
            btn_press_count <= 2'b00; // Reiniciar contador de botones
        end
    end

    // Manejo de los botones en modo normal o test, con niveles separados
    always @(posedge clk) begin
        if (test_mode) begin
            // Modo test: Solo permitir niveles 1 o 10
            if (btn_salud) begin
                display_out[1:0] <= 2'b00; // Mostrar Salud
                if (nivel_salud == 'd8 && display_out == 'b100) begin
                    nivel_salud = 4'b0001;
                end
                if (display_out == 3'b00 && nivel_salud == 'd1) begin
                    nivel_salud = 4'b1010;
                end
            end
            if (btn_energia) begin
                display_out[1:0] <= 2'b01; // Mostrar Energía
                if (btn_press_count == 2'b01) begin
                    nivel_energia <= (nivel_energia == 4'b0001) ? 4'b1010 : 4'b0001; // Alternar entre 1 y 10
                end
                btn_press_count <= btn_press_count + 1;
            end
            if (btn_hambre) begin
                display_out[1:0] <= 2'b10; // Mostrar Hambre
                if (btn_press_count == 2'b01) begin
                    nivel_hambre <= (nivel_hambre == 4'b0001) ? 4'b1010 : 4'b0001; // Alternar entre 1 y 10
                end
                btn_press_count <= btn_press_count + 1;
            end
            if (btn_diversion) begin
                display_out[1:0] <= 2'b11; // Mostrar Diversión
                if (btn_press_count == 2'b01) begin
                    nivel_diversion <= (nivel_diversion == 4'b0001) ? 4'b1010 : 4'b0001; // Alternar entre 1 y 10
                end
                btn_press_count <= btn_press_count + 1;
            end
        end else begin
            // Modo normal: Incrementar el nivel del estado correspondiente, con límite de 10
            if (btn_salud) begin
                display_out[1:0] <= 2'b00; // Mostrar Salud
                if (nivel_salud < 4'b1010 && display_out == 3'b100) begin
                    nivel_salud <= nivel_salud + 1; // Aumentar nivel Salud
                    btn_press_count <= btn_press_count - 1; 
                end
            end
            if (btn_energia) begin
                display_out[1:0] <= 2'b01; // Mostrar Energía
                btn_press_count <= btn_press_count + 1;
                if (nivel_energia < 4'b1010 && display_out == 3'b101) begin
                    nivel_energia <= nivel_energia + 1; // Aumentar nivel Energía
                    btn_press_count <= btn_press_count - 1;
                end
            end
            if (btn_hambre) begin
                display_out[1:0] <= 2'b10; // Mostrar Hambre
                btn_press_count <= btn_press_count + 1;
                if (nivel_hambre < 4'b1010 && display_out == 3'b110) begin
                    nivel_hambre <= nivel_hambre + 1; // Aumentar nivel Hambre
                    btn_press_count <= btn_press_count - 1;
                end
            end
            if (btn_diversion) begin
                display_out[1:0] <= 2'b11; // Mostrar Diversión
                btn_press_count <= btn_press_count + 1;
                if (nivel_diversion < 4'b1010 && display_out == 3'b111) begin
                    nivel_diversion <= nivel_diversion + 1; // Aumentar nivel Diversión
                    btn_press_count <= btn_press_count - 1;
                end
            end
        end
    end

    // Manejo del decremento de los niveles en modo normal, con niveles separados
    always @(posedge clk) begin
        if (!test_mode) begin
            if (timer_salud == 120) begin
                nivel_salud <= nivel_salud - 1;
                timer_salud <= 0;
            end else timer_salud <= timer_salud + 1;

            if (timer_energia == 100) begin
                nivel_energia <= nivel_energia - 1;
                timer_energia <= 0;
            end else timer_energia <= timer_energia + 1;

            if (timer_hambre == 70) begin
                nivel_hambre <= nivel_hambre - 1;
                timer_hambre <= 0;
            end else timer_hambre <= timer_hambre + 1;

            if (timer_diversion == 50) begin
                nivel_diversion <= nivel_diversion - 1;
                timer_diversion <= 0;
            end else timer_diversion <= timer_diversion + 1;
        end
    end

    // Actualizar cara feliz/triste basado en el nivel del estado actual
    always @(posedge clk) begin
        case (display_out[1:0])
            2'b00: display_out[2] <= (nivel_salud >= 4'd5) ? 1'b1 : 1'b0; // Salud
            2'b01: display_out[2] <= (nivel_energia >= 4'd5) ? 1'b1 : 1'b0; // Energía
            2'b10: display_out[2] <= (nivel_hambre >= 4'd5) ? 1'b1 : 1'b0; // Hambre
            2'b11: display_out[2] <= (nivel_diversion >= 4'd5) ? 1'b1 : 1'b0; // Diversión
        endcase
    end

    // Control de la regleta de 7 segmentos para mostrar el nivel actual del estado seleccionado
    always @(posedge clk) begin
        case (display_out[1:0])
            2'b00: seg_display <= get_seg_display(nivel_salud);   // Mostrar nivel de Salud
            2'b01: seg_display <= get_seg_display(nivel_energia); // Mostrar nivel de Energía
            2'b10: seg_display <= get_seg_display(nivel_hambre);  // Mostrar nivel de Hambre
            2'b11: seg_display <= get_seg_display(nivel_diversion); // Mostrar nivel de Diversión
        endcase
    end

    // Función para convertir el nivel en el formato de 7 segmentos
    function [6:0] get_seg_display;
        input [3:0] level;
        case (level)
            4'b0000: get_seg_display = 7'b0111111; // 0
            4'b0001: get_seg_display = 7'b0000110; // 1
            4'b0010: get_seg_display = 7'b1011011; // 2
            4'b0011: get_seg_display = 7'b1001111; // 3
            4'b0100: get_seg_display = 7'b1100110; // 4
            4'b0101: get_seg_display = 7'b1101101; // 5
            4'b0110: get_seg_display = 7'b1111101; // 6
            4'b0111: get_seg_display = 7'b0000111; // 7
            4'b1000: get_seg_display = 7'b1111111; // 8
            4'b1001: get_seg_display = 7'b1101111; // 9
            4'b1010: get_seg_display = 7'b1110111; // A (utilizado para representar 10)
            default: get_seg_display = 7'b0000000; // Apagar todos los segmentos
        endcase
    endfunction

endmodule


