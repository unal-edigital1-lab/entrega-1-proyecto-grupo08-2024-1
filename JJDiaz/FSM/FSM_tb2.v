`timescale 1ns/1ps

module tamagotchi_tb;

    // Declaración de señales
    reg btn_salud;
    reg btn_energia;
    reg btn_hambre;
    reg btn_diversion;
    reg btn_reset;
    reg btn_test;
    reg clk;
    reg [2:0] count_reset;
    reg [2:0] count_test;
    wire [2:0] display_out;
    wire [6:0] seg_display;

    // Instancia del módulo tamagotchi_fsm
    tamagotchi_fsm uut (
        .btn_salud(btn_salud),
        .btn_energia(btn_energia),
        .btn_hambre(btn_hambre),
        .btn_diversion(btn_diversion),
        .btn_reset(btn_reset),
        .btn_test(btn_test),
        .clk(clk),
        .count_reset(count_reset),
        .count_test(count_test),
        .display_out(display_out),
        .seg_display(seg_display)
    );

    // Generación del reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Periodo de 10 ns
    end

    // Secuencia de test
    initial begin
        // Inicialización de señales
        btn_salud = 0;
        btn_energia = 0;
        btn_hambre = 0;
        btn_diversion = 0;
        btn_reset = 0;
        btn_test = 0;
        count_reset = 3'b000;
        count_test = 3'b000;

        // Esperar para estabilizar
        #20;

        //Inicio de modo test
        //btn_test = 1;
        #10 btn_test = 0;
        #20

        // Simulación del comportamiento: Primer botón Salud
        // Presionar botón de salud por primera vez
        btn_salud = 1;
        #10 btn_salud = 0;  // Liberar el botón
        #20;

        // Verificar cambio en display_out y seg_display
        $display("Salud - Primera presion: display_out = %b, seg_display = %b", display_out, seg_display);

        // Presionar botón de salud por segunda vez
        btn_salud = 1;
        #10 btn_salud = 0;  // Liberar el botón
        #20;

        // Verificar cambio en display_out y aumento en seg_display
        $display("Salud - Segunda presion: display_out = %b, seg_display = %b", display_out, seg_display);

        // Simulación del comportamiento: Botón Energía
        // Presionar botón de energía por primera vez
        btn_salud = 1;
        #10 btn_salud = 0;  // Liberar el botón
        #20;

        // Verificar cambio en display_out y seg_display
        $display("Energia - Primera presion: display_out = %b, seg_display = %b", display_out, seg_display);

        // Presionar botón de energía por segunda vez
        btn_salud = 1;
        #10 btn_salud = 0;  // Liberar el botón
        #20;

        // Verificar cambio en display_out y aumento en seg_display
        $display("Energia - Segunda presion: display_out = %b, seg_display = %b", display_out, seg_display);

        // Simulación del comportamiento: Primer botón Hambre
        // Presionar botón de hambre por primera vez
        btn_salud = 1;
        #10 btn_salud = 0;  // Liberar el botón
        #20;

        // Verificar cambio en display_out y seg_display
        $display("Hambre - Primera presion: display_out = %b, seg_display = %b", display_out, seg_display);

        // Presionar botón de hambre por segunda vez
        btn_salud = 1;
        #10 btn_salud = 0;  // Liberar el botón
        #20;

        // Verificar cambio en display_out y aumento en seg_display
        $display("Hambre - Segunda presion: display_out = %b, seg_display = %b", display_out, seg_display);

        // Simulación del comportamiento: Botón Diversion
        // Presionar botón de diversion por primera vez
        btn_diversion = 1;
        #10 btn_diversion = 0;  // Liberar el botón
        #20;

        // Verificar cambio en display_out y seg_display
        $display("Diversion - Primera presion: display_out = %b, seg_display = %b", display_out, seg_display);

        // Presionar botón de diversion por segunda vez
        btn_diversion = 1;
        #10 btn_diversion = 0;  // Liberar el botón
        #20;

        // Verificar cambio en display_out y aumento en seg_display
        $display("Diversion - Segunda presion: display_out = %b, seg_display = %b", display_out, seg_display);

        // Simulación del comportamiento: Botón Energía
        // Presionar botón de energía por primera vez
        btn_energia = 1;
        #10 btn_energia = 0;  // Liberar el botón
        #20;

        // Verificar cambio en display_out y seg_display
        $display("Energia - Primera presion: display_out = %b, seg_display = %b", display_out, seg_display);

        // Presionar botón de energía por segunda vez
        btn_energia = 1;
        #10 btn_energia = 0;  // Liberar el botón
        #20;

        // Verificar cambio en display_out y aumento en seg_display
        $display("Energia - Segunda presion: display_out = %b, seg_display = %b", display_out, seg_display);

        btn_reset = 1;
        #10 btn_reset = 0;
        #20

        // Finalizar simulación
        $finish;
    end

    // Guardar la salida en un archivo .vcd para visualización en GTKWave
    initial begin
        $dumpfile("tamagotchi_tb.vcd");
        $dumpvars(0, tamagotchi_tb);
    end

endmodule
