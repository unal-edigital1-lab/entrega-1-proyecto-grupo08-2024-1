module Top_Module (
    input clk,
    input trigger,
    input echo,
    output [7:0] lcd_data,
    output lcd_rs,
    output lcd_en
);

    wire [15:0] distance;
    wire lcd_trigger;

    Ultrasonic_Sensor u_sensor (
        .clk(clk),
        .trigger(trigger),
        .echo(echo),
        .distance(distance)
    );

    FSM fsm (
        .clk(clk),
        .distance(distance),
        .lcd_trigger(lcd_trigger)
    );

    LCD_Controller lcd (
        .clk(clk),
        .trigger(lcd_trigger),
        .lcd_data(lcd_data),
        .lcd_rs(lcd_rs),
        .lcd_en(lcd_en)
    );

endmodule
