module ControlLed(
    input clk,
    input wire [19:0] contador2,  
    output reg led1,   
    output reg led2, 
    output reg led3   
);


parameter L1=20'd70000; 
parameter L1m=20'd50000; //Para entre 30cm 
parameter L2=20'd50000;  //Para entre 10cm
parameter L2m=20'd30000;
parameter L3=20'd30000; //Para entre 2cm
parameter L3m=20'd3000; //Para 1cm


always @(contador2) 
	begin

		if (contador2>L1m && contador2<L1)
			begin
				led1 <= 0;
				led2 <= 1;
				led3 <= 1;  
			end
		else if (contador2>L2m && contador2<L2)
			begin
				led1 <= 1;
				led2 <= 0;
				led3 <= 1;  
			end
		else if (contador2>L3m && contador2<L3)
			begin
				led1 <= 1;
				led2 <= 1;
				led3 <= 0;  
			end
	end

endmodule
