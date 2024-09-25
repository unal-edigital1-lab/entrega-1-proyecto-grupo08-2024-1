`timescale 1ns / 1ps

module tb_bucleEspera;

    // Inputs
    reg clk;
    reg reset;
    reg [3:0]select_figures;
    reg [1:0]sleep;
		
    // Outputs
    wire rs;
    wire rw;
    wire enable;
    wire [7:0] data;

    // Instantiate the Unit Under Test (UUT)
    bucleEspera uut (
        .clk(clk), 
        .reset(reset), 
        .select_figures(select_figures), 
        .rs(rs), 
        .rw(rw), 
        .enable(enable), 
        .data(data),
        .sleep(sleep)
    );

    // Clock generation
    always #1 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        select_figures = 4'b1000;
        //sleep = 2'b00;

        // Apply reset
        reset = 1;
        #10 reset = 0;
        #10 reset = 1;


        // Test case 1: select_fig1 = 00 (Gato Feliz), select_fig2 = 000 (Energia)
        #10000000 select_figures = 4'b1000;  
		  
	#10000000 select_figures = 4'b1000;  
	#10000000 select_figures = 4'b1000;  
	#10000000 select_figures = 4'b1000;  
	#10000000 select_figures = 4'b1000;
	#10000000 select_figures = 4'b1000;
	#10000000 select_figures = 4'b1000;
	#10000000 select_figures = 4'b1000;	
	#10000000 select_figures = 4'b1000;
	#10000000 select_figures = 4'b1000;		
	
	//#10000000 select_figures = 4'b0101; //Si se quiere probar la visualización 1
	//#10000000 sleep = 2'b11; //Si se quiere probar la visualización 2
	
	
	#10000000 reset = 1;
	#1000000 reset = 0;
	#1000000 reset = 1;
  
    end

	 initial begin: TEST_CASE          // Bloque de código ejecutado al realizar la simulación
     $dumpfile("tb_bucleEspera.vcd");  // Almacena los resultados de la simulación en el archivo BCDtoSSeg_TB.vcd
	 $dumpvars(-1, uut);             // Indica que todas las variables y sus valores van a guardarse en el archivo anterior
	 #(200000000) $finish;// La simulación tendrá una duración de 200 unidades de tiempo (200 ns)
   end
	 
endmodule
