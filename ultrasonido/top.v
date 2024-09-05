module top (
  input clk,
  input echo,
  output trig,
  output sens_ult,
  output wire [19:0] s0
);

  


  
  // ContadorConTrigger
  ContadorConTrigger ContadorConTrigger_i0 (
    .clk( clk ), //in
    .echo( echo ), //in
    .trigger( trig ) //out
  );
  // ContadorConEcho
  ContadorConEcho ContadorConEcho_i1 (
    .clk( clk ),       //in
    .echo( echo ),     //in
    .contador2( s0 )   //out
  );
  // ControlLed
  ControlLed ControlLed_i2 (
    .clk( clk ),             //in
    .contador2( s0 ),        //in
    .echo( echo ),           //in
    .sens_ult( sens_ult )    //out
  );

  
endmodule