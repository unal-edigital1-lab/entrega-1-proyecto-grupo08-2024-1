`timescale 1ns / 1ps

module ContadorConEcho_tb;

    // Declara las señales de entrada y salida para el módulo ContadorConEcho
    reg clk;
    reg echo;
    wire [31:0] echo_duration;

    // Crea una instancia del módulo ContadorConEcho
    ContadorConEcho uut (
        .clk(clk),
        .echo(echo),
        .echo_duration(echo_duration)
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
        #50000;

        // Desactiva echo
        echo = 0;
        #10000;

        echo = 1;
        #100000;

        // Desactiva echo
        echo = 0;
        #10000;

        echo = 1;
        #20000;

        // Desactiva echo
        echo = 0;
        #10000;

        // Finaliza la simulación
        #100 $finish;
    end

    initial begin
        $dumpfile("ContadorConEcho_tb.vcd");
        $dumpvars(0, ContadorConEcho_tb);
        
    end

endmodule
