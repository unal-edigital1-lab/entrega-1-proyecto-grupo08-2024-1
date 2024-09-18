module tamagotchi_fsm (
    input wire btn_salud,
	input wire btn_ali,
	input wire ult,
    input wire gyro,
	input wire btn_reset,
	input wire btn_test,
    input wire clk, // Reloj de entrada de 50 MHz
    output reg [3:0] display_out,
	output reg [1:0] display_out2,
    output reg [6:0] seg_display,	 // Salida para la regleta de 7 segmentos
    output reg clk_out,       // Reloj de salida de 6.67 Hz
		output reg an,
    output reg tstled
    );

    // Definición de niveles separados para cada estado
    reg [3:0] nivel_salud;
    reg [3:0] nivel_energia;
    reg [3:0] nivel_hambre;
    reg [3:0] nivel_diversion;

    reg [7:0] timer_salud, timer_energia, timer_energia2, timer_hambre, timer_diversion, timer_diversion2; // Contadores de tiempo
    reg  test_mode;

    // Parámetro para contar los ciclos del reloj de entrada
    reg [22:0] contador;   // Suficientemente grande para contar hasta 7,500,000
    parameter DIVISOR = 7500000;
    //parameter DIVISOR = 15000000;
    //parameter DIVISOR = 2500000;

    // Inicialización de valores
	
    initial begin
        nivel_salud <= 4'b0011;   // Nivel de Salud inicial en 8
        nivel_energia <= 4'b0100; // Nivel de Energía inicial en 8
        nivel_hambre <= 4'b0101;  // Nivel de Hambre inicial en 8
        nivel_diversion <= 4'b0110; // Nivel de Diversión inicial en 8
        timer_salud <= 0;
        timer_energia <= 0;
        timer_hambre <= 0;
        timer_diversion <= 0;
        display_out <= 4'b1000; // Mostrar Neutra y cara feliz por defecto
        test_mode <= 1'b0; // Iniciar en modo normal
        seg_display<= 7'b1111111; // Inicializar la regleta de 7 segmentos en 0

			contador = 0;
			clk_out = 0;
			an = 0;
			tstled <= 1;
    end
	 
    
    always @(posedge clk) begin
        if (contador == (DIVISOR - 1)) begin
            contador <= 0;
            clk_out <= ~clk_out; // Invierte el reloj de salida
        end else begin
            contador <= contador + 1;
        end
    end
    
    always @(posedge clk_out) begin
		// Manejo del test
		if (!btn_reset) begin // 5 segundos en binario es 101
            nivel_salud <= 4'b1000;   // Reiniciar nivel de Salud a 8
            nivel_energia <= 4'b1000; // Reiniciar nivel de Energía a 8
            nivel_hambre <= 4'b1000;  // Reiniciar nivel de Hambre a 8
            nivel_diversion <= 4'b1000; // Reiniciar nivel de Diversión a 8
            display_out <= 4'b1000; // Cara neutra
            test_mode <= 1'b0; // Salir del modo de prueba
            tstled <= 1;
        end
		  
		  //Manejo inicial del test
		  if (!btn_test) begin // 5 segundos en binario es 101
            test_mode <= 1'b1; // Activar modo de prueba
            tstled <= 0;
        end
		  
		  if (test_mode) begin
            // Modo test: Solo permitir niveles 1 o 10
            if (btn_salud && nivel_salud != 4'b0001) begin
                display_out[3:0] <= 4'b0000; // Mostrar Salud
                if (display_out == 4'b0100) begin
                    nivel_salud <= 4'b0001;
                end
            end
            if (btn_salud && nivel_salud != 4'b0001) begin
                display_out[3:0] <= 4'b0000; // Mostrar Salud
                if (display_out == 4'b0000) begin
                    nivel_salud <= 4'b0001;
                end
            end
            if (btn_salud && nivel_salud == 4'b0001) begin
                display_out[3:0] <= 4'b0000; // Mostrar Salud
                if (display_out == 4'b0000) begin
                    nivel_salud <= 4'b1010;
                end
            end
           
            if (btn_ali && nivel_hambre != 4'b0001) begin
                display_out[1:0] <= 2'b10; // Mostrar Hambre
                if (display_out == 3'b010) begin
                    nivel_hambre <= 4'b0001;
                end
            end
				
            if (btn_ali && nivel_hambre != 4'b0001) begin
                display_out[1:0] <= 2'b10; // Mostrar Hambre
                if (display_out == 3'b110) begin
                    nivel_hambre <= 4'b0001;
                end
            end
				
            if (btn_ali && nivel_hambre == 4'b0001) begin
                display_out[1:0] <= 2'b10; // Mostrar Hambre
                if (display_out == 3'b010) begin
                    nivel_hambre <= 4'b1010;
                end
            end
            if (ult && nivel_diversion != 4'b0001) begin
                display_out[1:0] <= 2'b11; // Mostrar Diversión
                if (display_out == 3'b011) begin
                    nivel_diversion <= 4'b0001;
                end
            end
            if (ult && nivel_diversion != 4'b0001) begin
                display_out[1:0] <= 2'b11; // Mostrar Diversión
                if (display_out == 3'b111) begin
                    nivel_diversion <= 4'b0001;
                end
            end
            if (ult && nivel_diversion == 4'b0001) begin
                display_out[1:0] <= 2'b11; // Mostrar Diversión
                if (display_out == 3'b011) begin
                    nivel_diversion <= 4'b1010;
                end
            end
            if (gyro && nivel_energia != 4'b0001) begin
                display_out[1:0] <= 2'b01; // Mostrar Diversión
                if (display_out == 3'b101) begin
                    nivel_energia <= 4'b0001;
                end
            end
            if (gyro && nivel_energia == 4'b0001) begin
                display_out[1:0] <= 2'b01; // Mostrar Diversión
                if (display_out == 3'b001) begin
                    nivel_energia <= 4'b1010;
                end
            end
        end else begin
	 
            // Modo normal: Incrementar el nivel del estado correspondiente, con límite de 10
            if (btn_salud && nivel_salud < 4'b0101) begin
                display_out <= 4'b0000; // Mostrar Salud
                if (display_out == 4'b0000) begin
                    nivel_salud <= nivel_salud + 1; // Aumentar nivel Salud
						  timer_salud <= 0;
                end
            end
				
            if (btn_salud && nivel_salud > 4'b0100) begin
                display_out <= 4'b0100; // Mostrar Salud
                if (nivel_salud < 4'b1010 && display_out == 4'b0100) begin
                    nivel_salud <= nivel_salud + 1; // Aumentar nivel Salud
						  timer_salud <= 0;
                end
            end
				
				if (btn_ali && nivel_hambre < 4'b0101) begin
                display_out <= 4'b0010; // Mostrar Hambre
                if (display_out == 4'b0010) begin
                    nivel_hambre <= nivel_hambre + 1; // Aumentar nivel Hambre
						  timer_hambre <= 0;
                end
            end
				
            if (btn_ali && nivel_hambre > 4'b0100) begin
                display_out <= 4'b0110; // Mostrar Hambre
                if (nivel_hambre < 4'b1010 && display_out == 4'b0110) begin
                    nivel_hambre <= nivel_hambre + 1; // Aumentar nivel Hambre
						  timer_hambre <= 0;
                end
            end
				
				if (ult && nivel_diversion < 4'b0101)begin
					display_out <= 4'b0011; // Mostrar Hambre
					if (display_out == 4'b0011 && timer_diversion2 == 6) begin
                   nivel_diversion <= nivel_diversion + 1; // Aumentar nivel Hambre
						 timer_diversion <= 0;
						 timer_diversion2 <= 0;
					end else timer_diversion2 <= timer_diversion2 + 1;
				end
				
				if (ult && nivel_diversion > 4'b0100)begin
					display_out <= 4'b0111; // Mostrar Hambre
					if (nivel_diversion < 4'b1010 && display_out == 4'b0111 && timer_diversion2 == 6) begin
                   nivel_diversion <= nivel_diversion + 1; // Aumentar nivel Hambre
						 timer_diversion <= 0;
						 timer_diversion2 <= 0;
					end else timer_diversion2 <= timer_diversion2 + 1;
				end

               if (!gyro && nivel_energia < 4'b0101)begin
						display_out <= 4'b0101; // Mostrar Hambre
                  display_out2 <= 2'b01; // Mostrar Dormido
						if (display_out2 == 2'b01 && timer_energia2 == 12) begin
							nivel_energia <= nivel_energia + 1; // Aumentar nivel Hambre
							timer_energia <= 0;
							timer_energia2 <= 0;
                  end else timer_energia2 <= timer_energia2 + 1;
				end

               if (!gyro && nivel_energia > 4'b0100)begin
						display_out <= 4'b0101; // Mostrar Hambre
                  display_out2 <= 2'b01; // Mostrar Dormido
					if (nivel_energia < 4'b1010 && display_out2 == 2'b01 && timer_energia2 == 12) begin
                        nivel_energia <= nivel_energia + 1; // Aumentar nivel Hambre
						timer_energia <= 0;
						timer_energia2 <= 0;
					end else timer_energia2 <= timer_energia2 + 1;
				end
			end

    // Manejo del decremento de los niveles en modo normal, con niveles separados
        if (!test_mode) begin
		    if (timer_salud == 24 && nivel_salud > 4'b0001) begin
                nivel_salud <= nivel_salud - 1;
                timer_salud <= 0;
            end else timer_salud <= timer_salud + 1;
				
				if (nivel_salud == 4'b0001)begin
					timer_salud <= 0;
				end
        if (gyro) begin
			display_out2 <= 2'b00;
		    if (timer_energia == 24 && nivel_energia > 4'b0001) begin
                nivel_energia <= nivel_energia - 1;
                timer_energia <= 0;
            end else timer_energia <= timer_energia + 1;
				
				if (nivel_energia == 4'b0001)begin
					timer_salud <= 0;
				end
        end

		    if (timer_hambre == 24 && nivel_hambre > 4'b0001) begin
                nivel_hambre <= nivel_hambre - 1;
                timer_hambre <= 0;
            end else timer_hambre <= timer_hambre + 1;
				
				if (nivel_hambre == 4'b0001)begin
					timer_salud <= 0;
				end

		    if (timer_diversion == 24 && nivel_diversion > 4'b0001) begin
                nivel_diversion <= nivel_diversion - 1;
                timer_diversion <= 0;
            end else timer_diversion <= timer_diversion + 1;
				
				if (nivel_diversion == 4'b0001)begin
					timer_diversion <= 0;
				end
				
        end
		  

    // Actualizar cara feliz/triste basado en el nivel del estado actual
        case (display_out[1:0])
            2'b00: display_out[2] <= (nivel_salud >= 4'd5) ? 1'b1 : 1'b0; // Salud
            2'b01: display_out[2] <= (nivel_energia >= 4'd5) ? 1'b1 : 1'b0; // Energía
            2'b10: display_out[2] <= (nivel_hambre >= 4'd5) ? 1'b1 : 1'b0; // Hambre
            2'b11: display_out[2] <= (nivel_diversion >= 4'd5) ? 1'b1 : 1'b0; // Diversión
        endcase

    // Control de la regleta de 7 segmentos para mostrar el nivel actual del estado seleccionado
        case (display_out[1:0])
            2'b00: seg_display <= get_seg_display(nivel_salud);   // Mostrar nivel de Salud
            2'b01: seg_display <= get_seg_display(nivel_energia); // Mostrar nivel de Energía
            2'b10: seg_display <= get_seg_display(nivel_hambre);  // Mostrar nivel de Hambre
            2'b11: seg_display <= get_seg_display(nivel_diversion); // Mostrar nivel de Diversión
        endcase
    end

    // Función para convertir el nivel en el formato de 7 segmentos
    function [6:0] get_seg_display;
        input [3:0] level;
        case (level)
            4'b0000: get_seg_display = 7'b1000000; // 0
            4'b0001: get_seg_display = 7'b1111001; // 1
            4'b0010: get_seg_display = 7'b0100100; // 2
            4'b0011: get_seg_display = 7'b0110000; // 3
            4'b0100: get_seg_display = 7'b0011001; // 4
            4'b0101: get_seg_display = 7'b0010010; // 5
            4'b0110: get_seg_display = 7'b0000010; // 6
            4'b0111: get_seg_display = 7'b1111000; // 7
            4'b1000: get_seg_display = 7'b0000000; // 8
            4'b1001: get_seg_display = 7'b0010000; // 9
            4'b1010: get_seg_display = 7'b0001000; // A (utilizado para representar 10)
            default: get_seg_display = 7'b1111111; // Apagar todos los segmentos
        endcase
    endfunction

endmodule

