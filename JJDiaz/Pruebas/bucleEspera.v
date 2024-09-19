module bucleEspera #(parameter num_commands = 3, 
                                      num_data_all = 64,  
                                      char_data = 8, 
                                      num_cgram_addrs = 8,
                                      COUNT_MAX = 20000,
												  WAIT_TIME = 200)(
    input clk,            
    input reset,          
    //input ready_i,
	 input [3:0] select_figures, //DEBE ESTAR EN LA PRUEBA FINAL
	 input [2:0] sleep,
    output reg rs,        
    output reg rw,
    //output reg enable, //NO ACTIVAR 
	 output enable,
    output reg [7:0] data
);

// Definir los estados del controlador
localparam IDLE = 0;
localparam INIT_CONFIG = 1; //1
localparam CLEAR_COUNTERS0 = 2; //2
localparam SELECT_VIEW = 3;
localparam CREATE_CHARS = 4; //3
localparam CLEAR_COUNTERS1 = 5; //4
localparam SET_CURSOR_AND_WRITE = 6; //5
localparam SHOW_NOTHING = 7; //6
localparam WAIT = 8; //7


localparam SET_CGRAM_ADDR = 0;
localparam WRITE_CHARS = 1;
localparam SET_CURSOR = 2;
localparam WRITE_LCD = 3;
//localparam CHANGE_LINE = 4;

// Direcciones de escritura de la CGRAM 
localparam CGRAM_ADDR0 = 8'h40;
localparam CGRAM_ADDR1 = 8'h48;
localparam CGRAM_ADDR2 = 8'h50;
localparam CGRAM_ADDR3 = 8'h58;
localparam CGRAM_ADDR4 = 8'h60;
localparam CGRAM_ADDR5 = 8'h68;
localparam CGRAM_ADDR6 = 8'h70;
localparam CGRAM_ADDR7 = 8'h78;

reg [3:0] fsm_state;
reg [3:0] next;
reg clk_16ms;

// Definir un contador para el divisor de frecuencia
reg [$clog2(COUNT_MAX)-1:0] counter_div_freq;

// Comandos de configuración
localparam CLEAR_DISPLAY = 8'h01;
localparam SHIFT_CURSOR_RIGHT = 8'h06;
localparam DISPON_CURSOROFF = 8'h0C;
localparam DISPON_CURSORON = 8'h0E;
localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;
//localparam LINES2_MATRIX5x8_Mwait_done <= 1'b0;ODE4bit = 8'h28;
//localparam LINES1_MATRIX5x8_MODE8bit = 8'h30;
//localparam LINES1_MATRIX5x8_MODE4bit = 8'h20;
localparam START_1LINE = 8'h80;
localparam START_2LINE = 8'hC0;

// Definir un contador para controlar el envío de comandos
reg [$clog2(num_commands):0] command_counter;

// Definir un contador para controlar el envío de cada fila de datos
reg [$clog2(num_data_all):0] data_counter;

// Definir un contador para controlar el envío de caracteres a la CGRAM
reg [$clog2(char_data):0] char_counter;

// Definir un contador para controlar el envío de cuantos CGRAM requiere
reg [$clog2(num_cgram_addrs):0] cgram_addrs_counter;

reg [$clog2(WAIT_TIME)-1:0] wait_counter;

reg wait_done;


// Banco de registros
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
reg [7:0] config_memory [0:num_commands-1]; 
reg [7:0] cgram_addrs [0: num_cgram_addrs-1];

reg [1:0] create_char_task;
reg init_config_executed;
wire done_cgram_write;
reg done_lcd_write;
reg change;
integer i;

//reg [3:0] select_figures; //PRUEBAS ONLY, SE DEBE QUITAR

reg [1:0] select_fig1;
reg [1:0] select_fig2; 

initial begin
    fsm_state <= IDLE;
	 //fsm_state <= INIT_CONFIG;
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
	 //select_figures <= 4'b0100; //SOLO PARA PRUEBAS, SE DEBE QUITAR
	 wait_counter <= 'b0;
	 wait_done <= 1'b0;
	 //enable <= 'b0;

    create_char_task <= SET_CGRAM_ADDR;
	 
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoFelizF.txt", gatoFeliz);//
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoTristeF.txt", gatoTriste);//
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoNeutroF.txt", gatoNeutro);//
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/ComidaF.txt", alimentacion);// 
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/EnergiaF.txt", energia);// 
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/SaludF.txt", salud);// 
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/DiversionF.txt", diversion);// 
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/EstadoNeutroF.txt", nState);//
            $readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoDormido.txt", gatoDormido);// 
            $readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/ZZZ.txt", zzz);// 
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoMuerto.txt", gatoMuerto);// 
            $readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/Muerto.txt", muerte);// 
			
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
		  //fsm_state <= INIT_CONFIG;
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
        //default: next = INIT_CONFIG;
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
		  //enable <= 'b0;
		  
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoFelizF.txt", gatoFeliz);//
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoTristeF.txt", gatoTriste);//
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoNeutroF.txt", gatoNeutro);//
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/ComidaF.txt", alimentacion);// 
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/EnergiaF.txt", energia);// 
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/SaludF.txt", salud);// 
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/DiversionF.txt", diversion);// 
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/EstadoNeutroF.txt", nState);//
            $readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoDormido.txt", gatoDormido);// 
            $readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/ZZZ.txt", zzz);// 
			$readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/GatoMuerto.txt", gatoMuerto);// 
            $readmemb("C:/Users/Isabela Mendoza/Documents/GitHub/entrega-1-proyecto-grupo08-2024-1/JJDiaz/Pruebas/Muerto.txt", muerte);//  
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
					 //enable <= 'b0;
            end
            INIT_CONFIG: begin
                rs <= 'b0;
			    data <= config_memory[command_counter];
				 command_counter <= command_counter + 1;
				 //enable <= 'b1;
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
                //rs <= 'b0;
					 rs <= 0;
                data <= CLEAR_DISPLAY;
					 wait_counter <= 'b0;
					 wait_done <= 1'b0;
					 //enable <= 'b0;
					 
            end

            SELECT_VIEW: begin
                if (sleep == 2'b01) begin //Dormido
                    for (i = 0; i < num_data_all; i = i +1 )begin
                        data_memory[i] <= gatoDormido[i];
                        data_memory2[i] <= zzz[i];
                    end
                end else if (sleep == 2'b11) begin
						for (i = 0; i < num_data_all; i = i+1)begin
								data_memory[i] <= gatoMuerto[i];
								data_memory2[i] <= muerto[i];
						end
					 end else begin
                case(select_fig1) //Esta es la linea 269
                    2'b01: begin
                        for (i = 0; i < num_data_all; i = i + 1) begin
                            data_memory[i] <= gatoFeliz[i];
                        end
                    end
                    2'b00: begin
                        for (i = 0; i < num_data_all; i = i + 1) begin
                            data_memory[i] <= gatoTriste[i];
                        end
                    end
                    2'b10: begin
                        for (i = 0; i < num_data_all; i = i + 1) begin
                            data_memory[i] <= gatoNeutro[i];
                            data_memory2[i] <= nState[i];
                        end
                    end
                endcase
                case(select_fig2)
                    2'b01: begin
                        for (i = 0; i < num_data_all; i = i + 1) begin
                            if(select_fig1 != 2'b10)begin
                            data_memory2[i] <= energia[i];
                            end
                        end
                    end
                    2'b11: begin
                        for (i = 0; i < num_data_all; i = i + 1) begin
                            if(select_fig1 != 2'b10)begin
                            data_memory2[i] <= diversion[i];
                            end
                        end
                    end
                    2'b10: begin
                        for (i = 0; i < num_data_all; i = i + 1) begin
                            if(select_fig1 != 2'b10)begin
                            data_memory2[i] <= alimentacion[i];
                            end
                        end
                    end
                    2'b00: begin
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
								//enable <= 'b1;
                        create_char_task <= WRITE_CHARS; 
                    end
                    WRITE_CHARS: begin
                        rs <= 1; 
                        if(change == 'b0) begin
				            data <= data_memory[data_counter];
						  //enable <= 'b1;
                        end else begin
							data <= data_memory2[data_counter];
							//enable <= 'b1;
                        end
                        data_counter <= data_counter + 1;
                        if(char_counter == char_data -1) begin
                            char_counter = 0;
                            create_char_task <= SET_CGRAM_ADDR;
                            cgram_addrs_counter <= cgram_addrs_counter + 1;
                        end else begin
                            char_counter <= char_counter +1;
                            //rs <= 0; data <= DISPON_CURSOROFF;
                        end
                    end
                endcase
            end
            CLEAR_COUNTERS1: begin
                //rs = 'b0; data <= 'b0;
                data_counter <= 'b0;
                char_counter <= 'b0;
                create_char_task <= SET_CURSOR;
                cgram_addrs_counter <= 'b0;
					 //enable <= 'b0;
					 rs <= 0;
					 data <= DISPON_CURSOROFF;
            end
            SET_CURSOR_AND_WRITE: begin
                case(create_char_task)
					SET_CURSOR: begin
								if (change == 'b0)begin
                                    rs <= 0;
								    data <= (cgram_addrs_counter > 3)? 8'h80 + (cgram_addrs_counter%4) + 8'h40 : 8'h80 + (cgram_addrs_counter%4);
								//enable <= 'b1;
								end else begin
								    rs <= 0;
								    data <= (cgram_addrs_counter > 3)? 8'h84 + (cgram_addrs_counter%4) + 8'h40 : 8'h84 + (cgram_addrs_counter%4);
								//enable <= 'b1;
								end
                        create_char_task <= WRITE_LCD; 
                    end
                    WRITE_LCD: begin
                        rs <= 1; data <=  8'h00 + cgram_addrs_counter;
								//enable <= 'b1;
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
					//enable <= 'b0;
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
