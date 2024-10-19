`include "config.svh"

module lab_top
# (
    parameter  clk_mhz       = 50,
               w_key         = 4,
               w_sw          = 8,
               w_led         = 8,
               w_digit       = 8,
               w_gpio        = 100,

               screen_width  = 680,
               screen_height = 240,

               w_red         = 4,
               w_green       = 4,
               w_blue        = 4,

               w_x           = $clog2 ( screen_width  ),
               w_y           = $clog2 ( screen_height )
)
(
    input                        clk,
    input                        slow_clk,
    input                        rst,

    // Keys, switches, LEDs

    input        [w_key   - 1:0] key,
    input        [w_sw    - 1:0] sw,
    output logic [w_led   - 1:0] led,

    // A dynamic seven-segment display

    output logic [          7:0] abcdefgh,
    output logic [w_digit - 1:0] digit,

    // Graphics

    input        [w_x     - 1:0] x,
    input        [w_y     - 1:0] y,

    output logic [w_red   - 1:0] red,
    output logic [w_green - 1:0] green,
    output logic [w_blue  - 1:0] blue,

    // Microphone, sound output and UART

    input        [         23:0] mic,
    output       [         15:0] sound,

    input                        uart_rx,
    output                       uart_tx,

    // General-purpose Input/Output

    inout        [w_gpio  - 1:0] gpio
);

    //------------------------------------------------------------------------

       assign led        = '0;
       assign abcdefgh   = '0;
       assign digit      = '0;
    // assign red        = '0;
    // assign green      = '0;
    // assign blue       = '0;
       assign sound      = '0;
       assign uart_tx    = '1;

    //------------------------------------------------------------------------

    wire [w_x * 2 - 1:0] x_2 = x * x;

    // These additional wires are needed
    // because some graphics interfaces have up to 10 bits per color channel

    wire [10:0] x11 = 11' (x);
    wire [ 9:0] y10 = 10' (y);

    always_comb
    begin
        red   = '0;
        green = '0;
        blue  = '0;

        if (((x - screen_width/2) ** 2 + (y - screen_height/2) ** 2 < (screen_width / 8) ** 2) 
        & ((x - screen_width/2) ** 2 + (y - screen_height/2) ** 2 > (screen_width / 10) ** 2) ) // Ellipse
        begin
            red = '1;
        end

        // Буква В
        // рисуем палку
        if (y >= screen_height/10
        & y < (screen_height + 200)/10
        & x >= 9*screen_width/10
        & x < (9*(screen_width + 2)/10))
        begin
            blue = '1;
        end 
        // верхнюю полуокружность
        if (((x - 9*screen_width/10) ** 2 + (y - (screen_height+50)/10) ** 2 < 27)
        & ((x - 9*screen_width/10) ** 2 + (y - (screen_height+50)/10) ** 2 >= (4) ** 2)
        & x >= 9*screen_width/10)
            blue = '1; 
        // нижнюю полуокружность
        if (((x - 9*screen_width/10) ** 2 + (y - (screen_height+150)/10) ** 2 < 27)
        & ((x - 9*screen_width/10) ** 2 + (y - (screen_height+150)/10) ** 2 >= (4) ** 2)
        & x >= 9*screen_width/10)
            blue = '1; 
    end

endmodule
