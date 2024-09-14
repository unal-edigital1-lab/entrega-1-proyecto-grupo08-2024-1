module btnRT (
    input clk,
    input boton_in,
    output reg boton_out
);

    localparam COUNT_LIMIT = 28'd250000000; // 50000 ns = 50 us

    reg [$clog2(COUNT_LIMIT)+1:0] counter; // contador con bits de COUNT_LIMIT

    initial begin
        boton_out = 1;
        counter = 0;
    end

	 
	 always @(posedge clk) begin
	   if(boton_in == 0) begin
		counter <= counter + 1;
			if(counter > COUNT_LIMIT) begin
				boton_out <= 0;
			end else begin
				boton_out <= 1;
			
			end
		end else begin
			boton_out <= 1;
			counter <= 0;
		end
	 end

endmodule