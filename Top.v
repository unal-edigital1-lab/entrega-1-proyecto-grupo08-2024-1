module Top ();
    wire conexion;

    // Instanciar Modulo1
    DEMO_MPU6050 u_DEMO_MPU6050 (
        .LEDSIGN(conexion)
    );

    // Instanciar Modulo2
    Modulo2 u_modulo2 (
        .entrada2(conexion)
    );
endmodule
