module ContadorConEcho(
    input wire clk,           // Entrada de reloj
    input wire echo,          // Entrada de control (cuando echo=1, se incrementa el contador)
	 input wire reset,
	 output reg clk_out,
    output reg [19:0] contador2 // Salida del contador de 32 bits
);

reg [22:0] counter;      // Suficientemente grande para contar hasta 7,500,000
    //parameter DIVISOR = 7500000;
    //parameter DIVISOR = 3750000;
    parameter DIVISOR = 1;


always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == DIVISOR-1) begin
                counter <= 0;
                clk_out <= ~clk_out;  // Invierte la señal para generar el nuevo clk
            end else begin
                counter <= counter + 1;
            end
        end
    end

always @(posedge clk_out) 
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
