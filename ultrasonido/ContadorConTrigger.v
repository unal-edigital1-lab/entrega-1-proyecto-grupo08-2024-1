module ContadorConTrigger(
    input wire clk,  
    input wire echo,        
    output reg trigger       
);

// Limite 10us = 10000ns = 500 ciclos de reloj

reg [19:0] contador1;        
parameter limite = 20'd500;     

initial begin
    contador1 = 0;
    trigger = 0;
end

/*always @(negedge echo ) begin
    contador1 = 0;
    
end*/

always @(posedge clk) begin
    if (contador1 < limite) begin
        contador1 <= contador1 + 1;
        trigger <= 1;
    end else begin
        
        trigger = 0;
    end
end

endmodule