module COMPARE (
    input wire MCLK,
    input wire nRST,
    input wire TIC, //Señal de activación de operación
    input wire COMPLETED, 
    output reg RESCAN, 
    input wire [7:0] XREG,
    output reg LEDX,
    output reg SIGN
);

// Analizar función
// Calcula magnitud (valor absoluto) de un número de 8 bit
    function [7:0] magnitude;
        input [7:0] a;
        reg [7:0] ret;
        begin
            if (a[7] == 1'b1) begin
                ret = ~a + 1'b1; //Si el número es negativo, se obtiene el complemento a 2 (valor absoluto).
            end else begin
                ret = a; //Si el número es positivo, se devuelve tal como está.
            end
            magnitude = ret; //Retorna el valor absoluto.
        end
    endfunction

// Cálculo de las magnitudes de XREG, YREG y ZREG
    wire [7:0] x2c = magnitude(XREG);

// Comparaciones entre las magnitudes para determinar cuál es mayor
    wire xy = (x2c > 0) ? 1'b1 : 1'b0; //1 si x2c es mayor que y2c, 0 de lo contrario.

// Determinación de qué LED debe encenderse basado en las comparaciones
    wire ledx_a = xy;

    always @(posedge MCLK or negedge nRST) begin
        if (!nRST) begin //Si nRST está activo (reset), se inicializan los LEDs y las señales de control
            LEDX <= 1'b1;
            SIGN <= 1'b1;
            RESCAN <= 1'b0;
        end else begin
            if (TIC) begin //Si TIC es 1, se revisa si el proceso está completado
                if (COMPLETED) begin
                    LEDX <= ~ledx_a;
                    SIGN <= 1'b0;
                    if (ledx_a) begin //Se determinan los valores de los LEDs basados en las comparaciones
                        SIGN <= ~XREG[7];
                    end
                    RESCAN <= 1'b1;
                end else begin
                    RESCAN <= 1'b0;
                end
            end
        end
    end

endmodule
