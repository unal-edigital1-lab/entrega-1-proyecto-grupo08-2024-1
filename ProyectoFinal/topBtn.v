module topBtn(

    input clk,
    input btn_heal,
    input btn_ali,
    input btn_RST,
    input btn_TST,

    output reg btn_salud,
    output reg btn_hambre,
    output reg btn_reset,
    output reg btn_test

);
    
    initial begin
        btn_salud = 0;
        btn_hambre = 0;
        btn_reset = 0;
        btn_test = 0;
    end

    wire heal;
    wire ali;
    wire RST;
    wire TST;

    btnAntirebote #(50000) B_heal (.clk(clk), .boton_in(btn_heal), .boton_out(heal));
    btnAntirebote #(50000) B_ali  (.clk(clk), .boton_in(btn_ali), .boton_out(ali));
    btnRT B_rst (.clk(clk), .boton_in(btn_RST), .boton_out(RST));
    btnRT B_tst (.clk(clk), .boton_in(btn_TST), .boton_out(TST)); 

    
    

    always @(posedge clk) begin
        
        btn_salud = heal;
        btn_hambre = ali;
        btn_reset = RST;
        btn_test = TST;
    end

    




endmodule