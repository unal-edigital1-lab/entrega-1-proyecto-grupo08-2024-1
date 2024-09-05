`timescale 1ns / 1ps

module btnAntirebote_tb;

    // Parámetros
    parameter COUNT_BOT = 50000;



    // Declara las señales de entrada y salida para el módulo btnAntirebote
    
    reg clk;
    reg boton_in;
    wire boton_out;

    // Crea una instancia del módulo btnAntirebote
    btnAntirebote #(50000) uut (
        
        .clk(clk),
        .boton_in(boton_in),
        .boton_out(boton_out)
    );

    // Genera una señal de reloj
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // Test sequence
    initial begin
        // Inicializa las señales
        
        boton_in = 0;

        // Espera 50000 ns
        #COUNT_BOT;

        #20 boton_in = 1;

        #COUNT_BOT;
        
        #20 boton_in = 0;
        #COUNT_BOT;

        

        // Prueba el botón
        #20 boton_in = 1;
        #COUNT_BOT;
        #20 boton_in = 0;
        #COUNT_BOT;

        #20 boton_in = 1;
        #(COUNT_BOT/2);
        #20 boton_in = 0;
        #COUNT_BOT;

        // Finaliza la simulación
        #20 $finish;
    end

    initial begin
        $dumpfile("btnAntirebote_tb.vcd");
        $dumpvars(0, btnAntirebote_tb);
        
    end

endmodule