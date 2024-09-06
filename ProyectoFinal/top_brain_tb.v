`include "mpu6050/mpu6050.v"
`include "mpu6050/i2cmaster.v"
`include "mpu6050/demo_mpu6050.v"
`include "mpu6050/compare.v"
`include "JJDiaz/FSM/FSM.v"
`include "ultrasonido/top.v"
`include "ultrasonido/ControlLed.v"
`include "ultrasonido/ContadorConTrigger.v"
`include "ultrasonido/ContadorConEcho.v"
`include "Botones/btn/btnAntirebote.v"
`include "Botones/btn/btnRT.v"
`include "Botones/btn/topBtn.v"
`include "TopBrain.v"

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
        .btn_TST(btn_TST)
    );

initial begin
        rst = 0;
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
        #60000 $finish;
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
        #350000;
        // Desactiva echo
        echo = 0;
        // Espera 10 us del trig
        #10000;
        // Espera 25 us de los pulsos enviados por el ultrasonido
        #25000;
        // Activa echo de nuevo
        echo = 1;
        #50000;
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
        #100000;
        echo = 0;
        #50000;
        // Finaliza la simulación
        #100 $finish;
    end


 initial begin

        $dumpfile("top_brain_tb.vcd");
        $dumpvars(-1, UUT);

        //Inicializar variables
        #10000000
        $finish;
    end


endmodule