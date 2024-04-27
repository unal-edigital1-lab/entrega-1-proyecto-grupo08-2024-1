module top (
  input clk,
  input echo,
  output trig,
  output led1,
  output led2,
  output led3
);
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
    .contador2( s0 )
  );
  // ControlLed
  ControlLed ControlLed_i2 (
    .clk( clk ),
    .contador2( s0 ),
    .led1( led1 ),
    .led2( led2 ),
    .led3( led3 )
  );
endmodule