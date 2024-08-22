module tamagotchi_fsm (
    input wire btn_salud,
    input wire btn_energia,
    input wire btn_hambre,
    input wire btn_diversion,
    input wire reset,
    input wire clk,
    output reg [2:0] display_out
);

    // Definición de estados
    reg [3:0] niveles; // Niveles de cada estado
    reg [7:0] timer_salud, timer_energia, timer_hambre, timer_diversion; // Contadores de tiempo

    // Inicialización de valores
    initial begin
        niveles = 4'b1010; // Todos los niveles en 10
        timer_salud = 0;
        timer_energia = 0;
        timer_hambre = 0;
        timer_diversion = 0;
        display_out = 3'b000; // Mostrar Salud y cara feliz por defecto
    end

    // Manejo del reset
    always @(posedge reset) begin
        niveles <= 4'b1010; // Reiniciar todos los niveles a 10
        display_out[2] <= 1'b1; // Cara feliz
    end

    // Manejo de los botones
    always @(posedge clk) begin
        if (btn_salud) begin
            display_out[1:0] <= 2'b00; // Mostrar Salud
            if (display_out[2:0] == 2'b00) begin
                niveles[3:2] <= niveles[3:2] + 1; // Aumentar nivel Salud
            end
        end
        if (btn_energia) begin
            display_out[1:0] <= 2'b01; // Mostrar Energía
            if (display_out[1:0] == 2'b01) begin
                niveles[3:2] <= niveles[3:2] + 1; // Aumentar nivel Energía
            end
        end
        if (btn_hambre) begin
            display_out[1:0] <= 2'b10; // Mostrar Hambre
            if (display_out[1:0] == 2'b10) begin
                niveles[3:2] <= niveles[3:2] + 1; // Aumentar nivel Hambre
            end
        end
        if (btn_diversion) begin
            display_out[1:0] <= 2'b11; // Mostrar Diversión
            if (display_out[1:0] == 2'b11) begin
                niveles[3:2] <= niveles[3:2] + 1; // Aumentar nivel Diversión
            end
        end
    end

    // Manejo del decremento de los niveles
    always @(posedge clk) begin
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

    // Actualizar cara feliz/triste
    always @(posedge clk) begin
        if (niveles[3:2] == 4'b0000) begin
            display_out[2] <= 1'b0; // Cara triste
        end else begin
            display_out[2] <= 1'b1; // Cara feliz
        end
    end

endmodule
