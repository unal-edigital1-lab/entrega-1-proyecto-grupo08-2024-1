// Módulo encargado de comunicarse con el periférico
module I2CMASTER ( 
    input wire MCLK, //Reloj de la FPGA
    input wire nRST, //Reset de la FPGA
    input wire SRST, //Reset síncrono
    input wire TIC, //Tasa de i2c (tasa de bit x3)
    input wire [7:0] DIN, //Data a enviar
    output reg [7:0] DOUT, //Data a recibir
    input wire RD, //Comando de lectura
    input wire WE, //Comando de escritura
    output reg NACK, //Nack del esclavo
    output reg QUEUED, //Operación (ciclo de lectura o escritura) en espera
    output reg DATA_VALID, //Nueva data disponible en DOUT
    output reg STOP, //Señal de parada
    output reg [2:0] STATUS, //Estado de máquina de estados
    input wire SCL_IN, //Señal de reloj i2c
    output reg SCL_OUT, //Señal de reloj i2c modificada para controlar el bus
    input wire SDA_IN, //Señal de datos i2c
    output reg SDA_OUT //Señal de datos i2c modificada para controlar el bus
);

    parameter DEVICE = 8'h68; //Parámetro necesario para iniciar comunicación con el MPU6050

    // Definición de los estados
    parameter S_IDLE = 5'b00000, //Estado de espera
              S_START = 5'b00001, //Estado de inicio 
              S_SENDBIT = 5'b00010, //Estado de envío de bit
              S_WESCLUP = 5'b00011, //Estado de espera de la subida del reloj SCL
              S_WESCLDOWN = 5'b00100, //Estado de espera de la bajada del reloj SCL
              S_CHECKACK = 5'b00101, //Estado de verificación de ACK/NACK
              S_CHECKACKUP = 5'b00110, //Estado de verificación con reloj alto
              S_CHECKACKDOWN = 5'b00111, //Estado de verificación con reloj bajo
              S_WRITE = 5'b01000, //Estado de escritura de datos
              S_PRESTOP = 5'b01001, //Estado previo a la señal de parada 
              S_STOP = 5'b01010, //Estado de parada
              S_READ = 5'b01011, //Estado lectura de datos
              S_RECVBIT = 5'b01100, //Estado de recepción de bits (de esclavo a maestro)
              S_RDSCLUP = 5'b01101, //Espera para la subida del SCL de lectura
              S_RDSCLDOWN = 5'b01110, //Espera para la bajada del SCL de lectura
              S_SENDACK = 5'b01111, //Estado para enviar ACK al esclavo después de leer
              S_SENDACKUP = 5'b10000, //Espera con ACK y reloj alto
              S_SENDACKDOWN = 5'b10001, //Espera con ACK y reloj bajo
              S_RESTART = 5'b10010; //Estado de reinicio de la comunicación

    // Variables de estado
    reg [4:0] state, next_state;
    reg [3:0] counter, next_counter; //Contador para controlar bits enviados/recibidos
    reg [7:0] shift; //Cambio de bit a bit por señal bidireccional de un bit que se envía
    reg nackdet;
    reg sda_in_q, sda_in_qq; //Registro de captura para sincronizar SDA_IN con el reloj MCLK

    // Lógica combinacional para el contador
    always @(*) begin
        next_counter = counter + 1;
    end

    // Lógica secuencial para el registro de captura de SDA_IN
    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin
            sda_in_q <= 1'b1;
            sda_in_qq <= 1'b1;
        end else if (MCLK) begin
            sda_in_q <= SDA_IN;
            sda_in_qq <= sda_in_q; //Sincroniza SDA_IN con el reloj MCLK
        end
    end

    // Lógica secuencial principal para la máquina de estados
    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin //Reset del sistema: se inicializan todas las señales y estados
            STATUS <= 3'b000;
            state <= S_IDLE;
            SCL_OUT <= 1'b1;
            SDA_OUT <= 1'b1;
            NACK <= 1'b0;
            QUEUED <= 1'b0;
            DATA_VALID <= 1'b0;
            DOUT <= 8'b0;
            counter <= 4'b0;
            nackdet <= 1'b0;
            shift <= 8'b0;
            STOP <= 1'b0;
        end else if (MCLK) begin
            if (SRST) begin //Si hay reset síncrono, vuelve al estado de inactividad
                state <= S_IDLE;
            end else begin
                case (state)
                    //Estado de inactividad, esperando comandos de escritura o lectura
                    S_IDLE: begin
                        STATUS <= 3'b000;
                        SCL_OUT <= 1'b1;
                        SDA_OUT <= 1'b1;
                        NACK <= 1'b0;
                        QUEUED <= 1'b0;
                        DATA_VALID <= 1'b0;
                        DOUT <= 8'h01; //Inicializa el registro de datos de salida
                        counter <= 4'b0;
                        STOP <= 1'b0;
                        if (TIC) begin
                            if (WE || RD) begin //Si hay una operación de escritura o lectura pendiente, pasa al estado de inicio
                                state <= S_START;
                            end
                        end
                    end
                    //Estado que genera la condición de inicio en el bus I2C (start bit)
                    S_START: begin
                        STATUS <= 3'b001;
                        SCL_OUT <= 1'b1;
                        SDA_OUT <= 1'b0; //Genera el start bit (SDA pasa de alto a bajo mientras SCL está alto)
                        NACK <= 1'b0;
                        QUEUED <= 1'b0;
                        STOP <= 1'b0;
                        DATA_VALID <= 1'b0;
                        if (TIC) begin //Si la tasa de reloj TIC lo permite, comienza la transmisión
                            SCL_OUT <= 1'b0; //Baja el reloj SCL para comenzar la transmisión
                            counter <= 4'b0000;
                            shift[7:1] <= DEVICE[6:0]; //Carga la dirección del dispositivo esclavo
                            if (WE) begin
                                shift[0] <= 1'b0; //Para escritura, el último bit es '0' (RW bit)
                                next_state <= S_WRITE; 
                            end else begin
                                shift[0] <= 1'b1; //Para lectura, el último bit es '1' (RW bit)
                                next_state <= S_READ;
                            end
                            state <= S_SENDBIT;
                        end
                    end
                    // Estado donde se envía un bit de la dirección o del dato al esclavo
                    S_SENDBIT: begin
                        if (TIC) begin
                            STATUS <= 3'b010;
                            SCL_OUT <= 1'b0; //SCL está en bajo
                            SDA_OUT <= shift[7]; //Bit más significativo se envía por SDA
                            shift[7:1] <= shift[6:0]; //Desplaza los bits a la derecha para preparar el siguiente
                            counter <= next_counter; //Con el incremento del contador, se incrementa el envío de bits
                            NACK <= 1'b0; 
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            state <= S_WESCLUP; 
                        end
                    end
                    // Estado que espera que el reloj SCL suba para completar la transmisión de un bit
                    S_WESCLUP: begin 
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b1; //Sube reloj SCL para que el esclavo lea el bit enviado
                            state <= S_WESCLDOWN;
                        end
                    end
                    // Estado que espera la bajada del reloj SCL para terminar la transmisión de un bit
                    S_WESCLDOWN: begin 
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0; //Baja el reloj SCL para terminar la transmisión de un bit
                            if (counter[3]) begin //Leen cuando el contador llega a 8 (1000)
                                state <= S_CHECKACK; //Pasa al estado donde se verifica el ACK/NACK
                            end else begin
                                state <= S_SENDBIT; //De lo contrario, vuelve a enviar el siguiente bit
                            end
                        end
                    end
                    // Estado que espera la bajada del reloj SCL después de verificar el ACK/NACK
                    S_CHECKACK: begin
                        if (TIC) begin
                            STATUS <= 3'b011;
                            SDA_OUT <= 1'b1; //Libera la línea SDA para que el esclavo pueda responder con ACK/NACK
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0; //Baja el reloj SCL en preparación para leer el ACK/NACK
                            state <= S_CHECKACKUP;    
                        end
                    end
                    // Estado que espera la subida del reloj SCL para verificar el ACK/NACK
                    S_CHECKACKUP: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            SCL_OUT <= 1'b1; //Sube el reloj SCL para leer el estado de la línea SDA
                            nackdet <= (sda_in_qq == 1'b1) ? 1'b1 : 1'b0; //Si SDA sigue en alto, significa que hay un NACK
                            state <= S_CHECKACKDOWN;    
                        end
                    end
                    // Estado que espera la bajada del reloj SCL después de verificar el ACK/NACK
                    S_CHECKACKDOWN: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0; //Baja el reloj SCL para finalizar la verificación del ACK/NACK
                            state <= next_state;    // Para a escoger el estado de S_WRITE o S_READ
                        end
                    end
                    // Estado para manejar la escritura de datos al dispositivo esclavo
                    S_WRITE: begin
                        if (nackdet) begin //Si se ha detectado un NACK
                            NACK <= 1'b1; //Activa la señal NACK para indicar el error
                            SCL_OUT <= 1'b0; //Baja el reloj SCL
                            if (TIC) begin
                                nackdet <= 1'b0; 
                                SDA_OUT <= 1'b0; //Prepara la línea SDA para la parada
                                state <= S_PRESTOP; //Cambia al estado de preparación para la parada
                            end
                        end else begin
                            if (WE) begin //Si hay un comando de escritura
                                shift <= DIN; //Carga los datos de entrada (DIN) en el registro de desplazamiento
                                counter <= 4'b0000; //Reinicia el contador de bits
                                QUEUED <= 1'b1; //Indica que hay una operación en cola
                                DATA_VALID <= 1'b0;
                                state <= S_SENDBIT; //Vuelve al estado de envío de bits para transmitir los datos
                            end else if (RD) begin //Si hay un comando de lectura
                                SCL_OUT <= 1'b0; //Baja el reloj SCL
                                SDA_OUT <= 1'b1; //Libera línea SDA para lectura
                                if (TIC) begin
                                    state <= S_RESTART; //Cambia a estado de reinicio
                                end
                            end else begin
                                SCL_OUT <= 1'b0; //Baja el reloj SCL
                                if (TIC) begin
                                    SDA_OUT <= 1'b0; //Prepara la línea SDA para la parada
                                    state <= S_PRESTOP; //Cambia a estado antes de la parada
                                end
                            end
                        end
                    end
                    // Estado de reinicio de operación
                    S_RESTART: begin
                        if (TIC) begin
                            state <= S_IDLE; //Vuelve al estado de inactividad
                        end
                    end
                    // Estado para manejar la lectura de datos del dispositivo esclavo
                    S_READ: begin
                        if (nackdet) begin 
                            NACK <= 1'b1;
                            SCL_OUT <= 1'b0; //Baja reloj SCL
                            if (TIC) begin
                                nackdet <= 1'b0;
                                SDA_OUT <= 1'b0; //Prepara SDA para parada
                                state <= S_PRESTOP; // Por detectar un Nack, se devuelve.
                            end
                        end else begin
                            if (RD) begin //Si hay un comando de lectura
                                shift <= 8'b0; //Limpia el registro de desplazamiento para recibir los datos
                                counter <= 4'b0000; //Reinicia contador
                                QUEUED <= 1'b1; //Indica que hay una operación en cola
                                state <= S_RECVBIT; //Cambia al estado de recepción de bits
                            end else if (WE) begin //Si hay un comando de escrituta  
                                SCL_OUT <= 1'b0; //Baja reloj SCL
                                SDA_OUT <= 1'b1; //Sube línea SDA para escritura
                                if (TIC) begin
                                    state <= S_IDLE; // Vuelve a estado de inactividad
                                end
                            end else begin
                                SCL_OUT <= 1'b0; 
                                if (TIC) begin
                                    SDA_OUT <= 1'b0;
                                    state <= S_PRESTOP;
                                end
                            end
                        end
                    end
                    // Estado que recibe un bit del esclavo I2C
                    S_RECVBIT: begin
                        if (TIC) begin
                            STATUS <= 3'b101;
                            SDA_OUT <= 1'b1; //Líbera la línea SDA permitir que el esclavo envíe un bit 
                            SCL_OUT <= 1'b0; //SCL en bajo
                            counter <= next_counter; //Incrementa contador
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            state <= S_RDSCLUP;
                        end
                    end
                    // Estado que sube el reloj SCL para permitir la lectura del bit
                    S_RDSCLUP: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b1; //Sube reloj SCL para permitir que el esclavo envíe el bit
                            shift[7:1] <= shift[6:0]; //Desplaza los datos hacie la derecha para recibir el próximo bit
                            shift[0] <= sda_in_qq; //Captura el bit recibido en la línea SDA
                            state <= S_RDSCLDOWN;
                        end
                    end
                    // Estado que baja el reloj después de recibir un bit
                    S_RDSCLDOWN: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0; //Baja el reloj SCL después de recibir el bit
                            if (counter[3]) begin
                                state <= S_SENDACK; //Si ya se han recibido los 8 bits, cambia al estado de envío del ACK
                            end else begin
                                state <= S_RECVBIT; //Si faltan bits, vuelve a recibir otro bit
                            end
                        end
                    end
                    // Estado que envía el ACK al esclavo I2C
                    S_SENDACK: begin
                        if (TIC) begin // 
                            STATUS <= 3'b110;
                            SDA_OUT <= (RD) ? 1'b0 : 1'b1;  // Si es una lectura, baja línea SDA para enviar un ACK
                            DOUT <= shift; //Guarda los datos recibidos en la variable DOUT
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b1; //Marca que los datos recibidos son válidos
                            SCL_OUT <= 1'b0; //Mantiene el reloj SCL en bajo
                            state <= S_SENDACKUP;
                        end
                    end
                    // Estado que sube el reloj SCL para confirmar el ACK
                    S_SENDACKUP: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b1; //Sube el reloj SCL para finalizar la transmición del ACK
                            state <= S_SENDACKDOWN;
                        end
                    end
                    // Estado que baja el reloj SCL después de enviar el ACK
                    S_SENDACKDOWN: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0; //Baja reloj de SCL para terminar envío de ACK
                            state <= S_READ; //Vuelve a estado de lectura de datos del esclavo
                        end
                    end
                    // Estado que prepara la condición de parada (STOP)
                    S_PRESTOP: begin
                        if (TIC) begin
                            STATUS <= 3'b111;
                            STOP <= 1'b1; //Activa la señal de parada
                            SCL_OUT <= 1'b1; //Sube reloj SCL antes de parar 
                            SDA_OUT <= 1'b0; //Baja línea SDA antes de enviar la parada
                            NACK <= 1'b0;
                            state <= S_STOP; 
                        end
                    end
                    // Estado que envía la condición de parada (STOP)
                    S_STOP: begin
                        if (TIC) begin
                            SCL_OUT <= 1'b1; //Mantiene reloj SCL en alto
                            SDA_OUT <= 1'b1; //Sube línea SDA para completar parada
                            state <= S_IDLE; //Vuelve al estado de inactividad
                        end
                    end
                    // Estado por defecto que asegura que el sistema está en inactividad
                    default: state <= S_IDLE;
                endcase
            end
        end
    end

endmodule
