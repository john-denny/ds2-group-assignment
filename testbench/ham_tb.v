
module hamming1511_tb();
    reg [14:0] input_bits; // Bit 14 is the MSB
    wire [15:0] led;
    wire is_error;

    hamming1511 dut(input_bits, led, is_error);

    initial begin
        $display("Testing 15/11 Hamming Encoder");
        
        // Set a test case
        $display("Testcase 1");
        input_bits = 15'b101010101111101;
        #2; // 2 time units for propagation
        if (is_error == 1) $fatal(1, "TESTCASE 1 | Fail on Error Bit");
        if (led != 16'b0) $fatal(1, "TESTCASE 1 | Fail on LEDs");
    
    end

    initial begin
        $dumpfile("out.vcd");
        $dumpvars(1, hamming1511_tb);
        // TODO - Fix monitor statement
        $monitor("Testbench | error: %b | led: %b |", is_error, led);
    end

endmodule