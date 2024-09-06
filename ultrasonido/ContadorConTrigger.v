module ContadorConTrigger(
    input wire clk,  
    input wire echo,    
    output reg trigger       
);

// Limite 10us = 10000ns = 500 ciclos de reloj

        
parameter limite = 20'd501; 
parameter limCount = 20'd2000;  

reg [19:0] contador1;   
reg [19:0] countAux;
 

initial begin
    contador1 = 0;
    trigger = 0;
    countAux = 0;
end




always @(posedge clk) begin
    if (echo == 0 && contador1 > limCount) begin
        countAux = 0;
    end 
        if (countAux == 0 && contador1 > limite) begin
            contador1 = 0;
        end else begin
        if (contador1 < limite) begin
            
            trigger = 1;
        end else begin
        
            trigger = 0;
        end
        end
    contador1 = contador1 + 1;
    countAux = countAux + 1;
end

endmodule