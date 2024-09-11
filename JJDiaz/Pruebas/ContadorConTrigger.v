module ContadorConTrigger(
    input clk,
    output reg trig
);

parameter TRIG_PULSE_WIDTH = 10'd500; // 10us = 10000ns = 500 ciclos de reloj
reg [31:0] counter;

always @(posedge clk) begin
    if (counter < TRIG_PULSE_WIDTH) begin
        counter <= counter + 1;
        trig <= 1;
    end else begin
        counter <= 0;
        trig <= 0;
    end
end

endmodule
