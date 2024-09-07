`timescale 1ns / 1ps

module tb_bucleEspera;

    // Inputs
    reg clk;
    reg reset;
    reg ready_i;
	 reg [3:0]select_figures;
		
    // Outputs
    wire rs;
    wire rw;
    wire enable;
    wire [7:0] data;

    // Instantiate the Unit Under Test (UUT)
    bucleEspera uut (
        .clk(clk), 
        .reset(reset), 
        .ready_i(ready_i),
        .select_figures(select_figures), 
        .rs(rs), 
        .rw(rw), 
        .enable(enable), 
        .data(data)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        ready_i = 0;
        select_figures = 4'b0011;

        // Apply reset
        reset = 1;
        #10 reset = 0;
        #10 reset = 1;

        // Wait for system initialization
        #10 ready_i = 1; 

        // Test case 1: select_fig1 = 00 (Gato Feliz), select_fig2 = 000 (Energia)
        select_figures = 4'b0101; 
        #10000;
        
        // Test case 2: select_fig1 = 01 (Gato Triste), select_fig2 = 001 (Diversion)
        select_figures = 4'b0011; 
        #1000000;
        
        // Test case 3: select_fig1 = 11 (Gato Neutro), select_fig2 = 010 (Alimentacion)//SOLO NEUTRO
        select_figures = 4'b1000; 
        #1000000;

        // Test case 4: select_fig1 = 00 (Gato Feliz), select_fig2 = 011 (Salud)
        select_figures = 4'b0100; 
        #1000000;

        // Test case 5: select_fig1 = 01 (Gato Triste), select_fig2 = 100 (Estado Neutro)
        //select_figures = 4'b01100; 
        //#1000000;
        
        // Test case 6: select_fig1 = 11 (Gato Triste), select_fig2 = 000 (Alimentacion)
        select_figures = 4'b0010; 
        #1000000;
        
		  //#(10000000000000000000000) $finish;
		  
    end

	 initial begin: TEST_CASE          // Bloque de código ejecutado al realizar la simulación
     $dumpfile("tb_bucleEspera.vcd");  // Almacena los resultados de la simulación en el archivo BCDtoSSeg_TB.vcd
	 $dumpvars(-1, uut);             // Indica que todas las variables y sus valores van a guardarse en el archivo anterior
	 #(10000000) $finish;// La simulación tendrá una duración de 200 unidades de tiempo (200 ns)
   end
	 
endmodule
