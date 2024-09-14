`timescale 1ns / 1ps

module Salida_tb;

    reg clk;
    reg aux;
    wire led;
    wire sens_ult;

    // Instancia del módulo Salida
    Salida uut (
        .clk(clk), 
        .aux(aux), 
        .led(led), 
        .sens_ult(sens_ult)
    );

    // Generador de reloj
    always begin
        #10 clk = ~clk;
    end

    // Estímulo de prueba
    initial begin
        // Inicialización
        clk = 0;
        aux = 0;

        // Espera un ciclo de reloj
        #100000;

        // Prueba con aux = 1
        aux = 1;
        #20;

        // Prueba con aux = 0
        aux = 0;
        #150000;

        aux = 1;
        #20;

        aux = 0;
        #250000;

        aux = 1;
        #20;

        aux = 0;
        #100000;

        aux = 1;
        #20;

        aux = 0;
        #100000;

        aux = 1;
        #20;

        aux = 0;
        #100000;

        // Finaliza la simulación
        $finish;
    end

    initial begin
        $dumpfile("Salida_tb.vcd");
        $dumpvars(0, Salida_tb);
        
    end

endmodule