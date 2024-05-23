module DEMO_MPU6050 (
    input wire MCLK,
    input wire RESET,
    inout wire SDA,
    inout wire SCL,
    output wire LEDX,
    output wire LEDY,
    output wire LEDZ,
    output wire LEDSIGN
);

    // Internal signals
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
    reg [7:0] counter;
    wire nRST;

    // Output registers
    reg [7:0] XREG;
    reg [7:0] YREG;
    reg [7:0] ZREG;

    assign nRST = RESET;

    // Instantiate MPU6050 component
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

    // Instantiate I2CMASTER component
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

    // Instantiate COMPARE component
    COMPARE I_COMPARE_0 (
        .MCLK(MCLK),
        .nRST(nRST),
        .TIC(TIC),
        .COMPLETED(COMPLETED),
        .RESCAN(RESCAN),
        .XREG(XREG),
        .YREG(YREG),
        .ZREG(ZREG),
        .LEDX(LEDX),
        .LEDY(LEDY),
        .LEDZ(LEDZ),
        .SIGN(LEDSIGN)
    );

    // Generate TIC signal
    assign TIC = counter[7] & counter[5];

    // Counter process
    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin
            counter <= 8'b0;
        end else if (TIC) begin
            counter <= 8'b0;
        end else begin
            counter <= counter + 1;
        end
    end

    // Registers process
    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin
            XREG <= 8'b0;
            YREG <= 8'b0;
            ZREG <= 8'b0;
        end else if (TIC && LOAD) begin
            case (ADR)
                4'h0: XREG <= DATA;
                4'h2: YREG <= DATA;
                4'h4: ZREG <= DATA;
            endcase
        end
    end

    // Open-drain configuration
    assign SCL = (SCL_OUT) ? 1'bz : 1'b0;
    assign SCL_IN = SCL;
    assign SDA = (SDA_OUT) ? 1'bz : 1'b0;
    assign SDA_IN = SDA;

endmodule
