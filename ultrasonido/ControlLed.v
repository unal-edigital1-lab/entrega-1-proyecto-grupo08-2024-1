module ControlLed(
    input clk,
    input wire [19:0] contador2,  
    output reg sens_ult 
     
);

// distancia = 340 m/s * tiempo / 2
// 5cm => 295 us = 295000 ns = 14750 ciclos de reloj
// 1cm => 59 us = 59000 ns = 2950 ciclos de reloj

initial begin
	sens_ult=0; 
end


parameter L=14'd14750; //Para 5cm
parameter Lm=14'd2950; //Para 1cm



always @(posedge clk) 
	begin

		if (contador2>Lm && contador2<L)
			begin
				sens_ult=1; 
			end
	    else 
		begin
			sens_ult=0;
		end
	end
	

endmodule
