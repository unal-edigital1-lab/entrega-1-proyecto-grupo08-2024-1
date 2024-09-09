module top (
  input clk,
  input echo,
  input reset,
  output trig,
  output led1,
  output sens_ult
);

  wire clk_out;
  wire [19:0] s0;
  // ContadorConTrigger
  ContadorConTrigger ContadorConTrigger_i0 (
    .clk( clk ),
    .trigger( trig )
  );
  // ContadorConEcho
  ContadorConEcho ContadorConEcho_i1 (
    .clk( clk ),
    .echo( echo ),
	 .reset(reset),
	 .clk_out(clk_out),
    .contador2( s0 )
  );
  // ControlLed
  ControlLed ControlLed_i2 (
    .contador2( s0 ),
    .led1( led1 ),
    .sens_ult( sens_ult )
  );
endmodule
