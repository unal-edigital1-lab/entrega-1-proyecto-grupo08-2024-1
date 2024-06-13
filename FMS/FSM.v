module FSM (
    input clk,
    input [15:0] distance,
    output reg lcd_trigger
);

    parameter WAIT = 2'b00, CHECK = 2'b01, ALERT = 2'b10;
    reg [1:0] state = WAIT;

    always @(posedge clk) begin
        case (state)
            WAIT: begin
                if (distance < 50) begin  // Distance threshold
                    state <= CHECK;
                end
            end

            CHECK: begin
                lcd_trigger <= 1;
                state <= ALERT;
            end

            ALERT: begin
                lcd_trigger <= 0;
                state <= WAIT;
            end
        endcase
    end
endmodule
