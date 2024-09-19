`timescale 1ns/1ps

module tamagotchi_tb;

    // Declaración de señales
    reg btn_salud;
    reg btn_energia;
    reg ledsign;
    reg btn_hambre;
    reg btn_diversion;
    reg btn_reset;
    reg btn_test;
    reg clk;
    wire [3:0] display_out;
    wire [6:0] seg_display;

    reg reset;
    wire clk_out;

    // Instancia del módulo tamagotchi_fsm
    tamagotchi_fsm uut (
        .btn_salud(btn_salud),
        .btn_energia(btn_energia),
        .ledsign(ledsign),
        .btn_hambre(btn_hambre),
        .btn_diversion(btn_diversion),
        .btn_reset(btn_reset),
        .btn_test(btn_test),
        .clk(clk),
        .display_out(display_out),
        .seg_display(seg_display),
        .clk_out(clk_out)
    );

    // Generación del reloj
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // Periodo de 10 ns
    end

    // Secuencia de test
    initial begin
        // Inicialización de señales
        btn_salud = 0;
        btn_energia = 0;
        ledsign =0;
        btn_hambre = 0;
        btn_diversion = 0;
        btn_reset = 0;
        btn_test = 0;

        #1000

        // Finalizar simulación
        $finish;
    end

    // Guardar la salida en un archivo .vcd para visualización en GTKWave
    initial begin
        $dumpfile("tamagotchi_tb.vcd");
        $dumpvars(0, tamagotchi_tb);
    end

endmodule