`timescale 1ns / 1ps

module ControlLed_tb;

    // Declara las señales de entrada y salida para el módulo ControlLed
    reg clk;
    reg [31:0] echo_duration;
    wire aux;

    // Crea una instancia del módulo ControlLed
    ControlLed UUT (
        .clk(clk),
        .echo_duration(echo_duration),
        .aux(aux)
    );

    // Genera una señal de reloj
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Inicializa las señales
        echo_duration = 0;

        // Espera 100 ns
        #10;

        echo_duration = 14'd5000;
        #20

        echo_duration = 0;
        #10

        echo_duration = 14'd2000;
        #20

        echo_duration = 0;
        #10

        echo_duration = 14'd16000;
        #20

        echo_duration = 0;
        #10

        echo_duration = 14'd10000;
        #20

        echo_duration = 0;


        
        // Finaliza la simulación
        #10 $finish;
    end

    initial begin
        $dumpfile("ControlLed_tb.vcd");
        $dumpvars(0, ControlLed_tb);
        
    end

endmodule