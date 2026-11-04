module hamming1511_tb();

    // Intitialise variables and the dut
    reg [14:0] input_bits;
    wire [15:0] led;
    wire is_error;

    hamming1511 dut(input_bits, led, is_error);

    // Create a task to abstract test cases
    task check_case;
        input [14:0] candidate;
        input [3:0] expected_syndrome;
        input integer case_number;
        reg [15:0] expected_led;
        
        begin
            input_bits = candidate;
            expected_led = (expected_syndrome == 4'b0) ? 16'b0 : (16'b1 << expected_syndrome);
            #2;

            if (dut.syndrome !== expected_syndrome)
                $fatal(1, "Case %0d: input=%b syndrome=%b expected=%b",
                       case_number, candidate, dut.syndrome, expected_syndrome);
            if (is_error !== (expected_syndrome != 4'b0))
                $fatal(1, "Case %0d: input=%b is_error=%b",
                       case_number, candidate, is_error);
            if (led !== expected_led)
                $fatal(1, "Case %0d: input=%b led=%b expected=%b",
                       case_number, candidate, led, expected_led);
        end
    endtask

    initial begin
        $display("Testing valid codewords and all single-bit error positions");

        check_case(15'b111111111111111, 4'd0, 1);   // Valid codeword
        check_case(15'b111111111111110, 4'd1, 2);   // Error at position 1
        check_case(15'b111111111111101, 4'd2, 3);   // Error at position 2
        check_case(15'b111111111111011, 4'd3, 4);   // Error at position 3
        check_case(15'b111111111110111, 4'd4, 5);   // Error at position 4
        check_case(15'b111111111101111, 4'd5, 6);   // Error at position 5
        check_case(15'b111111111011111, 4'd6, 7);   // Error at position 6
        check_case(15'b111111110111111, 4'd7, 8);   // Error at position 7
        check_case(15'b111111101111111, 4'd8, 9);   // Error at position 8
        check_case(15'b111111011111111, 4'd9, 10);  // Error at position 9
        check_case(15'b111110111111111, 4'd10, 11); // Error at position 10
        check_case(15'b111101111111111, 4'd11, 12); // Error at position 11
        check_case(15'b111011111111111, 4'd12, 13); // Error at position 12
        check_case(15'b110111111111111, 4'd13, 14); // Error at position 13
        check_case(15'b101111111111111, 4'd14, 15); // Error at position 14
        check_case(15'b011111111111111, 4'd15, 16); // Error at position 15
        check_case(15'b000000000000000, 4'd0, 17);  // Another valid codeword

        $display("PASS: all 17 test cases passed");
        $finish;
    end

    initial begin
        $dumpfile("out.vcd");
        $dumpvars(1, hamming1511_tb);
    end
endmodule
