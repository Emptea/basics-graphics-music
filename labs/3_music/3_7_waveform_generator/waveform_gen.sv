module waveform_gen
# (
    parameter clk_mhz        = 50,
              y_width        = 16, // sound samples resolution
              waveform_width = 4
)
(
    input                         clk,
    input                         reset,
    input  [                 2:0] octave,
    input  [waveform_width - 1:0] waveform,
    output [y_width        - 1:0] y
);

    // We are grouping together clk_mhz ranges of
    // (12-19), (20-35), (36-67), (68-131).

    localparam CLK_BIT  =  $clog2 ( clk_mhz - 4 ) + 4;
    localparam CLK_DIV_DATA_OFFSET = { { CLK_BIT - 2 { 1'b0 } }, 1'b1 };
    
    wire   [y_width - 1:0] tone_y     [4:0];
    wire             [8:0] tone_x;
    wire             [8:0] tone_x_max [4:0];

    logic  [CLK_BIT - 1:0] clk_div;
    logic  [          1:0] quadrant; // Quadrant (quarter period)

    logic           [ 8:0] x;        // Current sample
    wire            [ 8:0] x_max;    // Last sample in a quadrant (quarter period)
    logic  [y_width - 1:0] y_mod;

    always_ff @ (posedge clk or posedge reset)
        if (reset) 
            clk_div <= '0;
        else
            clk_div <= clk_div + 1'b1;

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            x <= 9'b1;
        else if (clk_div == CLK_DIV_DATA_OFFSET ) // One sample for L and R audio channels
            x <= (quadrant [0] & (x > 1'b0) | (x >= x_max)) ? (x - 1'b1) : (x + 1'b1);

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            quadrant <= 2'b0;
        else if ((clk_div == CLK_DIV_DATA_OFFSET ) & ((x == x_max) | (x == 9'b0)))
            quadrant <= quadrant + 1'b1;

    assign tone_x = x << octave;
    assign x_max = (waveform [0] || waveform [1] || waveform [2]) ?
                                (tone_x_max [waveform] >> octave) :  9'b1;
    assign y_mod = (waveform [0] || waveform [1] || waveform [2]) ?
                                (tone_y     [waveform]          ) : 16'b0;
    assign y     = (quadrant [1]) ? (~y_mod + 1'b1) : y_mod;

generate

//table_sampling_rate sampling_rate = clk_mhz / 512  ( < 36 mhz)
//                                  = clk_mhz / 1024 (36-67 mhz)
//                                  = clk_mhz / 2048 ( > 67 mhz)

    if (clk_mhz == 33)
    begin : clk_mhz_33
    table_64453_S  table_64453_S  ( .x(tone_x), .y(tone_y [1] ), .x_max(tone_x_max [1] ));
    table_64453_T  table_64453_T  ( .x(tone_x), .y(tone_y [2] ), .x_max(tone_x_max [2] ));
    table_64453_Q  table_64453_Q  ( .x(tone_x), .y(tone_y [4] ), .x_max(tone_x_max [4] ));
    end
    else if (clk_mhz == 27)
    begin : clk_mhz_27
    table_52734_S  table_52734_S  ( .x(tone_x), .y(tone_y [1] ), .x_max(tone_x_max [1] ));
    table_52734_T  table_52734_T  ( .x(tone_x), .y(tone_y [2] ), .x_max(tone_x_max [2] ));
    table_52734_Q  table_52734_Q  ( .x(tone_x), .y(tone_y [4] ), .x_max(tone_x_max [4] ));
    end
    else
    begin : clk_mhz_50
    table_48828_S  table_48828_S  ( .x(tone_x), .y(tone_y [1] ), .x_max(tone_x_max [1] ));
    table_48828_T  table_48828_T  ( .x(tone_x), .y(tone_y [2] ), .x_max(tone_x_max [2] ));
    table_48828_Q  table_48828_Q  ( .x(tone_x), .y(tone_y [4] ), .x_max(tone_x_max [4] ));
    end
    
endgenerate

endmodule

module table_48828_S
(
    input        [ 8:0] x,
    output       [ 8:0] x_max,
    output logic [15:0] y
);

    assign x_max = 28;

    always_comb
        case (x)
         0: y = 16'b0000000000000000;
         1: y = 16'b0000010111010000;
         2: y = 16'b0000101110011100;
         3: y = 16'b0001000101011110;
         4: y = 16'b0001011100010010;
         5: y = 16'b0001110010110100;
         6: y = 16'b0010001000111111;
         7: y = 16'b0010011110101101;
         8: y = 16'b0010110011111100;
         9: y = 16'b0011001000100111;
        10: y = 16'b0011011100101010;
        11: y = 16'b0011110000000000;
        12: y = 16'b0100000010100101;
        13: y = 16'b0100010100010111;
        14: y = 16'b0100100101010001;
        15: y = 16'b0100110101001111;
        16: y = 16'b0101000100010000;
        17: y = 16'b0101010010001111;
        18: y = 16'b0101011111001010;
        19: y = 16'b0101101010111111;
        20: y = 16'b0101110101101010;
        21: y = 16'b0101111111001010;
        22: y = 16'b0110000111011101;
        23: y = 16'b0110001110100001;
        24: y = 16'b0110010100010101;
        25: y = 16'b0110011000111000;
        26: y = 16'b0110011100001000;
        27: y = 16'b0110011110000101;
        28: y = 16'b0110011110101111;
        default: y = 16'b0;
        endcase

endmodule

module table_48828_T
(
    input        [ 8:0] x,
    output       [ 8:0] x_max,
    output logic [15:0] y
);

    assign x_max = 28;

    always_comb
        case (x)
         0: y = 16'b0000000000000000;
         1: y = 16'b0000010000011101;
         2: y = 16'b0000100000111011;
         3: y = 16'b0000110001011000;
         4: y = 16'b0001000001110101;
         5: y = 16'b0001010010010010;
         6: y = 16'b0001100010110000;
         7: y = 16'b0001110011001101;
         8: y = 16'b0010000011101010;
         9: y = 16'b0010010100001000;
        10: y = 16'b0010100100100101;
        11: y = 16'b0010110101000010;
        12: y = 16'b0011000101011111;
        13: y = 16'b0011010101111101;
        14: y = 16'b0011100110011010;
        15: y = 16'b0011110110110111;
        16: y = 16'b0100000111010101;
        17: y = 16'b0100010111110010;
        18: y = 16'b0100101000001111;
        19: y = 16'b0100111000101100;
        20: y = 16'b0101001001001010;
        21: y = 16'b0101011001100111;
        22: y = 16'b0101101010000100;
        23: y = 16'b0101111010100010;
        24: y = 16'b0110001010111111;
        25: y = 16'b0110011011011100;
        26: y = 16'b0110101011111001;
        27: y = 16'b0110111100010111;
        28: y = 16'b0111001100110100;
        default: y = 16'b0;
        endcase

endmodule

module table_48828_Q
(
    input        [ 8:0] x,
    output       [ 8:0] x_max,
    output logic [15:0] y
);

    assign x_max = 28;

    always_comb
        case (x)
        0: y = 16'b0000000000000000;
        default: y = 16'b0101001001001010;
        endcase

endmodule

module table_64453_S
(
    input        [ 8:0] x,
    output       [ 8:0] x_max,
    output logic [15:0] y
);

    assign x_max = 37;

    always_comb
        case (x)
         0: y = 16'b0000000000000000;
         1: y = 16'b0000010001100111;
         2: y = 16'b0000100011001011;
         3: y = 16'b0000110100101011;
         4: y = 16'b0001000110000110;
         5: y = 16'b0001010111011000;
         6: y = 16'b0001101000100000;
         7: y = 16'b0001111001011100;
         8: y = 16'b0010001010001010;
         9: y = 16'b0010011010101001;
        10: y = 16'b0010101010110101;
        11: y = 16'b0010111010101110;
        12: y = 16'b0011001010010001;
        13: y = 16'b0011011001011101;
        14: y = 16'b0011101000001111;
        15: y = 16'b0011110110100111;
        16: y = 16'b0100000100100011;
        17: y = 16'b0100010010000000;
        18: y = 16'b0100011110111110;
        19: y = 16'b0100101011011011;
        20: y = 16'b0100110111010101;
        21: y = 16'b0101000010101011;
        22: y = 16'b0101001101011100;
        23: y = 16'b0101010111100111;
        24: y = 16'b0101100001001010;
        25: y = 16'b0101101010000100;
        26: y = 16'b0101110010010101;
        27: y = 16'b0101111001111011;
        28: y = 16'b0110000000110101;
        29: y = 16'b0110000111000011;
        30: y = 16'b0110001100100011;
        31: y = 16'b0110010001010110;
        32: y = 16'b0110010101011011;
        33: y = 16'b0110011000110001;
        34: y = 16'b0110011011011000;
        35: y = 16'b0110011101001111;
        36: y = 16'b0110011110010111;
        37: y = 16'b0110011110101111;
        default: y = 16'b0;
        endcase

endmodule

module table_64453_T
(
    input        [ 8:0] x,
    output       [ 8:0] x_max,
    output logic [15:0] y
);

    assign x_max = 37;

    always_comb
        case (x)
         0: y = 16'b0000000000000000;
         1: y = 16'b0000001100011101;
         2: y = 16'b0000011000111010;
         3: y = 16'b0000100101010111;
         4: y = 16'b0000110001110100;
         5: y = 16'b0000111110010001;
         6: y = 16'b0001001010101110;
         7: y = 16'b0001010111001100;
         8: y = 16'b0001100011101001;
         9: y = 16'b0001110000000110;
        10: y = 16'b0001111100100011;
        11: y = 16'b0010001001000000;
        12: y = 16'b0010010101011101;
        13: y = 16'b0010100001111010;
        14: y = 16'b0010101110010111;
        15: y = 16'b0010111010110100;
        16: y = 16'b0011000111010001;
        17: y = 16'b0011010011101110;
        18: y = 16'b0011100000001011;
        19: y = 16'b0011101100101001;
        20: y = 16'b0011111001000110;
        21: y = 16'b0100000101100011;
        22: y = 16'b0100010010000000;
        23: y = 16'b0100011110011101;
        24: y = 16'b0100101010111010;
        25: y = 16'b0100110111010111;
        26: y = 16'b0101000011110100;
        27: y = 16'b0101010000010001;
        28: y = 16'b0101011100101110;
        29: y = 16'b0101101001001011;
        30: y = 16'b0101110101101000;
        31: y = 16'b0110000010000110;
        32: y = 16'b0110001110100011;
        33: y = 16'b0110011011000000;
        34: y = 16'b0110100111011101;
        35: y = 16'b0110110011111010;
        36: y = 16'b0111000000010111;
        37: y = 16'b0111001100110100;
        default: y = 16'b0;
        endcase

endmodule

module table_64453_Q
(
    input        [ 8:0] x,
    output       [ 8:0] x_max,
    output logic [15:0] y
);

    assign x_max = 37;

    always_comb
        case (x)
        0: y = 16'b0000000000000000;
        default: y = 16'b0101001001001010;
        endcase

endmodule

module table_52734_S
(
    input        [ 8:0] x,
    output       [ 8:0] x_max,
    output logic [15:0] y
);

    assign x_max = 30;

    always_comb
        case (x)
         0: y = 16'b0000000000000000;
         1: y = 16'b0000010101101101;
         2: y = 16'b0000101011010110;
         3: y = 16'b0001000000111000;
         4: y = 16'b0001010110001111;
         5: y = 16'b0001101011010110;
         6: y = 16'b0010000000001010;
         7: y = 16'b0010010100101000;
         8: y = 16'b0010101000101100;
         9: y = 16'b0010111100010010;
        10: y = 16'b0011001111010111;
        11: y = 16'b0011100001111000;
        12: y = 16'b0011110011110001;
        13: y = 16'b0100000101000000;
        14: y = 16'b0100010101100001;
        15: y = 16'b0100100101010001;
        16: y = 16'b0100110100001101;
        17: y = 16'b0101000010010100;
        18: y = 16'b0101001111100010;
        19: y = 16'b0101011011110101;
        20: y = 16'b0101100111001011;
        21: y = 16'b0101110001100010;
        22: y = 16'b0101111010111000;
        23: y = 16'b0110000011001100;
        24: y = 16'b0110001010011100;
        25: y = 16'b0110010000100110;
        26: y = 16'b0110010101101011;
        27: y = 16'b0110011001101000;
        28: y = 16'b0110011100011101;
        29: y = 16'b0110011110001010;
        30: y = 16'b0110011110101111;
        default: y = 16'b0;
        endcase

endmodule

module table_52734_T
(
    input        [ 8:0] x,
    output       [ 8:0] x_max,
    output logic [15:0] y
);

    assign x_max = 30;

    always_comb
        case (x)
         0: y = 16'b0000000000000000;
         1: y = 16'b0000001111010111;
         2: y = 16'b0000011110101110;
         3: y = 16'b0000101110000101;
         4: y = 16'b0000111101011100;
         5: y = 16'b0001001100110011;
         6: y = 16'b0001011100001010;
         7: y = 16'b0001101011100001;
         8: y = 16'b0001111010111001;
         9: y = 16'b0010001010010000;
        10: y = 16'b0010011001100111;
        11: y = 16'b0010101000111110;
        12: y = 16'b0010111000010101;
        13: y = 16'b0011000111101100;
        14: y = 16'b0011010111000011;
        15: y = 16'b0011100110011010;
        16: y = 16'b0011110101110001;
        17: y = 16'b0100000101001000;
        18: y = 16'b0100010100011111;
        19: y = 16'b0100100011110110;
        20: y = 16'b0100110011001101;
        21: y = 16'b0101000010100100;
        22: y = 16'b0101010001111011;
        23: y = 16'b0101100001010011;
        24: y = 16'b0101110000101010;
        25: y = 16'b0110000000000001;
        26: y = 16'b0110001111011000;
        27: y = 16'b0110011110101111;
        28: y = 16'b0110101110000110;
        29: y = 16'b0110111101011101;
        30: y = 16'b0111001100110100;
        default: y = 16'b0;
        endcase

endmodule

module table_52734_Q
(
    input        [ 8:0] x,
    output       [ 8:0] x_max,
    output logic [15:0] y
);

    assign x_max = 30;

    always_comb
        case (x)
        0: y = 16'b0000000000000000;
        default: y = 16'b0101001001001010;
        endcase

endmodule