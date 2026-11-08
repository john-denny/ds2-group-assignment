module decoder_tb();

    reg [15:0] input_bits;
    wire [15:0] led;
    wire is_error;

    secded16_decoder dut(input_bits, led, is_error);

    // Check the decoder syndrome, error flag, and one-hot LED output.
    task check_case;
        input [15:0] candidate;
        input [3:0] expected_syndrome;
        input expected_error;
        input integer case_number;
        reg [15:0] expected_led;

        begin
            input_bits = candidate;
            expected_led = (expected_syndrome == 4'b0) ? 16'b0 : (16'b1 << expected_syndrome);
            #2;

            if (dut.syndrome !== expected_syndrome)
                $fatal(1, "Case %0d: input=%b syndrome=%b expected=%b",
                       case_number, candidate, dut.syndrome, expected_syndrome);
            if (is_error !== expected_error)
                $fatal(1, "Case %0d: input=%b is_error=%b expected=%b",
                       case_number, candidate, is_error, expected_error);
            if (led !== expected_led)
                $fatal(1, "Case %0d: input=%b led=%b expected=%b",
                       case_number, candidate, led, expected_led);
        end
    endtask

    initial begin
        $display("Testing valid codewords, single-bit errors, and double-bit errors");

        // Both all-zero and all-one 16-bit words are valid codewords.
        check_case(16'h0000, 4'd0, 1'b0, 1);
        check_case(16'hffff, 4'd0, 1'b0, 2);

        // A single flipped bit in positions 1 through 15 gives that syndrome.
        // Single-bit errors are not flagged as uncorrectable double errors.
        check_case(16'hfffe, 4'd1,  1'b0, 3);
        check_case(16'hfffd, 4'd2,  1'b0, 4);
        check_case(16'hfffb, 4'd3,  1'b0, 5);
        check_case(16'hfff7, 4'd4,  1'b0, 6);
        check_case(16'hffef, 4'd5,  1'b0, 7);
        check_case(16'hffdf, 4'd6,  1'b0, 8);
        check_case(16'hffbf, 4'd7,  1'b0, 9);
        check_case(16'hff7f, 4'd8,  1'b0, 10);
        check_case(16'hfeff, 4'd9,  1'b0, 11);
        check_case(16'hfdff, 4'd10, 1'b0, 12);
        check_case(16'hfbff, 4'd11, 1'b0, 13);
        check_case(16'hf7ff, 4'd12, 1'b0, 14);
        check_case(16'hefff, 4'd13, 1'b0, 15);
        check_case(16'hdfff, 4'd14, 1'b0, 16);
        check_case(16'hbfff, 4'd15, 1'b0, 17);

        // The overall parity bit has no Hamming syndrome of its own.
        check_case(16'h7fff, 4'd0, 1'b0, 18);

        // Two flipped bits preserve overall parity, so a nonzero syndrome
        // indicates an uncorrectable double-bit error.
        check_case(16'hfffc, 4'd3, 1'b1, 19);
        check_case(16'h7ffe, 4'd1, 1'b1, 20);

        $display("PASS: all 20 test cases passed");
        $finish;
    end

    initial begin
        $dumpfile("out.vcd");
        $dumpvars(1, decoder_tb);
    end
endmodule
