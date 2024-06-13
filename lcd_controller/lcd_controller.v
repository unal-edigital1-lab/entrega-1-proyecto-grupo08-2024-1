module lcd_controller #(parameter COUNT_MAX = 8000000)(
	input clk,
	output rs, ena, rw,
	output [7:0] dat
);

	parameter INIT = 0;
	
	reg [7:0] data;
	reg rs_reg, rw_reg; //registro asociado a la salida. Pin que dice si lo q estoy mandando es un dato de config o un dato para mostrar 
	//reg rw_reg; //Para escritura siempre es en 0
	reg [$clog2(COUNT_MAX) -1:0] counter;//Cuantos bits necesito para contar hasta COUNTER_MAX(800000)
	reg [5:0] current, next;
	reg clkr;//Segundo clock generado por el divisor
	
	initial begin
		data = 0;
		rs_reg = 0;
		rw_reg = 0;
		counter = 0;
		current = 0;
		next = 0;
		clkr = 0;
	end
	
	always @(posedge clk) begin
		if (counter == COUNT_MAX-1) begin
			clkr = ~clkr;
			counter <= 0;
		end else begin
			counter = counter + 1;
		end
	end
	
	always @(posedge clkr)begin
		current = next;
		case(current)
				0: begin rs_reg <= 0; data <= 8'h38; next<=1; end   //Modo de 8 bit, 2 lineas , 5*8 pixeles
				1: begin rs_reg <= 0; data <= 8'h06; next<=2; end   //Desplazar a la derecha
				2: begin rs_reg <= 0; data <= 8'h0C; next<=3; end
				3: begin rs_reg <= 0; data <= 8'h01; next<=4; end
				4: begin rs_reg <= 1; data <= "H"; next<=5; end
				5: begin rs_reg <= 1; data <= "o"; next<=6; end
				6: begin rs_reg <= 1; data <= "l"; next<=7; end
				7: begin rs_reg <= 1; data <= "a"; next<=8; end
				8: begin rs_reg <= 1; data <= " "; next<=9; end
			9: begin rs_reg <= 1; data <= "V"; next<=10; end
			10: begin rs_reg <= 1; data <= "o"; next<=11; end
			11: begin rs_reg <= 1; data <= "y"; next<=12; end
			12: begin rs_reg <= 1; data <= " "; next<=13; end
			13: begin rs_reg <= 1; data <= "a"; next<=14; end
			14: begin rs_reg <= 1; data <= " "; next<=15; end
			15: begin rs_reg <= 1; data <= "s"; next<=16; end
			16: begin rs_reg <= 1; data <= "e"; next<=17; end
			17: begin rs_reg <= 1; data <= "r"; next<=18; end
			18: begin rs_reg <= 1; data <= "."; next<=19; end
			19: begin rs_reg <= 1; data <= "."; next<=20; end
			20: begin rs_reg <= 0; data <= 8'hC0; next<=21; end
			21: begin rs_reg <= 1; data <= "t"; next<=22; end
			22: begin rs_reg <= 1; data <= "u"; next<=23; end
			23: begin rs_reg <= 1; data <= " "; next<=24; end
			24: begin rs_reg <= 1; data <= "t"; next<=25; end
			25: begin rs_reg <= 1; data <= "a"; next<=26; end
			26: begin rs_reg <= 1; data <= "m"; next<=27; end
			27: begin rs_reg <= 1; data <= "g"; next<=28; end
			28: begin rs_reg <= 1; data <= "o"; next<=29; end
			29: begin rs_reg <= 1; data <= "t"; next<=30; end
			30: begin rs_reg <= 1; data <= "c"; next<=31; end
			31: begin rs_reg <= 1; data <= "h"; next<=32; end
			32: begin rs_reg <= 1; data <= "i"; next<=33; end
			33: begin rs_reg <= 1; data <= " "; next<=34; end
			34: begin rs_reg <= 1; data <= "<"; next<=35; end
			35: begin rs_reg <= 1; data <= "3"; next<=36; end
			36: begin rs_reg <= 1; data <= " "; next<=INIT; end
				default: next = INIT;
			endcase
		end
		
		assign ena = clkr;
		assign rw = rw_reg;
		assign rs = rs_reg;
		assign dat = data;
endmodule