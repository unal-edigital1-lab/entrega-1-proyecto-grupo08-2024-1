`timescale 1ns / 1ps

module top_tb;

    
    reg clk;
    reg echo;
    wire trig;
    wire sens_ult;
    wire led;
    

    
    top uut (
        .clk(clk),
        .echo(echo),
        .trig(trig),
        .sens_ult(sens_ult),
        .led(led)
    );

    
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    
    initial begin
        // Inicializa las señales
        echo = 0;

        // Espera 10 us del trig
        #10000;

        // Espera 25 us de los pulsos enviados por el ultrasonido
        #25000;

        // Activa echo
        echo = 1;
        #50000;

        // Desactiva echo
        echo = 0;
        // Espera 10 us del trig
        #10000;

        // Espera 25 us de los pulsos enviados por el ultrasonido
        #25000;


        // Activa echo de nuevo
        echo = 1;
        #60000;

        echo = 0;
        // Espera 10 us del trig
        #10000;

        // Espera 25 us de los pulsos enviados por el ultrasonido
        #25000;

        echo = 1;
        #200000;

        echo = 0;
        // Espera 10 us del trig
        #10000;

        // Espera 25 us de los pulsos enviados por el ultrasonido
        #25000;

        echo = 1;
        #300000;

        echo = 0;
        #50000;

        echo = 1;
        #59000;

        echo = 0;
        // Espera 10 us del trig
        #10000;
        echo = 1;
        #59000;

        echo = 0;
        // Espera 10 us del trig
        #10000;

        echo = 1;
        #59000;

        echo = 0;
        // Espera 10 us del trig
        #10000;

        echo = 1;
        #59000;

        echo = 0;
        // Espera 10 us del trig
        #10000;
        echo = 1;
        #59000;

        echo = 0;
        // Espera 10 us del trig
        #1000000;
    





        // Finaliza la simulación
        $finish;
    end

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
    end

endmodule