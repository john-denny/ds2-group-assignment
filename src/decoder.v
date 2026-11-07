

module hamming1511 (
    input wire [14:0] input_bits,
    output wire [15:0] led,
    output wire is_error
);
    wire [3:0] syndrome;
    
    // Syndrome
    xor syndrome1(syndrome[0], input_bits[0], input_bits[2], input_bits[4], input_bits[6], input_bits[8], input_bits[10], input_bits[12], input_bits[14]);
    xor syndrome2(syndrome[1], input_bits[1], input_bits[2], input_bits[5], input_bits[6], input_bits[9], input_bits[10], input_bits[13], input_bits[14]);
    xor syndrome3(syndrome[2], input_bits[3], input_bits[4], input_bits[5], input_bits[6], input_bits[11], input_bits[12], input_bits[13], input_bits[14]);
    xor syndrome4(syndrome[3], input_bits[7], input_bits[8], input_bits[9], input_bits[10], input_bits[11], input_bits[12], input_bits[13], input_bits[14]);

    // This bit shows if there is an error
    assign is_error = (syndrome == 4'b0) ? 1'b0 : 1'b1;
    
     
    // Error position - Take the syndrome bits and dump them into a 1 hot 16 bit value
    // if the syndrome is 0, set all 16 bits to 0, otherwise
    assign led = (syndrome == 4'b0) ? 16'b0 : 16'b1 << syndrome; // Create a 16 bit value to store the number 1. Then left shift that bit "syndrome number of times"
endmodule