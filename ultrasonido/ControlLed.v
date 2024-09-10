module ControlLed (
    input clk,
    input [31:0] echo_duration,
    output reg aux
);


// 29 us/cm 
// 20 ns = 1 ciclo de reloj = 0,02 us
// 1 us = 1000 ns
// 2cm => 58us = 58000 ns = 2900 cR; 10cm => 290us = 290000ns = 14500 cR; 5cm => 145us = 145000 ns = 7250 cR


parameter DISTANCE_2CM = 14'd2900; // Duración del pulso para 2cm
parameter DISTANCE_5CM = 14'd14500; // Duración del pulso para 5cm

always @(clk) begin
    if (echo_duration > DISTANCE_2CM && echo_duration < DISTANCE_5CM) begin
        aux <= 1; // Enciende el LED si la distancia está entre 2cm y 5cm
        
		
    end else if (echo_duration > DISTANCE_5CM || echo_duration < DISTANCE_2CM) begin
        aux <= 0; // Apaga el LED en cualquier otro caso
		
    end

end

endmodule