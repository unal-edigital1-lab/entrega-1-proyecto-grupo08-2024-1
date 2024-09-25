module Salida ( //Modulo que controla la salida 
    input clk,
    input aux,
    output reg led,
    output reg sens_ult
);

// 1s = 10⁹ ns = 50M ciclos

reg [31:0] countAux;
parameter downLed = 26'd5000000;

initial begin
    led = 1;
    sens_ult = 0;
    countAux = 0;
end

always @(posedge clk) begin 
    if (aux == 1) begin   //Si la señal aux se activa se enciende el Led y se activa la señal de salida sens_ult
        led <= 0;
        sens_ult <= 1;
        countAux = 0;
    end else if(countAux > downLed) begin //El led se apaga y sens_ult vuelve a 0 después de 0.1 segundos
        led <= 1;
        sens_ult <= 0;
    end


    countAux <= countAux + 1; //El contador incrementa en todo mom
end

endmodule