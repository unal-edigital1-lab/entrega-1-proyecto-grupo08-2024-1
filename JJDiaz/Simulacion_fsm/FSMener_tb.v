`timescale 1ns/1ps

module tamagotchi_tb;

    // Declaración de señales
    reg ledsign;
    reg clk;
    wire [3:0] display_out;
    wire [6:0] seg_display;

    wire clk_out;

    // Instancia del módulo tamagotchi_fsm
    tamagotchi_fsm uut (
        .ledsign(ledsign),
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
        // Simulación del comportamiento: Estado Energia
        // Sensor mirando hacia abajo
        ledsign = 0;
        #100;
        /*$display("Loading", display_out, seg_display);
        #100000000;
        $display("Loading", display_out, seg_display);
        #100000000;
        $display("Loading", display_out, seg_display);
        #100000000;
        $display("Loading", display_out, seg_display);
        #100000000;
        $display("Loading", display_out, seg_display);
        #100000000;  
        $display("Loading", display_out, seg_display);
        #100000000;
        $display("Loading", display_out, seg_display);
        #100000000;
        $display("Loading", display_out, seg_display);
        #100000000;
        $display("Loading", display_out, seg_display);
        #100000000; */

        // Finalizar simulación
        $finish;
    end

    // Guardar la salida en un archivo .vcd para visualización en GTKWave
    initial begin
        $dumpfile("tamagotchi_tb.vcd");
        $dumpvars(0, tamagotchi_tb);
    end

endmodule