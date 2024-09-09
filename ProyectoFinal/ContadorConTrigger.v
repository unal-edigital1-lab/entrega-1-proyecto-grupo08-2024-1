module ContadorConTrigger(
    input wire clk,          
    output reg trigger       
);

reg [19:0] contador1;        
parameter limite = 20'd500000;     

always @(posedge clk) begin
    if (contador1 < limite) begin
        contador1 <= contador1 + 1;
        trigger <= 1;
    end else begin
        contador1 = 0;
        trigger = 0;
    end
end

endmodule