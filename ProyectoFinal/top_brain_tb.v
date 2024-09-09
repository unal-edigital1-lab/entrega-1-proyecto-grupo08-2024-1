`include "ProyectoFinal/TopBrain.v"
`include "ProyectoFinal/FSM.v"
`include "ProyectoFinal/bucleEspera.v"
`include "ProyectoFinal/btnAntirebote.v"
`include "ProyectoFinal/btnRT.v"
`include "ProyectoFinal/topBtn.v"
`include "ProyectoFinal/compare.v"
`include "ProyectoFinal/demo_mpu6050.v"
`include "ProyectoFinal/mpu6050.v"
`include "ProyectoFinal/i2cmaster.v"
`include "ProyectoFinal/top.v"
`include "ProyectoFinal/ControlLed.v"
`include "ProyectoFinal/ContadorConTrigger.v"
`include "ProyectoFinal/ContadorConEcho.v"

`timescale 1ns / 1ps

module top_brain_tb;

    //Inputs son reg / Outputs son wire / Bidireccionales son wire
    reg clk;
    reg rst;
    wire SDA;
    wire SCL;
    wire LEDX;
    wire LEDSIGN;
    reg echo;
    wire trig;
    wire led1;
    reg btn_heal;
    reg btn_ali;
    reg btn_RST;
    reg btn_TST;
    reg ready_i;
    wire rs;
    wire rw;
    wire [7:0] data;
    wire enable;
    wire [6:0] seg_display;
    wire an;

    TopBrain UUT (
        .clk(clk),
        .rst(rst),
        .SDA(SDA),
        .SCL(SCL),
        .LEDX(LEDX),
        .LEDSIGN(LEDSIGN),
        .echo(echo),
        .trig(trig),
        .led1(led1),
        .btn_heal(btn_heal),
        .btn_ali(btn_ali),
        .btn_RST(btn_RST),
        .btn_TST(btn_TST),
        .ready_i(ready_i),
        .rs(rs),
        .rw(rw),
        .data(data),
        .enable(enable),
        .seg_display(seg_display),
        .an(an)
    );

initial begin
        rst = 0;
        clk = 0;
        forever #10 clk = ~clk;
    end

initial begin
        // Inicializa las señales
        btn_heal = 0;

        // Espera 100 ns
     
        #100000000
        // Activa btn_heal durante 60000 ciclos de reloj
        btn_heal = 1;
        #100000000;
        // Desactiva btn_heal
        btn_heal = 0;
        #100000000;
        // Activa btn_ali durante 60000 ciclos de reloj
        btn_heal = 1;
        #100000000;
        // Desactiva btn_ali
        btn_heal = 0;
        #100000000 $finish;
    end

 initial begin

        $dumpfile("top_brain_tb.vcd");
        $dumpvars(-1, UUT);

        //Inicializar variables
        //#10000000
        //$finish;
    end


endmodule