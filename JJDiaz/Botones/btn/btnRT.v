module btnRT (  //Modulo para Botones Reset y Test: Envía una señal depués de estar presionados 5 segundos
    input clk,
    input boton_in,
    output reg boton_out
);

    localparam COUNT_LIMIT = 28'd250000000; // 25*10⁷ ciclos de reloj = 5*10⁹ ns = 5 segundos 

    reg [$clog2(COUNT_LIMIT)+1:0] counter; // contador con bits necesarios para representar a COUNT_LIMIT

    initial begin  
        boton_out = 1; // La salida inicia en 1
        counter = 0;
    end

	 
	 always @(posedge clk) begin
	   if(boton_in == 0) begin // Si el boton_in está presionado empieza a aumentar el contador
		counter <= counter + 1;
			if(counter > COUNT_LIMIT) begin // Cuando el contador llegue a COUNT_LIMIT, la salida se pone en 0
				boton_out <= 0;
			end else begin // Si no ha llegado a COUNT_LIMIT, la salida se mantiene en 1
				boton_out <= 1;
			end
		end else begin // Si el boton_in no está presionado, la salida estará en 1 y el contador en 0
			boton_out <= 1;
			counter <= 0;
		end
	 end

endmodule