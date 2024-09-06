module ControlLed(
    input clk,
	input wire echo,
    input wire [19:0] contador2,  
    output reg sens_ult,
	output reg led1 
     
);

// distancia = 340 m/s * tiempo / 2
// 5cm => 295 us = 295000 ns = 14750 ciclos de reloj
// 1cm => 59 us = 59000 ns = 2950 ciclos de reloj


//10us = 10000ns = 500 ciclos de reloj = 10 bits

parameter DOWNSENS=15'd1001; //Para 50 ciclos de reloj == 1us
reg [$clog2(DOWNSENS)-1:0] downSens; //Para 10 bits
reg aux;

initial begin
	sens_ult=0; 
	downSens=0;
	led1=0;
	aux = 0;
end


parameter L=14'd14750; //Para 5cm
parameter Lm=14'd2950; //Para 1cm






always @(posedge clk)
	begin
		if(echo==0)	begin
			aux =1;
		end
		else begin	
			aux = 0;
		end


		if(aux ==1) begin
			if (contador2>Lm && contador2<L)
			begin
				sens_ult=1;
			    led1=1;
 
			end
	
		end


		if (sens_ult==1)
			begin
				downSens=downSens+1;
				if (downSens > DOWNSENS)
					begin
						sens_ult=0;
						downSens=0;
						led1=0;
					end
			end
		else
			begin
				downSens=0;
			end
	end

endmodule
