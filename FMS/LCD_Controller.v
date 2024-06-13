module LCD_Controller (
    input clk,
    input trigger,
    output reg [7:0] lcd_data,
    output reg lcd_rs,
    output reg lcd_en
);

    reg [3:0] state;
    reg [19:0] counter;
    reg [7:0] message [0:15];

    initial begin
        message[0] = "D";
        message[1] = "i";
        message[2] = "s";
        message[3] = "t";
        message[4] = "a";
        message[5] = "n";
        message[6] = "c";
        message[7] = "e";
        message[8] = " ";
        message[9] = "T";
        message[10] = "r";
        message[11] = "i";
        message[12] = "g";
        message[13] = "g";
        message[14] = "e";
        message[15] = "r";
    end

    always @(posedge clk) begin
        if (trigger) begin
            counter <= 0;
            state <= 0;
        end

        case (state)
            0: begin
                if (counter < 50000) begin
                    counter <= counter + 1;
                end else begin
                    lcd_data <= message[state];
                    lcd_rs <= 1;
                    lcd_en <= 1;
                    state <= state + 1;
                end
            end

            1: begin
                lcd_en <= 0;
                if (counter < 50000) begin
                    counter <= counter + 1;
                end else begin
                    state <= state + 1;
                    counter <= 0;
                end
            end

            2: begin
                if (state < 16) begin
                    lcd_data <= message[state];
                    lcd_rs <= 1;
                    lcd_en <= 1;
                    state <= state + 1;
                end else begin
                    state <= 0;
                end
            end
        endcase
    end
endmodule
