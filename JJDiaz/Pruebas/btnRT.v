module btnRT (
    input clk,
    input boton_in,
    output reg boton_out
);

    localparam COUNT_LIMIT = 2500; // 50000 ns = 50 us

    reg [$clog2(COUNT_LIMIT)-1:0] counter; // contador con bits de COUNT_LIMIT

    initial begin
        boton_out = 0;
        counter = 0;
    end

    always @(posedge clk) begin
        if (boton_in) begin
            // Si boton_in está activo, incrementa el contador
            counter <= counter + 1;
            if (counter >= COUNT_LIMIT) begin
                // Si el contador alcanza el límite, activa boton_out
                boton_out <= 1;
            end
        end
        else begin
            // Si boton_in está desactivado, resetea el contador y desactiva boton_out
            counter <= 0;
            boton_out <= 0;
        end
    end

endmodule