module I2CMASTER (
    input wire MCLK,               // Reloj maestro.
    input wire nRST,               // Reinicio asíncrono (activo bajo).
    input wire SRST,               // Reinicio sincrónico.
    input wire TIC,                // Reloj para la tasa de I2C (tres veces la tasa de bits).
    input wire [7:0] DIN,          // Datos a enviar.
    output reg [7:0] DOUT,         // Datos recibidos.
    input wire RD,                 // Comando de lectura.
    input wire WE,                 // Comando de escritura.
    output reg NACK,               // Señal de no reconocimiento del esclavo.
    output reg QUEUED,             // Indica que una operación (lectura o escritura) está en cola.
    output reg DATA_VALID,         // Indica que hay datos nuevos disponibles en DOUT.
    output reg STOP,               // Señal de parada.
    output reg [2:0] STATUS,       // Estado de la máquina de estados.
    input wire SCL_IN,             // Señal de reloj I2C de entrada.
    output reg SCL_OUT,            // Señal de reloj I2C de salida.
    input wire SDA_IN,             // Señal de datos I2C de entrada.
    output reg SDA_OUT             // Señal de datos I2C de salida.
);

parameter DEVICE = 8'h68; // Dirección del dispositivo I2C.

    // Definición de los estados.
    parameter S_IDLE = 5'b00000,
              S_START = 5'b00001,
              S_SENDBIT = 5'b00010,
              S_WESCLUP = 5'b00011,
              S_WESCLDOWN = 5'b00100,
              S_CHECKACK = 5'b00101,
              S_CHECKACKUP = 5'b00110,
              S_CHECKACKDOWN = 5'b00111,
              S_WRITE = 5'b01000,
              S_PRESTOP = 5'b01001,
              S_STOP = 5'b01010,
              S_READ = 5'b01011,
              S_RECVBIT = 5'b01100,
              S_RDSCLUP = 5'b01101,
              S_RDSCLDOWN = 5'b01110,
              S_SENDACK = 5'b01111,
              S_SENDACKUP = 5'b10000,
              S_SENDACKDOWN = 5'b10001,
              S_RESTART = 5'b10010;

    // Variables de estado.
    reg [4:0] state, next_state;   // Estado actual y siguiente de la máquina de estados.
    reg [3:0] counter, next_counter; // Contador para bits enviados/recibidos.
    reg [7:0] shift;              // Registro de desplazamiento para datos.
    reg nackdet;                  // Detección de no reconocimiento.
    reg sda_in_q, sda_in_qq;      // Registros para la sincronización de SDA_IN.

    always @(*) begin
        next_counter = counter + 1; // Incrementa el contador.
    end

    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin
            sda_in_q <= 1'b1;
            sda_in_qq <= 1'b1;
        end else if (MCLK) begin
            sda_in_q <= SDA_IN;    // Almacena el valor actual de SDA_IN.
            sda_in_qq <= sda_in_q; // Desfase de un ciclo de reloj.
        end
    end

    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin
            STATUS <= 3'b000;
            state <= S_IDLE;      // Estado inicial en IDLE.
            SCL_OUT <= 1'b1;      // Configura SCL en alto.
            SDA_OUT <= 1'b1;      // Configura SDA en alto.
            NACK <= 1'b0;         // Reinicia la señal de no reconocimiento.
            QUEUED <= 1'b0;       // Reinicia la señal de operación en cola.
            DATA_VALID <= 1'b0;   // Reinicia la señal de datos válidos.
            DOUT <= 8'b0;         // Reinicia la salida de datos.
            counter <= 4'b0;      // Reinicia el contador.
            nackdet <= 1'b0;      // Reinicia la detección de no reconocimiento.
            shift <= 8'b0;        // Reinicia el registro de desplazamiento.
            STOP <= 1'b0;         // Reinicia la señal de parada.
        end else if (MCLK) begin
            if (SRST) begin
                state <= S_IDLE;  // Reinicia el estado a IDLE si SRST está activo.
            end else begin
                case (state)
                    S_IDLE: begin
                        STATUS <= 3'b000;
                        SCL_OUT <= 1'b1;
                        SDA_OUT <= 1'b1;
                        NACK <= 1'b0;
                        QUEUED <= 1'b0;
                        DATA_VALID <= 1'b0;
                        DOUT <= 8'h01;
                        counter <= 4'b0;
                        STOP <= 1'b0;
                        if (TIC) begin
                            if (WE || RD) begin
                                state <= S_START; // Cambia al estado de inicio si hay comando de escritura o lectura.
                            end
                        end
                    end
                    S_START: begin
                        STATUS <= 3'b001;
                        SCL_OUT <= 1'b1;
                        SDA_OUT <= 1'b0; // Inicia la señal de inicio.
                        NACK <= 1'b0;
                        QUEUED <= 1'b0;
                        STOP <= 1'b0;
                        DATA_VALID <= 1'b0;
                        if (TIC) begin
                            SCL_OUT <= 1'b0;
                            counter <= 4'b0000;
                            shift[7:1] <= DEVICE[6:0];
                            if (WE) begin
                                shift[0] <= 1'b0; // Configura el bit de escritura.
                                next_state <= S_WRITE;
                            end else begin
                                shift[0] <= 1'b1; // Configura el bit de lectura.
                                next_state <= S_READ;
                            end
                            state <= S_SENDBIT; // Cambia al estado de envío de bits.
                        end
                    end
                    S_SENDBIT: begin
                        if (TIC) begin
                            STATUS <= 3'b010;
                            SCL_OUT <= 1'b0;
                            SDA_OUT <= shift[7];
                            shift[7:1] <= shift[6:0];
                            counter <= next_counter; 
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            state <= S_WESCLUP; // Cambia al estado de esperar subida de SCL.
                        end
                    end
                    S_WESCLUP: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b1; // Sube SCL.
                            state <= S_WESCLDOWN; // Cambia al estado de esperar bajada de SCL.
                        end
                    end
                    S_WESCLDOWN: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0; // Baja SCL.
                            if (counter[3]) begin
                                state <= S_CHECKACK; // Verifica el reconocimiento si se ha enviado el byte completo.
                            end else begin
                                state <= S_SENDBIT; // Continua enviando bits.
                            end
                        end
                    end
                    S_CHECKACK: begin
                        if (TIC) begin
                            STATUS <= 3'b011;
                            SDA_OUT <= 1'b1;
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0;
                            state <= S_CHECKACKUP; // Cambia al estado de verificación de reconocimiento.
                        end
                    end
                    S_CHECKACKUP: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            SCL_OUT <= 1'b1; // Sube SCL.
                            nackdet <= (sda_in_qq == 1'b1) ? 1'b1 : 1'b0; // Detecta no reconocimiento.
                            state <= S_CHECKACKDOWN; // Cambia al estado de verificación de reconocimiento bajada.
                        end
                    end
                    S_CHECKACKDOWN: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0; // Baja SCL.
                            state <= next_state; // Cambia al siguiente estado (escritura o lectura).
                        end
                    end
                    S_WRITE: begin
                        if (nackdet) begin
                            NACK <= 1'b1;
                            SCL_OUT <= 1'b0;
                            if (TIC) begin
                                nackdet <= 1'b0;
                                SDA_OUT <= 1'b0;
                                state <= S_PRESTOP; // Prepara la señal de parada si hay no reconocimiento.
                            end
                        end else begin
                            if (WE) begin
                                shift <= DIN; // Carga los datos a escribir.
                                counter <= 4'b0000;
                                QUEUED <= 1'b1;
                                DATA_VALID <= 1'b0;
                                state <= S_SENDBIT; // Cambia al estado de envío de bits.
                            end else if (RD) begin    
                                SCL_OUT <= 1'b0;
                                SDA_OUT <= 1'b1;
                                if (TIC) begin
                                    state <= S_RESTART; // Reinicia si hay comando de lectura.
                                end
                            end else begin
                                SCL_OUT <= 1'b0;
                                if (TIC) begin
                                    SDA_OUT <= 1'b0;
                                    state <= S_PRESTOP; // Prepara la señal de parada.
                                end
                            end
                        end
                    end
                    S_RESTART: begin
                        if (TIC) begin
                            state <= S_IDLE; // Reinicia al estado IDLE.
                        end
                    end
                    S_READ: begin
                        if (nackdet) begin
                            NACK <= 1'b1;
                            SCL_OUT <= 1'b0;
                            if (TIC) begin
                                nackdet <= 1'b0;
                                SDA_OUT <= 1'b0;
                                state <= S_PRESTOP; // Prepara la señal de parada si hay no reconocimiento.
                            end
                        end else begin
                            if (RD) begin
                                shift <= 8'b0; // Reinicia el registro de desplazamiento.
                                counter <= 4'b0000;
                                QUEUED <= 1'b1;
                                state <= S_RECVBIT; // Cambia al estado de recepción de bits.
                            end else if (WE) begin    
                                SCL_OUT <= 1'b0;
                                SDA_OUT <= 1'b1;
                                if (TIC) begin
                                    state <= S_IDLE; // Reinicia al estado IDLE.
                                end
                            end else begin
                                SCL_OUT <= 1'b0;
                                if (TIC) begin
                                    SDA_OUT <= 1'b0;
                                    state <= S_PRESTOP; // Prepara la señal de parada.
                                end
                            end
                        end
                    end
                    S_RECVBIT: begin
                        if (TIC) begin
                            STATUS <= 3'b101;
                            SDA_OUT <= 1'b1;
                            SCL_OUT <= 1'b0;
                            counter <= next_counter; 
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            state <= S_RDSCLUP; // Cambia al estado de recepción de bits con subida de SCL.
                        end
                    end
                    S_RDSCLUP: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b1; // Sube SCL.
                            shift[7:1] <= shift[6:0];
                            shift[0] <= sda_in_qq; // Desplaza los datos recibidos.
                            state <= S_RDSCLDOWN; // Cambia al estado de recepción de bits con bajada de SCL.
                        end
                    end
                    S_RDSCLDOWN: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0; // Baja SCL.
                            if (counter[3]) begin
                                state <= S_SENDACK; // Envía la señal de reconocimiento si se ha recibido el byte completo.
                            end else begin
                                state <= S_RECVBIT; // Continúa recibiendo bits.
                            end
                        end
                    end
                    S_SENDACK: begin
                        if (TIC) begin
                            STATUS <= 3'b110;
                            SDA_OUT <= (RD) ? 1'b0 : 1'b1;  // Envía la señal de reconocimiento final para lectura.
                            DOUT <= shift; // Almacena los datos recibidos en DOUT.
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b1;
                            SCL_OUT <= 1'b0;
                            state <= S_SENDACKUP; // Cambia al estado de subida de la señal de reconocimiento.
                        end
                    end
                    S_SENDACKUP: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b1; // Sube SCL.
                            state <= S_SENDACKDOWN; // Cambia al estado de bajada de la señal de reconocimiento.
                        end
                    end
                    S_SENDACKDOWN: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0; // Baja SCL.
                            state <= S_READ; // Cambia al estado de lectura.
                        end
                    end
                    S_PRESTOP: begin
                        if (TIC) begin
                            STATUS <= 3'b111;
                            STOP <= 1'b1;
                            SCL_OUT <= 1'b1;
                            SDA_OUT <= 1'b0;
                            NACK <= 1'b0;
                            state <= S_STOP; // Cambia al estado de parada.
                        end
                    end
                    S_STOP: begin
                        if (TIC) begin
                            SCL_OUT <= 1'b1;
                            SDA_OUT <= 1'b1;
                            state <= S_IDLE; // Reinicia al estado IDLE.
                        end
                    end
                    default: state <= S_IDLE; // Estado por defecto.
                endcase
            end
        end
    end
endmodule
