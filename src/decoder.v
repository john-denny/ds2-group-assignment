module secded16_decoder (
    input wire [15:0] input_bits,
    output wire [15:0] led,
    output wire is_error
);
    wire [3:0] syndrome;
    wire overall_parity_check; 
    wire overall_parity_mismatch;
    
    // Syndrome
    xor syndrome1(syndrome[0], input_bits[0], input_bits[2], input_bits[4], input_bits[6], input_bits[8], input_bits[10], input_bits[12], input_bits[14]);
    xor syndrome2(syndrome[1], input_bits[1], input_bits[2], input_bits[5], input_bits[6], input_bits[9], input_bits[10], input_bits[13], input_bits[14]);
    xor syndrome3(syndrome[2], input_bits[3], input_bits[4], input_bits[5], input_bits[6], input_bits[11], input_bits[12], input_bits[13], input_bits[14]);
    xor syndrome4(syndrome[3], input_bits[7], input_bits[8], input_bits[9], input_bits[10], input_bits[11], input_bits[12], input_bits[13], input_bits[14]);
    
    // Overall Parity check 
    assign overall_parity_check = ^input_bits[14:0];
    assign overall_parity_mismatch = (overall_parity_check !== input_bits[15]);

    // This bit shows if there is a double error (The syndrome picks up an error, and the overall parity doesn't)
    assign is_error = (syndrome !== 4'b0 && !overall_parity_mismatch) ? 1'b1 : 1'b0;

    // Illuminate the LED matching the erroneous input bit. The syndrome is
    // Double-bit errors have no unique location, so leave the LEDs off.
    assign led = overall_parity_mismatch
        ? ( // There's an error detected
            // If the syndromes 0, the error bit is the parity bit iself. 
            // Otherwise bit shift to the position of the error.
            (syndrome === 4'b0) ? 16'h8000 : (16'b1 << (syndrome - 4'd1))
            )
        // No error
        : 16'b0;
endmodule
