module topBtn(
    //botones de Entrada
    input clk, 
    input btn_heal,
    input btn_ali,
    input btn_RST,
    input btn_TST,
    // Señales de salida
    output reg btn_salud,
    output reg btn_hambre,
    output reg btn_reset,
    output reg btn_test,
	 //Leds para ver  las salidas
	 output reg ledSalud,
	 output reg ledHambre,
	 output reg ledReset,
	 output reg ledTest

);
    
    initial begin //Salidas están en 0
        btn_salud = 0;
        btn_hambre = 0;
        btn_reset = 0;
        btn_test = 0;
    end
    //Wires que controlaran las salidas de los módulos
    wire heal;
    wire ali;
    wire RST;
    wire TST;

    btnAntirebote #(50000) B_heal (.clk(clk), .boton_in(btn_heal), .boton_out(heal));
    btnAntirebote #(50000) B_ali  (.clk(clk), .boton_in(btn_ali), .boton_out(ali));
    btnRT B_rst (.clk(clk), .boton_in(btn_RST), .boton_out(RST));
    btnRT B_tst (.clk(clk), .boton_in(btn_TST), .boton_out(TST)); 

    
    

    always @(posedge clk) begin
        //Las señales se niegan para que se activen cuando el botón está presionado
        btn_salud = ~heal;
        btn_hambre = ~ali;
        btn_reset = ~RST;
        btn_test = ~TST;
		  
		  
		  //leds: contrarios a las señales que se mandan
		  
		  ledSalud = heal;
		  ledHambre = ali;
		  ledReset = RST;
		  ledTest = TST;
    end

    




endmodule