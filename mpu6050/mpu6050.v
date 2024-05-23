module MPU6050 (
    input wire MCLK,
    input wire nRST,
    input wire TIC,
    output reg SRST,
    output reg [7:0] DOUT,
    output reg RD,
    output reg WE,
    input wire QUEUED,
    input wire NACK,
    input wire STOP,
    input wire DATA_VALID,
    input wire [7:0] DIN,
    output reg [3:0] ADR,
    output reg [7:0] DATA,
    output reg LOAD,
    output reg COMPLETED,
    input wire RESCAN
);

    // Definición de los estados
    parameter S_IDLE = 3'b000,
              S_PWRMGT0 = 3'b001,
              S_PWRMGT1 = 3'b010,
              S_READ0 = 3'b011,
              S_READ1 = 3'b100,
              S_STABLE = 3'b101;

    // Variable de estado
    reg [2:0] state;
    reg [3:0] adr_i;

    // Máquina de estados
    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin
            SRST <= 1'b0;
            DOUT <= 8'b0;
            RD <= 1'b0;
            WE <= 1'b0;
            adr_i <= 4'b0;
            LOAD <= 1'b0;
            DATA <= 8'b11111111;
            COMPLETED <= 1'b0;
            state <= S_IDLE;
        end else begin
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
                        state <= S_PWRMGT0;
                    end
                end
                S_PWRMGT0: begin
                    if (TIC) begin
                        DOUT <= 8'h6B;
                        WE <= 1'b1;
                        RD <= 1'b0;
                        if (QUEUED) begin
                            DOUT <= 8'h00;
                            WE <= 1'b1;
                            RD <= 1'b0;
                            state <= S_PWRMGT1;
                        end else if (NACK) begin
                            state <= S_IDLE;
                        end
                    end
                end
                S_PWRMGT1: begin
                    if (TIC) begin
                        if (QUEUED) begin
                            DOUT <= 8'h00;
                            WE <= 1'b0;
                            RD <= 1'b0;
                            state <= S_READ0;
                        end else if (NACK) begin
                            state <= S_IDLE;
                        end
                    end
                end
                S_READ0: begin    
                    if (TIC) begin
                        if (STOP) begin
                            DOUT <= 8'h3B; // read 14 registers (incluyen los del acelerómetro)
                            WE <= 1'b1;
                            RD <= 1'b0;
                        end else if (QUEUED) begin
                            WE <= 1'b0;
                            RD <= 1'b1;
                            adr_i <= 4'b0;
                        end else if (DATA_VALID) begin
                            LOAD <= 1'b1;
                            DATA <= DIN;
                            state <= S_READ1;    
                        end else if (NACK) begin
                            state <= S_IDLE;
                        end    
                    end
                end
                S_READ1: begin
                    if (TIC) begin
                        if (DATA_VALID) begin
                            LOAD <= 1'b1;
                            DATA <= DIN;
                        end else if (QUEUED) begin
                            adr_i <= adr_i + 1;
                            if (adr_i == 4'b1100) begin // last one
                                WE <= 1'b0;
                                RD <= 1'b0;
                            end else begin
                                WE <= 1'b0;
                                RD <= 1'b1; //Le envía bit de lectura porque ya se terminó el comando
                            end
                        end else if (STOP) begin
                            state <= S_STABLE;
                        end else begin
                            LOAD <= 1'b0;
                        end
                    end
                end
                S_STABLE: begin
                    COMPLETED <= 1'b1;
                    if (TIC) begin
                        if (RESCAN) begin
                            state <= S_IDLE;
                        end
                    end
                end
            endcase
        end
    end

    always @* begin
        ADR = adr_i;
    end

endmodule
