`timescale 1ns / 1ps

module ControlLed_tb;

    // Declara las señales de entrada y salida para el módulo ControlLed
    reg clk;
    reg [19:0] contador2;
    wire sens_ult;

    // Crea una instancia del módulo ControlLed
    ControlLed UUT (
        .clk(clk),
        .contador2(contador2),
        .sens_ult(sens_ult)
    );

    // Genera una señal de reloj
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Inicializa las señales
        contador2 = 0;

        // Espera 100 ns
        #100;

        // Incrementa contador2 durante 60000 ciclos de reloj
        for (contador2 = 0; contador2 < 60000; contador2 = contador2 + 1) begin
            #10;
        end

        // Finaliza la simulación
        #100 $finish;
    end

    initial begin
        $dumpfile("ControlLed_tb.vcd");
        $dumpvars(0, ControlLed_tb);
        
    end

endmodule