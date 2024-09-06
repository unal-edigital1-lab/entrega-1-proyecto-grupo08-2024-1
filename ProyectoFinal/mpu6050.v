// Módulo encargado de configurar las instrucciones para enviar al módulo i2cmaster
module MPU6050 ( 
    input wire MCLK, //Reloj FPGA
    input wire nRST, //Señal Reset
    input wire TIC, //Reloj 
    output reg SRST, //Señal de Reset síncrono
    output reg [7:0] DOUT, //Datos de salida hacia bus i2c
    output reg RD, //Señal de lectura
    output reg WE, //Señal de escritura
    input wire QUEUED, //Señal que indica que la transacción i2c está en la cola
    input wire NACK, //Señal de no reconocimiento del i2c
    input wire STOP, //Señal de parada
    input wire DATA_VALID, //Señal de validación de datos
    input wire [7:0] DIN, //Datos de entrada desde el bus i2c
    output reg [3:0] ADR, //Dirección de registro para el sensor
    output reg [7:0] DATA, //Datos que se están cargando
    output reg LOAD, //Señal que indica la carga de datos
    output reg COMPLETED, //Señal que indica el fin de la operación
    input wire RESCAN //Señal para reiniciar la operación
);

    // Definición de los estados
    parameter S_IDLE = 3'b000, //Estado inicial
              S_PWRMGT0 = 3'b001, //Estado de energía 0
              S_PWRMGT1 = 3'b010, //Estado de energía 1
              S_READ0 = 3'b011, //Estado para iniciar lectura
              S_READ1 = 3'b100, //Estado para continuar lectura
              S_STABLE = 3'b101; //Estado de estabilidad después de completar operación

    // Variable de estado
    reg [2:0] state = 0; 
    reg [3:0] adr_i; //Registro de dirección

    // Máquina de estados
    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin //Reset del sistema, inicialización
            SRST <= 1'b0;
            DOUT <= 8'b0;
            RD <= 1'b0;
            WE <= 1'b0;
            adr_i <= 4'b0;
            LOAD <= 1'b0;
            DATA <= 8'b11111111; //Dato de inicio predefinido
            COMPLETED <= 1'b0;
            state <= S_IDLE;
        end else begin
            //Manejo diferentes estados
            case (state)
                S_IDLE: begin
                    if (TIC) begin
                        SRST <= 1'b0;
                        DOUT <= 8'b0;
                        RD <= 1'b0;
                        WE <= 1'b0;
                        adr_i <= 4'b0;
                        LOAD <= 1'b0;
                        DATA <= 8'b11111111;
                        COMPLETED <= 1'b0;
                        state <= S_PWRMGT0; //Cambia a estado de configuración de energía 
                    end
                end
                S_PWRMGT0: begin
                    if (TIC) begin
                        DOUT <= 8'h6B; //Dirección del registro PWR_MGMT_1
                        WE <= 1'b1; //Habilita escritura
                        RD <= 1'b0;
                        if (QUEUED) begin //Si la transacción está en cola, escribe el dato 0x00 para salir del modo de reposo
                            DOUT <= 8'h00;
                            WE <= 1'b1;
                            RD <= 1'b0;
                            state <= S_PWRMGT1; //Cambia al siguiente estado de gestión de energía
                        end else if (NACK) begin
                            state <= S_IDLE;
                        end
                    end
                end
                S_PWRMGT1: begin
                    if (TIC) begin
                        if (QUEUED) begin //Espera a que la transacción esté en cola y desactiva la escritura
                            DOUT <= 8'h00;
                            WE <= 1'b0;
                            RD <= 1'b0;
                            state <= S_READ0; //Cambia al estado de lectura
                        end else if (NACK) begin
                            state <= S_IDLE;
                        end
                    end
                end
                S_READ0: begin    
                    if (TIC) begin
                        if (STOP) begin
                            //Inicia la lectura de 14 registros incluyendo el del acelerómetro
                            DOUT <= 8'h3B; //Dirección del registro ACCEL_XOUT_H
                            WE <= 1'b1;
                            RD <= 1'b0;
                        end else if (QUEUED) begin //Si la transacción está en cola, prepara la lectura
                            WE <= 1'b0;
                            RD <= 1'b1;
                            adr_i <= 4'b0; //Resetea la dirección interna
                        end else if (DATA_VALID) begin //Si los datos son válidos, carga los datos recibidos
                            LOAD <= 1'b1;
                            DATA <= DIN;
                            state <= S_READ1; //Cambia al siguiente estado de lectura 
                        end else if (NACK) begin
                            state <= S_IDLE; //Si hay un NACK, vuelve al estado IDLE y comienza nuevamente
                        end    
                    end
                end
                S_READ1: begin
                    if (TIC) begin
                        if (DATA_VALID) begin //Si los datos son válidos, sigue cargando los datos
                            LOAD <= 1'b1;
                            DATA <= DIN;
                        end else if (QUEUED) begin
                            adr_i <= adr_i + 1; //Incrementa la dirección y continua leyendo si hay más datos
                            if (adr_i == 4'b1100) begin //Verifica si es el último registro
                                WE <= 1'b0;
                                RD <= 1'b0;
                            end else begin
                                WE <= 1'b0;
                                RD <= 1'b1; //Le envía bit de lectura 
                            end
                        end else if (STOP) begin
                            state <= S_STABLE; //Una vez completada la lectura, pasa al estado estable
                        end else begin
                            LOAD <= 1'b0;
                        end
                    end
                end
                S_STABLE: begin
                    COMPLETED <= 1'b1; //Indica que la operación ha finalizado
                    if (TIC) begin
                        if (RESCAN) begin
                            state <= S_IDLE; //Si se recibe RESCAN, vuelve al estado IDLE y vuelve a comenzar
                        end
                    end
                end
            endcase
        end
    end

// Asignación continua de la dirección al registro interno adr_i
    always @* begin
        ADR = adr_i;
    end

endmodule
