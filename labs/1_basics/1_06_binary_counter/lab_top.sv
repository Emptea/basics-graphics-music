`include "config.svh"

module lab_top
# (
    parameter  clk_mhz       = 50,
               w_key         = 4,
               w_sw          = 8,
               w_led         = 8,
               w_digit       = 8,
               w_gpio        = 100,

               screen_width  = 640,
               screen_height = 480,

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

    // assign led        = '0;
       assign abcdefgh   = '0;
       assign digit      = '0;
       assign red        = '0;
       assign green      = '0;
       assign blue       = '0;
       assign sound      = '0;
       assign uart_tx    = '1;

    //------------------------------------------------------------------------

    // Exercise 1: Free running counter.
    // How do you change the speed of LED blinking?
    // Try different bit slices to display.

    // localparam w_cnt = $clog2 (clk_mhz * 2000 * 1000);

    // logic [w_cnt - 1:0] cnt_r;

    // always_ff @ (posedge clk or posedge rst)
    //     if (rst)
    //         cnt_r <= '0;
    //     else
    //         cnt_r <= cnt_r + 1'd1;

    // assign led = cnt_r [$left (cnt_r) -: w_led];

    // Exercise 2: Key-controlled counter.
    // Comment out the code above.
    // Uncomment and synthesize the code below.
    // Press the key to see the counter incrementing.
    //
    // Change the design, for example:
    //
    // 1. One key is used to increment, another to decrement.
    //
    // 2. Two counters controlled by different keys
    // displayed in different groups of LEDs.

    /* EXERCISE 2.1 */
    // wire any_key = key[0];

    // logic [w_key-1:0] all_keys;

    // always_ff @ (posedge clk or posedge rst)
    //     if (rst)
    //         all_keys <= '0;
    //     else
    //         all_keys <= key;

    // wire key0_pressed = ~ key[0] & all_keys[0];
    // wire key1_pressed = ~ key[1] & all_keys[1];

    // logic [w_led - 1:0] cnt_r;

    // always_ff @ (posedge clk or posedge rst)
    //     if (rst)
    //         cnt_r <= '0;
    //     else if (key0_pressed)
    //         cnt_r <= cnt_r + 1'd1;
    //     else if (key1_pressed)
    //         cnt_r <= cnt_r - 1'd1;

    // assign led = w_led' (cnt_r);

    /* EXERCISE 2.2 */
    logic [w_key-1:0] all_keys;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            all_keys <= '0;
        else
            all_keys <= key;

    wire key0_pressed = ~ key[0] & all_keys[0];
    wire key1_pressed = ~ key[1] & all_keys[1];
    wire key2_pressed = ~ key[2] & all_keys[2];

    logic [w_led - w_led/2 - 1:0] cnt_r, cnt_l;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
        begin
            cnt_r <= '0;
            cnt_l <= '0;
        end
        else if (key0_pressed)
            cnt_r <= cnt_r + 1'd1;
        else if (key1_pressed)
            cnt_l <= cnt_l + 1'd1;
        else if (key2_pressed)
        begin
            cnt_l <= cnt_l - 1'd1;
            cnt_r <= cnt_l - 1'd1;
        end

    assign led = w_led' ({cnt_l, cnt_r});


endmodule
