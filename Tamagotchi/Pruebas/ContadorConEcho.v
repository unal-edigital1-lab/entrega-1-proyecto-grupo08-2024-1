module ContadorConEcho(
    input clk,
    input echo,
    output reg [31:0] echo_duration
);

reg [31:0] counter;

always @(posedge clk) begin
    if (echo) begin
        counter <= counter + 1;
    end else begin
        echo_duration <= counter;
        counter <= 0;
    end
end

endmodule