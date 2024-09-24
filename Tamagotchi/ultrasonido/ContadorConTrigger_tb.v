`timescale 1ns / 1ps

module ContadorConTrigger_tb; //Moudlo para probar Trigger

    // Declara las señales de entrada y salida para el módulo ContadorConTrigger
    reg clk;
    wire trigger;

    // Crea una instancia del módulo ContadorConTrigger
    ContadorConTrigger uut (
        .clk(clk),
        .trig(trig)
    );

    // Genera una señal de reloj
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Espera 100 ns
        #100;

        // Espera durante 60000 ciclos de reloj
        #50000;

        // Finaliza la simulación
        #100 $finish;
    end

    initial begin
        $dumpfile("ContadorConTrigger_tb.vcd");
        $dumpvars(0, ContadorConTrigger_tb);
        
    end

endmodule
