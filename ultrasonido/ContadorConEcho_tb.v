`timescale 1ns / 1ps

module ContadorConEcho_tb;

    // Declara las señales de entrada y salida para el módulo ContadorConEcho
    reg clk;
    reg echo;
    wire [19:0] contador2;

    // Crea una instancia del módulo ContadorConEcho
    ContadorConEcho uut (
        .clk(clk),
        .echo(echo),
        .contador2(contador2)
    );

    // Genera una señal de reloj
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Inicializa las señales
        echo = 0;

        // Espera 100 ns
        #100;

        // Activa echo durante 60000 ciclos de reloj
        echo = 1;
        #600000;

        // Desactiva echo
        echo = 0;
        #200;

        // Finaliza la simulación
        #100 $finish;
    end

    initial begin
        $dumpfile("ContadorConEcho_tb.vcd");
        $dumpvars(0, ContadorConEcho_tb);
        
    end

endmodule
