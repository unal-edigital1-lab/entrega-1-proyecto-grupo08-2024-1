`timescale 1ns/1ps

module tamagotchi_tb;

    // Declaración de señales
    reg btn_salud;
    reg btn_energia;
    reg btn_hambre;
    reg btn_diversion;
    reg btn_reset;
    reg btn_test;
    reg clk;
    reg [2:0] count_reset;
    reg [2:0] count_test;
    wire [2:0] display_out;

    // Instancia del módulo tamagotchi_fsm
    tamagotchi_fsm uut (
        .btn_salud(btn_salud),
        .btn_energia(btn_energia),
        .btn_hambre(btn_hambre),
        .btn_diversion(btn_diversion),
        .btn_reset(btn_reset),
        .btn_test(btn_test),
        .clk(clk),
        .count_reset(count_reset),
        .count_test(count_test),
        .display_out(display_out)
    );

    // Generación del reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Periodo de 10 ns
    end

    // Secuencia de test
    initial begin
        // Inicialización de señales
        btn_salud = 0;
        btn_energia = 0;
        btn_hambre = 0;
        btn_diversion = 0;
        btn_reset = 0;
        btn_test = 0;
        count_reset = 3'b000;
        count_test = 3'b000;

        // Esperar para estabilizar
        #20;

        // Simulación del comportamiento en modo normal
        // Presionar botón de salud
        btn_salud = 1;
        #10 btn_salud = 0;  // Liberar el botón
        #20;

        // Presionar botón de energía
        btn_energia = 1;
        #10 btn_energia = 0;  // Liberar el botón
        #20;

        // Presionar botón de hambre
        btn_hambre = 1;
        #10 btn_hambre = 0;  // Liberar el botón
        #20;

        // Presionar botón de diversión
        btn_diversion = 1;
        #10 btn_diversion = 0;  // Liberar el botón
        #20;

        // Finalizar simulación
        $finish;
    end

    // Guardar la salida en un archivo .vcd para visualización en GTKWave
    initial begin
        $dumpfile("tamagotchi_tb.vcd");
        $dumpvars(0, tamagotchi_tb);
    end

endmodule
