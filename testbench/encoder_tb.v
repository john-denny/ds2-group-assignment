module encoder_tb();

    reg [15:0] input_bits;
    wire [15:0] led;
    wire is_error;

    secded16_encoder dut(input_bits, led, is_error);

    // Check the encoded output, parity bits, and error flag.
    task check_case;
        input [15:0] candidate;
        input [15:0] expected_codeword;
        input expected_error;
        input integer case_number;

        begin
            input_bits = candidate;
            #2;

            if (led !== expected_codeword)
                $fatal(1, "Case %0d: input=%b led=%b expected=%b",
                       case_number, candidate, led, expected_codeword);

            if (is_error !== expected_error)
                $fatal(1, "Case %0d: input=%b is_error=%b expected=%b",
                       case_number, candidate, is_error, expected_error);

            if (dut.codeword[0] !== expected_codeword[0] ||
                dut.codeword[1] !== expected_codeword[1] ||
                dut.codeword[3] !== expected_codeword[3] ||
                dut.codeword[7] !== expected_codeword[7] ||
                dut.codeword[15] !== expected_codeword[15])
                $fatal(1, "Case %0d: parity bits incorrect", case_number);
        end
    endtask

    initial begin
        $display("Testing encoder data placement, parity bits, and invalid inputs");

        // Valid input data
        check_case(16'h0000, 16'h0000, 1'b0, 1);
        check_case(16'h0001, 16'h8007, 1'b0, 2);
        check_case(16'h0002, 16'h8019, 1'b0, 3);
        check_case(16'h0004, 16'h802a, 1'b0, 4);
        check_case(16'h0008, 16'h004b, 1'b0, 5);
        check_case(16'h07ff, 16'hffff, 1'b0, 6);

        // Invalid upper input bits
        check_case(16'h1000, 16'h0000, 1'b1, 7);
        check_case(16'h8001, 16'h8007, 1'b1, 8);
        check_case(16'hf7ff, 16'hffff, 1'b1, 9);

        $display("PASS: all 9 encoder test cases passed");
        $finish;
    end

    initial begin
        $dumpfile("encoder_out.vcd");
        $dumpvars(1, encoder_tb);
    end

endmodule
