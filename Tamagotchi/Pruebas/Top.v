module Top(
    input clk,

    //LCD
    input reset,
    output rs,
    output rw,
    output [7:0] data,
    output enable,

    //FSM
    input btn_salud,
    output [6:0] seg_displpay,
    output clk_out,
    output an
);

wire [3:0] display_out; //Salida de FSM y Entrada de LCD


    bucleEspera #(.num_commands(3), .num_data_all(64), .char_data(8), .num_cgram_addrs(8), .COUNT_MAX(100000), .WAIT_TIME(25)) U_bucleEspera(
        .clk(clk),
        .reset(reset),
        .select_figures(display_out),
        .rs(rs),
        .rw(rw),
        .enable(enable),
        .data(data)
    );

    tamagotchi_fsm #(.DIVISOR(7500000))U_tamagotchi_fsm(
        .clk(clk),
        .btn_salud(btn_salud),
        .display_out(display_out),
        .seg_display(seg_display),
        .clk_out(clk_out),
        .an(an)
    );

endmodule