module btnAntirebote #(parameter COUNT_BOT=50000)(
	
	input clk,
	input boton_in,
	output reg boton_out
);

reg [$clog2(COUNT_BOT)-1:0] counter; // contador con bits de COUNT_BOT
reg reset;




initial begin
	boton_out=0;
    reset = 0;;
end

always @(posedge clk) begin
	if (~reset)begin              
		//Si reset es 0, el counter vuelve a 0 y el boton_out es igual al inverso del boton_in
		
		counter <=0;
		boton_out<=boton_in;

	end else begin
		//Si reset es 1
		
		if (boton_in==boton_out) begin 
			// si el boton_in es igual al boton_out, el counter se incrementa en 1
			counter <= counter+1;			
		end else begin
			// si el boton_in es diferente al boton_out, el counter vuelve a 0
			counter<=0;			
		end
		if (boton_in==0 && counter==COUNT_BOT)begin
			// si el boton_in es 0 y el counter es igual a COUNT_BOT, el boton_out es igual a 0 y el counter vuelve a 0			
	 			boton_out<=0;
				counter<=0;
				
		end
		if (boton_in==1 && counter==COUNT_BOT/100+1)begin
			// si el boton_in es 1 y el counter es igual a COUNT_BOT/100+1, el boton_out es igual a 1 y el counter vuelve a 0
	 			boton_out<=1;
				counter<=0;
				
		end
	
	end
		

end	


endmodule