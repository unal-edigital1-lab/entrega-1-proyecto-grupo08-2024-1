module ContadorConEcho(
    input wire clk,           // Entrada de reloj
    input wire echo,          // Entrada de control (cuando echo=1, se incrementa el contador)
    output reg [19:0] contador2 // Salida del contador de 32 bits
);

always @(posedge clk) 
    begin
		if(echo==1)
			begin
				contador2=contador2+1; //Se va almacenando en un contador si el ultrasonido genera el echo
			end
		else
			begin 
				contador2=0;
			end
	end

endmodule