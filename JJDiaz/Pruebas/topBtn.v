module topBtn(

    input clk,
    input btn_heal,
    input btn_ali,
    input btn_RST,
    input btn_TST,

    /*output reg btn_salud,
    output reg btn_hambre,
    output reg btn_reset,
    output reg btn_test*/
	 
	 /*output reg ledSalud,
	 output reg ledHambre,
	 output reg ledReset,
	 output reg ledTest*/
	 
     //FSM
    //output [3:0] display_out,
    output [6:0] seg_display,
    output clk_out,       // Reloj de salida de 6.67 Hz
	 output an,

     //BucleEspera
     input reset,
     //input [3:0] select_figures,
     output rs,
     output rw,
     output [7:0] data,
     output enable,
	  
	  //Ultrasonido
	 input echo,
    output trig,
    output led

);

	
    
    /*initial begin
        btn_salud = 0;
        btn_hambre = 0;
        btn_reset = 0;
        btn_test = 0;
    end*/

    /*reg heal;
    reg ali;
    reg RST;
    reg TST;*/
	 
     wire [3:0] display_out;

	wire btn_salud;
	wire btn_hambre;
   wire btn_reset;
   wire btn_test;
	
	wire sens_ult;

    btnAntirebote #(50000) B_heal (.clk(clk), .boton_in(btn_heal), .boton_out(btn_salud));
    btnAntirebote #(50000) B_ali  (.clk(clk), .boton_in(btn_ali), .boton_out(btn_hambre));
    btnRT B_rst (.clk(clk), .boton_in(btn_RST), .boton_out(btn_reset));
    btnRT B_tst (.clk(clk), .boton_in(btn_TST), .boton_out(btn_test)); 

    tamagotchi_fsm #(7500000) U_tamagotchi(
       .clk(clk),
		 .ult(sens_ult),
       .btn_salud(btn_salud),
       .btn_ali(btn_hambre),
       .display_out(display_out),
       .seg_display(seg_display),
       .clk_out(clk_out),
       .an(an)
	);

    bucleEspera #(.num_commands(3), .num_data_all(64), .char_data(8), .num_cgram_addrs(8), .COUNT_MAX(50000), .WAIT_TIME(200)) U_bucleEspera(
        .clk(clk),
        .reset(reset),
        .select_figures(display_out),
        .rs(rs),
        .rw(rw),
        .enable(enable),
        .data(data)
    );
    top U_top(
		.clk(clk),
        .trig(trig),
        .echo(echo),
        .sens_ult(sens_ult),
        .led(led)
	 );

 
        
        assign btn_salud = ~btn_salud;
        assign btn_hambre = ~btn_hambre;
        assign btn_reset = ~btn_reset;
        assign btn_test = ~btn_test;
		  
		  
		  //leds
		  
		  /*ledSalud = heal;
		  ledHambre = ali;
		  ledReset = RST;
		  ledTest = TST;*/


    
	



endmodule