module Ultrasonic_Sensor (
    input clk,
    input trigger,  // Signal to trigger the sensor
    output reg echo,  // Signal received from the sensor
    output reg [15:0] distance  // Distance measured
);

    // Define the states
    parameter IDLE = 2'b00, TRIGGER = 2'b01, ECHO = 2'b10, DONE = 2'b11;
    reg [1:0] state = IDLE;

    reg [31:0] counter;
    reg [31:0] echo_start;
    reg [31:0] echo_end;

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                if (trigger) begin
                    counter <= 0;
                    state <= TRIGGER;
                end
            end

            TRIGGER: begin
                if (counter < 10) begin  // 10 clock cycles for trigger pulse
                    counter <= counter + 1;
                end else begin
                    counter <= 0;
                    state <= ECHO;
                end
            end

            ECHO: begin
                if (echo) begin
                    echo_start <= counter;
                    state <= DONE;
                end
                counter <= counter + 1;
            end

            DONE: begin
                if (!echo) begin
                    echo_end <= counter;
                    distance <= (echo_end - echo_start) / 58;  // Calculate distance
                    state <= IDLE;
                end
            end
        endcase
    end
endmodule
