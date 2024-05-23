module I2CMASTER (
    input wire MCLK,
    input wire nRST,
    input wire SRST,                        // synchronous reset
    input wire TIC,                         // i2c rate (bit rate x3)
    input wire [7:0] DIN,                   // data to send
    output reg [7:0] DOUT,                  // received data
    input wire RD,                          // read command
    input wire WE,                          // write command
    output reg NACK,                        // nack from slave
    output reg QUEUED,                      // operation (write or read cycle) is queued
    output reg DATA_VALID,                  // new data available on DOUT
    output reg STOP,
    output reg [2:0] STATUS,                // state machine state
    input wire SCL_IN,                      // i2c signals
    output reg SCL_OUT,
    input wire SDA_IN,
    output reg SDA_OUT
);

    parameter DEVICE = 8'h38;

    // Definición de los estados
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

    // Variables de estado
    reg [4:0] state, next_state;
    reg [3:0] counter, next_counter;
    reg [7:0] shift;
    reg nackdet;
    reg sda_in_q, sda_in_qq;

    always @(*) begin
        next_counter = counter + 1;
    end

    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin
            sda_in_q <= 1'b1;
            sda_in_qq <= 1'b1;
        end else if (MCLK) begin
            sda_in_q <= SDA_IN;
            sda_in_qq <= sda_in_q;
        end
    end

    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin
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
            if (SRST) begin
                state <= S_IDLE;
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
                                state <= S_START;
                            end
                        end
                    end
                    S_START: begin
                        STATUS <= 3'b001;
                        SCL_OUT <= 1'b1;
                        SDA_OUT <= 1'b0; // start bit
                        NACK <= 1'b0;
                        QUEUED <= 1'b0;
                        STOP <= 1'b0;
                        DATA_VALID <= 1'b0;
                        if (TIC) begin
                            SCL_OUT <= 1'b0;
                            counter <= 4'b0000;
                            shift[7:1] <= DEVICE[6:0];
                            if (WE) begin
                                shift[0] <= 1'b0;
                                next_state <= S_WRITE;
                            end else begin
                                shift[0] <= 1'b1; // RD='1'
                                next_state <= S_READ;
                            end
                            state <= S_SENDBIT;
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
                            state <= S_WESCLUP;
                        end
                    end
                    S_WESCLUP: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b1;
                            state <= S_WESCLDOWN;
                        end
                    end
                    S_WESCLDOWN: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0;
                            if (counter[3]) begin
                                state <= S_CHECKACK;
                            end else begin
                                state <= S_SENDBIT;
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
                            state <= S_CHECKACKUP;    
                        end
                    end
                    S_CHECKACKUP: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            SCL_OUT <= 1'b1;
                            nackdet <= (sda_in_qq == 1'b1) ? 1'b1 : 1'b0;
                            state <= S_CHECKACKDOWN;    
                        end
                    end
                    S_CHECKACKDOWN: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0;
                            state <= next_state;    // S_WRITE or S_READ
                        end
                    end
                    S_WRITE: begin
                        if (nackdet) begin
                            NACK <= 1'b1;
                            SCL_OUT <= 1'b0;
                            if (TIC) begin
                                nackdet <= 1'b0;
                                SDA_OUT <= 1'b0;
                                state <= S_PRESTOP;
                            end
                        end else begin
                            if (WE) begin
                                shift <= DIN;
                                counter <= 4'b0000;
                                QUEUED <= 1'b1;
                                DATA_VALID <= 1'b0;
                                state <= S_SENDBIT;
                            end else if (RD) begin    
                                SCL_OUT <= 1'b0;
                                SDA_OUT <= 1'b1;
                                if (TIC) begin
                                    state <= S_RESTART; // for restart
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
                    S_RESTART: begin
                        if (TIC) begin
                            state <= S_IDLE;
                        end
                    end
                    S_READ: begin
                        if (nackdet) begin
                            NACK <= 1'b1;
                            SCL_OUT <= 1'b0;
                            if (TIC) begin
                                nackdet <= 1'b0;
                                SDA_OUT <= 1'b0;
                                state <= S_PRESTOP;
                            end
                        end else begin
                            if (RD) begin
                                shift <= 8'b0;
                                counter <= 4'b0000;
                                QUEUED <= 1'b1;
                                state <= S_RECVBIT;
                            end else if (WE) begin    
                                SCL_OUT <= 1'b0;
                                SDA_OUT <= 1'b1;
                                if (TIC) begin
                                    state <= S_IDLE; // for restart
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
                            state <= S_RDSCLUP;
                        end
                    end
                    S_RDSCLUP: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b1;
                            shift[7:1] <= shift[6:0];
                            shift[0] <= sda_in_qq;
                            state <= S_RDSCLDOWN;
                        end
                    end
                    S_RDSCLDOWN: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0;
                            if (counter[3]) begin
                                state <= S_SENDACK;
                            end else begin
                                state <= S_RECVBIT;
                            end
                        end
                    end
                    S_SENDACK: begin
                        if (TIC) begin
                            STATUS <= 3'b110;
                            SDA_OUT <= (RD) ? 1'b0 : 1'b1;  // last read 
                            DOUT <= shift;
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b1;
                            SCL_OUT <= 1'b0;
                            state <= S_SENDACKUP;
                        end
                    end
                    S_SENDACKUP: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b1;
                            state <= S_SENDACKDOWN;
                        end
                    end
                    S_SENDACKDOWN: begin
                        if (TIC) begin
                            NACK <= 1'b0;
                            QUEUED <= 1'b0;
                            STOP <= 1'b0;
                            DATA_VALID <= 1'b0;
                            SCL_OUT <= 1'b0;
                            state <= S_READ;
                        end
                    end
                    S_PRESTOP: begin
                        if (TIC) begin
                            STATUS <= 3'b111;
                            STOP <= 1'b1;
                            SCL_OUT <= 1'b1;
                            SDA_OUT <= 1'b0;
                            NACK <= 1'b0;
                            state <= S_STOP;
                        end
                    end
                    S_STOP: begin
                        if (TIC) begin
                            SCL_OUT <= 1'b1;
                            SDA_OUT <= 1'b1;
                            state <= S_IDLE;
                        end
                    end
                    default: state <= S_IDLE;
                endcase
            end
        end
    end

endmodule
