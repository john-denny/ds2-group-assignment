module secded16_encoder (
    input wire [15:0] input_bits,
    output wire [15:0] led,
    output wire is_error
);
    wire [15:0] codeword;

    // Move all the data across
    assign codeword[14:8] = input_bits[10:4];
    assign codeword[6:4] = input_bits[3:1];
    assign codeword[2] = input_bits[0];

    // Parity bits
    xor parity1(codeword[0], codeword[2], codeword[4], codeword[6], codeword[8], codeword[10], codeword[12], codeword[14]);
    xor parity2(codeword[1], codeword[2], codeword[5], codeword[6], codeword[9], codeword[10], codeword[13], codeword[14]);
    xor parity3(codeword[3], codeword[4], codeword[5], codeword[6], codeword[11], codeword[12], codeword[13], codeword[14]);
    xor parity4(codeword[7], codeword[8], codeword[9], codeword[10], codeword[11], codeword[12], codeword[13], codeword[14]);

    assign codeword[15] = ^codeword[14:0];
    assign led = codeword;
endmodule