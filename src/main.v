module main(
    // Defined in the xdc
    input wire clk,
    input wire rst,
    input wire mode_button,
    input wire [15:0] input_bits, // Read-only for modules, only changed by the device
    output wire [15:0] device_led // The actual device leds
    );
    
    // Register to track whether the chip is in decode (0) or encode (1)
    reg mode;
    mode_toggle mode_switcher(clk, rst, mode_button, mode);
    
    // Individual led and error bit values for encoder and decoder
    wire [15:0] encode_leds; 
    wire encode_error;
    wire [15:0] decode_leds; 
    wire decode_error;

    secded16_decoder decoder(input_bits, decode_leds, decode_error);
    secded16_encoder encoder(input_bits, encode_leds, encode_error);

    assign device_led = mode ? encode_leds : decode_leds;
endmodule
