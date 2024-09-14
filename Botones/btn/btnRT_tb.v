`timescale 1ns / 1ps

module btnRT_tb; //Modulo para simular el modulo de botones Reset y Test

    // Declara las señales de entrada y salida para el módulo btnModule
    reg clk;
    reg boton_in;
    wire boton_out;

    // Crea una instancia del módulo btnModule
    btnRT uut (
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
        boton_in = 1;

        // Espera 20000 ns
        #200000;

        // Activa boton_in durante 550.000.000 ns
        boton_in = 0;
        #550000;

        // Desactiva boton_in
        boton_in = 1;
        #200000;

        // Activa boton_in durante 200.000 ns
        boton_in = 0;
        #200000;

        // Desactiva boton_in
        boton_in = 1;
        #200000;

        // Activa boton_in durante 200.000 ns
        boton_in = 0;
        #1000000;

        // Desactiva boton_in
        boton_in = 1;
        #200000;

        // Finaliza la simulación
        #100 $finish;
    end

    initial begin
        $dumpfile("btnRT_tb.vcd");
        $dumpvars(0, btnRT_tb);
        
    end

endmodule