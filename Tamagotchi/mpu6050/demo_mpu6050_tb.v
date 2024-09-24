`include "mpu6050/mpu6050.v"
`include "mpu6050/i2cmaster.v"
`include "mpu6050/demo_mpu6050.v"
`include "mpu6050/compare.v"
`timescale 1ns / 1ps

module demo_mpu6050_tb;

    // Inputs son reg / Outputs son wire / Bidireccionales son wire
    reg MCLK;
    reg RESET;
    wire SDA;
    wire SCL;
    wire LEDX;
    wire LEDSIGN;

    DEMO_MPU6050 UUT (
        .MCLK(MCLK),
        .RESET(RESET),
        .SDA(SDA),
        .SCL(SCLA),
        .LEDX(LEDX),
        .LEDSIGN(LEDSIGN)
    );


    initial begin // Simula reloj
        MCLK = 0;
        forever begin
            MCLK = #10 ~MCLK;
        end
    end

    initial begin

        $dumpfile("demo_mpu6050_tb.vcd");
        $dumpvars(-1, UUT);

        // Inicializar variables
        MCLK = 0;
        RESET = 1;
        #1000000
        $finish;
    end

endmodule