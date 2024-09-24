module DEMO_MPU6050 (
    input wire MCLK,
    input wire RESET,
    inout wire SDA,
    inout wire SCL,
    output wire LEDSIGN
);

    // Señales internas
    wire TIC;
    wire SRST;
    wire [7:0] DOUT;
    wire RD;
    wire WE;
    wire QUEUED;
    wire NACK;
    wire STOP;
    wire DATA_VALID;
    wire [7:0] DIN;
    wire [3:0] ADR;
    wire [7:0] DATA;
    wire LOAD;
    wire COMPLETED;
    wire RESCAN;
    wire [2:0] STATUS;
    wire SCL_IN;
    wire SCL_OUT;
    wire SDA_IN;
    wire SDA_OUT;
    reg [7:0] counter = 0;
    wire nRST;

    // Registros de salida
    reg [7:0] XREG;
    assign nRST = RESET;

    // Se instancia el módulo MPU6050 (sensor)
    MPU6050 I_MPU6050_0 (
        .MCLK(MCLK),
        .nRST(nRST),
        .TIC(TIC),
        .SRST(SRST),
        .DOUT(DIN),
        .RD(RD),
        .WE(WE),
        .QUEUED(QUEUED),
        .NACK(NACK),
        .STOP(STOP),
        .DATA_VALID(DATA_VALID),
        .DIN(DOUT),
        .ADR(ADR),
        .DATA(DATA),
        .LOAD(LOAD),
        .COMPLETED(COMPLETED),
        .RESCAN(RESCAN)
    );

    // Se instancia el módulo maestro I2C
    I2CMASTER #(.DEVICE(8'h68)) I_I2CMASTER_0 (
        .MCLK(MCLK),
        .nRST(nRST),
        .SRST(SRST),
        .TIC(TIC),
        .DIN(DIN),
        .DOUT(DOUT),
        .RD(RD),
        .WE(WE),
        .NACK(NACK),
        .QUEUED(QUEUED),
        .DATA_VALID(DATA_VALID),
        .STOP(STOP),
        .STATUS(STATUS),
        .SCL_IN(SCL_IN),
        .SCL_OUT(SCL_OUT),
        .SDA_IN(SDA_IN),
        .SDA_OUT(SDA_OUT)
    );

    // Se instancia el módulo comparador
    COMPARE I_COMPARE_0 (
        .MCLK(MCLK),
        .nRST(nRST),
        .TIC(TIC),
        .COMPLETED(COMPLETED),
        .RESCAN(RESCAN),
        .XREG(XREG),
        .SIGN(LEDSIGN)
    );

    // Genera la señal TIC
    assign TIC = counter[7] & counter[5]; //Genera la señal TIC cuando las posiciones 7 y 5 del contador están en alto

    // Proceso del contador, incrementa cada ciclo de reloj
    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin
            counter <= 8'b0; //Reinicia el contador di nRST está bajo
        end else if (TIC) begin
            counter <= 8'b0; //Reinicia el contador cuando TIC está activo
        end else begin
            counter <= counter + 1; //Incrementa el contador en cada ciclo de reloj
        end
    end

    // Proceso de registro para captura de datos
    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin
            XREG <= 8'b0; //Reinicia el registro XREG si NRST está bajo
        end else if (TIC && LOAD) begin
            case (ADR)
                4'h0: XREG <= DATA; //Carga los datos de XREG si la dirección es 0 y LOAD está activo
            endcase
        end
    end

    // Configuración de salida del bus I2C
    assign SCL = (SCL_OUT) ? 1'bz : 1'b0;  // Controla la línea SCL, la libera si SCL_OUT está activo
    assign SCL_IN = SCL;                   // Asigna el estado de la línea SCL a SCL_IN
    assign SDA = (SDA_OUT) ? 1'bz : 1'b0;  // Controla la línea SDA, la libera si SDA_OUT está activo
    assign SDA_IN = SDA;                   // Asigna el estado de la línea SDA a SDA_IN

endmodule
