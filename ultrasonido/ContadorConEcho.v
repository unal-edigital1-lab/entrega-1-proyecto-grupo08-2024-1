module ContadorConEcho( //Moudlo que recibe Echo
    input clk,
    input echo,
    output reg [31:0] echo_duration
);

reg [31:0] counter;

always @(posedge clk) begin
if (echo) begin             // Si echo esta en alto se aumenta un contador
        counter <= counter + 1;
    end else begin          // Cuando baja se guarda el valor del contador en echo_duration y se reinicia el contador
        echo_duration <= counter;
        counter <= 0;
    end
end

endmodule