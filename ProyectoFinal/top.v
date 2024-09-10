module top (
    input clk,
    input echo,
    output trig,
	  output sens_ult,
    output led
);


wire [31:0] echo_duration;
wire aux;

ContadorConTrigger U_trigger(
    .clk(clk), 
    .trig(trig)
    );


ContadorConEcho U_echo(
    .clk(clk), 
    .echo(echo), 
    .echo_duration(echo_duration)
    );

ControlLed U_led(
	 .clk(clk),
    .echo_duration(echo_duration), 
    .aux(aux)
    );

Salida U_salida(
    .clk(clk),
    .aux(aux),
    .led(led),
    .sens_ult(sens_ult)
    );  

endmodule