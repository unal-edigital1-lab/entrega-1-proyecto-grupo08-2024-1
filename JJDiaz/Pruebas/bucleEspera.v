module bucleEspera #(parameter num_commands = 3, //Número de comandos que se dan en la configuración inicial
			       num_data_all = 64,  //Número de datos por txt máximo 64
			       char_data = 8, //Número de caracteres a escribir máximo 8
			       num_cgram_addrs = 8, //Número de direcciones CGRAM a sobrescribir máximo 8
			       COUNT_MAX = 20000, //Divisor de frecuencia respecto al clk de la FPGA entre mas alto el número, más rápido el clk de la LCD
		     WAIT_TIME = 200)( //Tiempo que se muestra cada figura en pantalla
    input clk,            //clk de la FPGA
    input reset,          //Boton de reinicio vuelve todo a valores iniciales
    input [3:0] select_figures,  //Dato que se recibe del FSM total y determina el estado y la situación del gato
    input [1:0] sleep, // Dato que se recibe del FSM total y determina si el gato esta dormido, muerto o ninguno de las dos. Tiene prioridad sobre select_figures
    output reg rs,        //salida a la LCD
    output reg rw,        //Salida a la LCD
    output enable,        //Salida a la LCD
	output reg [7:0] data //Salida a la LCD
);

// Definir los estados del controlador
localparam IDLE = 0;
localparam INIT_CONFIG = 1; 
localparam CLEAR_COUNTERS0 = 2; 
localparam SELECT_VIEW = 3;
localparam CREATE_CHARS = 4; 
localparam CLEAR_COUNTERS1 = 5; 
localparam SET_CURSOR_AND_WRITE = 6; 
localparam SHOW_NOTHING = 7; 
localparam WAIT = 8; 

//Definir los sub estados de SET_CURSOR_AND_WRITE
localparam SET_CGRAM_ADDR = 0;
localparam WRITE_CHARS = 1;
localparam SET_CURSOR = 2;
localparam WRITE_LCD = 3;


// Direcciones de escritura de la CGRAM 
localparam CGRAM_ADDR0 = 8'h40;
localparam CGRAM_ADDR1 = 8'h48;
localparam CGRAM_ADDR2 = 8'h50;
localparam CGRAM_ADDR3 = 8'h58;
localparam CGRAM_ADDR4 = 8'h60;
localparam CGRAM_ADDR5 = 8'h68;
localparam CGRAM_ADDR6 = 8'h70;
localparam CGRAM_ADDR7 = 8'h78;

//Registros necesarios indicando su cantidad de bits	
reg [3:0] fsm_state; //Cnatidad de estados del FSM de 4 bits
reg [3:0] next;
reg clk_16ms; //Clk que toma en cuenta el código para usar la LCD (Clk de la FPGA pasado por el divisor de frecuencia)

// Definir un contador para el divisor de frecuencia
reg [$clog2(COUNT_MAX)-1:0] counter_div_freq;

// Comandos de configuración
localparam CLEAR_DISPLAY = 8'h01;
localparam SHIFT_CURSOR_RIGHT = 8'h06;
localparam DISPON_CURSOROFF = 8'h0C;
localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;


// Definir un contador para controlar el envío de comandos
reg [$clog2(num_commands):0] command_counter;

// Definir un contador para controlar el envío de cada fila de datos
reg [$clog2(num_data_all):0] data_counter;

// Definir un contador para controlar el envío de caracteres a la CGRAM
reg [$clog2(char_data):0] char_counter;

// Definir un contador para controlar el envío de cuantos CGRAM requiere
reg [$clog2(num_cgram_addrs):0] cgram_addrs_counter;

//Definir un contador para controlar la visualización de las figuras	
reg [$clog2(WAIT_TIME)-1:0] wait_counter;




// Banco de registros donde se guardan los txt
reg [7:0] data_memory [0: num_data_all-1];
reg [7:0] data_memory2 [0: num_data_all-1];
reg [7:0] gatoFeliz [0: num_data_all-1];
reg [7:0] gatoTriste [0: num_data_all-1];
reg [7:0] gatoNeutro [0: num_data_all-1];
reg [7:0] energia [0: num_data_all-1];
reg [7:0] diversion [0: num_data_all-1];
reg [7:0] alimentacion [0: num_data_all-1];
reg [7:0] salud [0: num_data_all-1];
reg [7:0] nState [0: num_data_all-1];
reg [7:0] gatoDormido [0: num_data_all-1];
reg [7:0] zzz [0: num_data_all-1];
reg [7:0] gatoMuerto [0: num_data_all-1];
reg [7:0] muerte [0: num_data_all-1];
reg [7:0] config_memory [0:num_commands-1]; 
reg [7:0] cgram_addrs [0: num_cgram_addrs-1];

//
reg [1:0] create_char_task;
reg init_config_executed;
wire done_cgram_write;
reg done_lcd_write;
reg wait_done;
reg change;
integer i;


reg [1:0] select_fig1;
reg [1:0] select_fig2; 

initial begin
    fsm_state <= IDLE;
	    data <= 'b0;
	    command_counter <= 'b0;
	    data_counter <= 'b0;
	    rw <= 0;
	    rs <= 0;
	    clk_16ms <= 'b0;
	    counter_div_freq <= 'b0;
	    init_config_executed <= 'b0;
	    cgram_addrs_counter <= 'b0; 
	    char_counter <= 'b0;
	    done_lcd_write <= 1'b0; 
	    change <= 'b0;
	    wait_counter <= 'b0;
	    wait_done <= 1'b0;

    create_char_task <= SET_CGRAM_ADDR;
	 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoFelizF.txt", gatoFeliz);//
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoTristeF.txt", gatoTriste);//
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoNeutroF.txt", gatoNeutro);//
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/ComidaF.txt", alimentacion);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/EnergiaF.txt", energia);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/SaludF.txt", salud);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/DiversionF.txt", diversion);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/EstadoNeutroF.txt", nState);//
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoDormido.txt", gatoDormido);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/ZZZ.txt", zzz);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoMuerto.txt", gatoMuerto);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/Muerte.txt", muerte);// 
			
	config_memory[0] <= LINES2_MATRIX5x8_MODE8bit;
	config_memory[1] <= DISPON_CURSOROFF;
	config_memory[2] <= CLEAR_DISPLAY;

	cgram_addrs[0] <= CGRAM_ADDR0;
	cgram_addrs[1] <= CGRAM_ADDR1;
	cgram_addrs[2] <= CGRAM_ADDR2;
	cgram_addrs[3] <= CGRAM_ADDR3;
	cgram_addrs[4] <= CGRAM_ADDR4;
	cgram_addrs[5] <= CGRAM_ADDR5;
	cgram_addrs[6] <= CGRAM_ADDR6;
	cgram_addrs[7] <= CGRAM_ADDR7;
end

always @(posedge clk) begin
    if (counter_div_freq == COUNT_MAX-1) begin
        clk_16ms <= ~clk_16ms;
        counter_div_freq <= 0;
    end else begin
        counter_div_freq <= counter_div_freq + 1;
    end
end


always @(*) begin
    select_fig1 = select_figures[3:2]; // Primeros 2 bits determinan la figura 1
    select_fig2 = select_figures[1:0]; // Últimos 3 bits determinan la figura 2
end

always @(posedge clk_16ms)begin
    if(reset == 0)begin
        fsm_state <= IDLE;
    end else begin
        fsm_state <= next;
    end
end

always @(*) begin
    case(fsm_state)
        IDLE: begin
            next <= (init_config_executed)? CREATE_CHARS : INIT_CONFIG;
        end
        INIT_CONFIG: begin 
            next <= (command_counter == num_commands)? CLEAR_COUNTERS0 : INIT_CONFIG;
        end
        CLEAR_COUNTERS0: begin
            next <= SELECT_VIEW;
        end
        SELECT_VIEW: begin
            next <= CREATE_CHARS;
        end
        CREATE_CHARS:begin
            next <= (done_cgram_write)? CLEAR_COUNTERS1 : CREATE_CHARS;
        end
        CLEAR_COUNTERS1: begin
            next <= SET_CURSOR_AND_WRITE;
        end
        SET_CURSOR_AND_WRITE: begin 
            next <= (done_lcd_write)? WAIT: SET_CURSOR_AND_WRITE;
        end
        WAIT: begin
	    next <= (wait_done)? CLEAR_COUNTERS0 : SHOW_NOTHING;
	end
	SHOW_NOTHING: begin
	    next <= WAIT;
	end
        default: next = IDLE;
    endcase
end

always @(posedge clk_16ms) begin
    if (reset == 0) begin
	command_counter <= 'b0;
	data_counter <= 'b0;
	data <= 'b0;
	char_counter <= 'b0;
	init_config_executed <= 'b0;
	cgram_addrs_counter <= 'b0;
	done_lcd_write <= 1'b0; 
	change <= 'b0;
	wait_counter <= 'b0;
	wait_done <= 1'b0;
	
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoFelizF.txt", gatoFeliz);//
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoTristeF.txt", gatoTriste);//
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoNeutroF.txt", gatoNeutro);//
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/ComidaF.txt", alimentacion);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/EnergiaF.txt", energia);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/SaludF.txt", salud);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/DiversionF.txt", diversion);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/EstadoNeutroF.txt", nState);//
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoDormido.txt", gatoDormido);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/ZZZ.txt", zzz);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoMuerto.txt", gatoMuerto);// 
	$readmemb("/home/gussi/Documents/unal/digital/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/Muerte.txt", muerte);//  
    end else begin
	    
        case (next)
            IDLE: begin
		char_counter <= 'b0;
		command_counter <= 'b0;
		data_counter <= 'b0;
		rs <= 'b0;
		cgram_addrs_counter <= 'b0;
		done_lcd_write <= 1'b0;
		change <= 'b0;
		wait_counter <= 'b0;
		wait_done <= 1'b0;
            end
            INIT_CONFIG: begin
		rs <= 'b0;
		data <= config_memory[command_counter];
		command_counter <= command_counter + 1;
                if(command_counter == num_commands-1) begin
                    init_config_executed <= 1'b1;
                end
            end
            CLEAR_COUNTERS0: begin
                data_counter <= 'b0;
                char_counter <= 'b0;
                create_char_task <= SET_CGRAM_ADDR;
                cgram_addrs_counter <= 'b0;
                done_lcd_write <= 1'b0;
		rs <= 0;
		data <= CLEAR_DISPLAY;
		wait_counter <= 'b0;
		wait_done <= 1'b0;
					 
            end

            SELECT_VIEW: begin
	    	//Se da prioridad a si esta dormido o muerto
                if (sleep == 2'b01) begin //Dormido
			for (i = 0; i < num_data_all; i = i +1 )begin
				data_memory[i] <= gatoDormido[i];
				data_memory2[i] <= zzz[i];
			end
		end else if (sleep == 2'b11) begin //Muerto
			for (i = 0; i < num_data_all; i = i+1)begin
				data_memory[i] <= gatoMuerto[i];
				data_memory2[i] <= muerte[i];
			end
		 end else begin //Si no esta ni muerto ni dormido continuo con los estador normales
			 
			 case(select_fig1) //Determina si el gato está feliz o triste, además de un estado inicial Neutro
	                    2'b01: begin //Gato Feliz
	                        for (i = 0; i < num_data_all; i = i + 1) begin
	                            data_memory[i] <= gatoFeliz[i];
	                        end
	                    end
	                    2'b00: begin //Gato Triste
	                        for (i = 0; i < num_data_all; i = i + 1) begin
	                            data_memory[i] <= gatoTriste[i];
	                        end
	                    end
	                    2'b10: begin // Gato Neutro y Estado Neutro
	                        for (i = 0; i < num_data_all; i = i + 1) begin
	                            data_memory[i] <= gatoNeutro[i];
	                            data_memory2[i] <= nState[i];
	                        end
	                    end
	                endcase
			 
			 case(select_fig2) //Determina el estado que se desea mostrar
	                    2'b01: begin //Estado de energía
	                        for (i = 0; i < num_data_all; i = i + 1) begin
	                            if(select_fig1 != 2'b10)begin
	                            data_memory2[i] <= energia[i];
	                            end
	                        end
	                    end
	                    2'b11: begin //Estado de Diversión
	                        for (i = 0; i < num_data_all; i = i + 1) begin
	                            if(select_fig1 != 2'b10)begin
	                            data_memory2[i] <= diversion[i];
	                            end
	                        end
	                    end
	                    2'b10: begin //Estado de Alimentación
	                        for (i = 0; i < num_data_all; i = i + 1) begin
	                            if(select_fig1 != 2'b10)begin
	                            data_memory2[i] <= alimentacion[i];
	                            end
	                        end
	                    end
	                    2'b00: begin //Estado de Salud
	                        for (i = 0; i < num_data_all; i = i + 1) begin
	                            if(select_fig1 != 2'b10)begin
	                                data_memory2[i] <= salud[i];
	                            end
	                        end
	                    end
	                    
	                endcase
                end
            end

            CREATE_CHARS: begin
                case(create_char_task)
                    SET_CGRAM_ADDR: begin
                        rs <= 'b0; data <= cgram_addrs[cgram_addrs_counter]; 
                        create_char_task <= WRITE_CHARS; 
                    end
                    WRITE_CHARS: begin
                        rs <= 1; 
                        if(change == 'b0) begin
			        data <= data_memory[data_counter];
                        end else begin
				data <= data_memory2[data_counter];
                        end
                        data_counter <= data_counter + 1;
                        if(char_counter == char_data -1) begin
                            char_counter = 0;
                            create_char_task <= SET_CGRAM_ADDR;
                            cgram_addrs_counter <= cgram_addrs_counter + 1;
                        end else begin
                            char_counter <= char_counter +1;
                        end
                    end
                endcase
            end
	    CLEAR_COUNTERS1: begin
			data_counter <= 'b0;
			char_counter <= 'b0;
			create_char_task <= SET_CURSOR;
			cgram_addrs_counter <= 'b0;
			rs <= 0;
			data <= DISPON_CURSOROFF;
	    end
            SET_CURSOR_AND_WRITE: begin
                case(create_char_task)
			SET_CURSOR: begin
			if (change == 'b0)begin
				rs <= 0;
				data <= (cgram_addrs_counter > 3)? 8'h80 + (cgram_addrs_counter%4) + 8'h40 : 8'h80 + (cgram_addrs_counter%4);
			end else begin
				rs <= 0;
				data <= (cgram_addrs_counter > 3)? 8'h84 + (cgram_addrs_counter%4) + 8'h40 : 8'h84 + (cgram_addrs_counter%4);
			end
                        create_char_task <= WRITE_LCD; 
                    end
                    WRITE_LCD: begin
                        rs <= 1; data <=  8'h00 + cgram_addrs_counter;
                        if(cgram_addrs_counter == num_cgram_addrs-1)begin
				cgram_addrs_counter = 'b0;
				if(change == 'b0)begin
					change <= change +1;
				end else begin
					change <= 'b0;
				end
				done_lcd_write <= 1'b1;
                        end else begin
				cgram_addrs_counter <= cgram_addrs_counter + 1;
                        end
				create_char_task <= SET_CURSOR; 
                    end
                endcase
            end
	    WAIT: begin
		if(wait_counter == WAIT_TIME)begin
			wait_done <= 1'b1;
		end
		rs <= 1;
		data <= 'b0;
		wait_counter <= wait_counter +1;
	    end
	    SHOW_NOTHING: begin
		rs <= 0;
		data <= 8'hC4;
            end
        endcase
    end
end

assign enable = clk_16ms;
assign done_cgram_write = (data_counter == num_data_all-1)? 'b1 : 'b0;

endmodule
