module COMPARE (
    input wire MCLK,
    input wire nRST,
    input wire TIC,
    input wire COMPLETED,
    output reg RESCAN,
    input wire [7:0] XREG,
    input wire [7:0] YREG,
    input wire [7:0] ZREG,
    output reg LEDX,
    output reg LEDY,
    output reg LEDZ,
    output reg SIGN
);

// Analizar función
    function [7:0] magnitude;
        input [7:0] a;
        reg [7:0] ret;
        begin
            if (a[7] == 1'b1) begin
                ret = ~a + 1'b1;
            end else begin
                ret = a;
            end
            magnitude = ret;
        end
    endfunction

    wire [7:0] x2c = magnitude(XREG);
    wire [7:0] y2c = magnitude(YREG);
    wire [7:0] z2c = magnitude(ZREG);

    wire xy = (x2c > y2c) ? 1'b1 : 1'b0;
    wire xz = (x2c > z2c) ? 1'b1 : 1'b0;
    wire yz = (y2c > z2c) ? 1'b1 : 1'b0;

    wire ledx_a = xy & xz;
    wire ledy_a = ~xy & yz;
    wire ledz_a = ~xz & ~yz;

    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin
            LEDX <= 1'b1;
            LEDY <= 1'b1;
            LEDZ <= 1'b1;
            SIGN <= 1'b1;
            RESCAN <= 1'b0;
        end else begin
            if (TIC) begin
                if (COMPLETED) begin
                    LEDX <= ~ledx_a;
                    LEDY <= ~ledy_a;
                    LEDZ <= ~ledz_a;
                    if (ledx_a) begin
                        SIGN <= ~XREG[7];
                    end else if (ledy_a) begin
                        SIGN <= ~YREG[7];
                    end else if (ledz_a) begin
                        SIGN <= ~ZREG[7];
                    end
                    RESCAN <= 1'b1;
                end else begin
                    RESCAN <= 1'b0;
                end
            end
        end
    end

endmodule
