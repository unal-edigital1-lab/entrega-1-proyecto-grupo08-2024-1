`timescale 1ns / 1ps

module topBtn_tb;

    
    reg clk;
    reg btn_heal;
    reg btn_ali;
    reg btn_RST;
    reg btn_TST;
    wire btn_salud;
    wire btn_hambre;
    wire btn_reset;
    wire btn_test;

    
    topBtn uut (
        .clk(clk),
        .btn_heal(btn_heal),
        .btn_ali(btn_ali),
        .btn_RST(btn_RST),
        .btn_TST(btn_TST),
        .btn_salud(btn_salud),
        .btn_hambre(btn_hambre),
        .btn_reset(btn_reset),
        .btn_test(btn_test)
    );

    
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    
    initial begin
        // Inicializa las señales
        btn_heal = 0;
        btn_ali = 0;
        btn_RST = 0;
        btn_TST = 0;

        // Espera 100 ns
        #100;

        // Activa btn_RST
        btn_RST = 1;
        #200;

        // Desactiva btn_RST
        btn_RST = 0;
        #200;

        btn_RST = 1;
        #60000

        btn_RST = 0;
        #200;


        // Activa btn_TST
        btn_TST = 1;
        #200;

        // Desactiva btn_TST
        btn_TST = 0;
        #200;

        btn_TST = 1;
        #60000

        btn_TST = 0;
        #200;

        // Activa btn_heal durante 60000 ciclos de reloj
        btn_heal = 1;
        #60000;

        // Desactiva btn_heal
        btn_heal = 0;
        #200;

        // Activa btn_ali durante 60000 ciclos de reloj
        btn_ali = 1;
        #60000;

        // Desactiva btn_ali
        btn_ali = 0;
        #200;

        

        // Finaliza la simulación
        #60000 $finish;
    end

    initial begin
        $dumpfile("topBtn_tb.vcd");
        $dumpvars(0, topBtn_tb);
        
    end

endmodule