module ContadorConTrigger( // Módulo que envía Trigger Constanstemente
    input clk,
    output reg trig
);

parameter TRIG_PULSE_WIDTH = 10'd500; // 10us = 10000ns = 500 ciclos de reloj
reg [31:0] counter;

always @(posedge clk) begin
    if (counter < TRIG_PULSE_WIDTH) begin // Señal trigger va a estar en 1 por 10us
        counter <= counter + 1;
        trig <= 1;
    end else begin  //Al llegar a 10us se reinicia el contador y la señal trigger
        counter <= 0;
        trig <= 0;
    end //La señal se enviará constantemente
end

endmodule
