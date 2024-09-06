module TopBrain (
    // Comunes
    input clk,
    input rst,
    // MPU6050
    inout SDA,
    inout SCL,
    output LEDX,
    output LEDSIGN,
    //Ultrasonido
    input echo,
    output trig,
    output led1,
    // Botones
    input btn_heal,
    input btn_ali,
    input btn_RST,
    input btn_TST
);

    //Conexiones internas
    wire btn_salud;
    wire btn_hambre;
    wire btn_reset;
    wire btn_test;
    wire btn_energia; //Arreglar problemas con MPU6050
    wire ledsign;
    
    wire sens_ult;
    wire [19:0] s0;

    //output reg [2:0] display_out,
    //output reg [6:0] seg_display

    topBtn U_topBtn (
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
    
    top U_top (
        .clk(clk),
        .echo(echo),
        .trig(trig),
        .sens_ult(sens_ult),
        .led1(led1),
        .s0(s0)
        );

    // Instanciar Top demo_mpu6050
    DEMO_MPU6050 U_DEMO_MPU6050 (
        .MCLK(clk),
        .RESET(rst),
        .SDA(SDA),
        .SCL(SCL),
        .LEDX(LEDX),
        .LEDSIGN(LEDSIGN)
    );

    tamagotchi_fsm U_tamagotchi_fsm (
        .btn_salud(btn_salud),
        .btn_energia(LEDX), //Arreglaaaar
        .ledsign(LEDSIGN),
        .btn_hambre(btn_hambre),
        .btn_diversion(sens_ult),
        .btn_reset(btn_reset),
        .btn_test(btn_test),
        .clk(clk)
    );

   
endmodule
