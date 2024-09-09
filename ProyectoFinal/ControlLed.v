module ControlLed(
    input wire [19:0] contador2,	 
    output reg led1,   
    output reg sens_ult
);



parameter L1=20'd70000;  //30cm             1400000 ns
parameter L1m=20'd50000; //Para entre 10cm    1000000 ns
parameter L3=20'd30000; //Para entre 2cm       600000 ns
parameter L3m=20'd3000; //Para 1cm             60000 ns



always @(contador2) 
	begin

		if (contador2 > L3m && contador2<L3)
			begin
				 sens_ult <= 0;
			end
		else if (contador2 > L1m && contador2<L1)
			begin
				sens_ult <= 1;
			end
		
		led1 <= ~sens_ult;
	end
endmodule
