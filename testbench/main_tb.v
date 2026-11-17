`timescale 1ns/1ps

module main_tb();

    reg clk;
    reg rst;
    reg mode_button;
    reg [15:0] input_bits;
    wire [15:0] device_led;

    main dut(clk, rst, mode_button, input_bits, device_led);

    // Generate a clock with a 10ns period.
    always #5 clk = ~clk;

    // Check the current mode and LED output.
    task check_case;
        input [15:0] candidate;
        input expected_mode;
        input [15:0] expected_led;
        input integer case_number;

        begin
            input_bits = candidate;
            #2;

            if (dut.mode !== expected_mode)
                $fatal(1, "Case %0d: mode=%b expected=%b",
                       case_number, dut.mode, expected_mode);

            if (device_led !== expected_led)
                $fatal(1, "Case %0d: input=%b led=%b expected=%b",
                       case_number, candidate, device_led, expected_led);
        end
    endtask

    // Press the mode button for one clock cycle.
    task toggle_mode;
        begin
            @(negedge clk);
            mode_button = 1'b1;
            @(negedge clk);
            mode_button = 1'b0;
            #2;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        mode_button = 1'b0;
        input_bits = 16'h0000;

        $display("Testing main module reset, mode switching, and LED outputs");

        // Reset into decoder mode.
        repeat (2) @(negedge clk);
        rst = 1'b0;
        #2;

        check_case(16'h0000, 1'b0, 16'h0000, 1);
        check_case(16'hfffe, 1'b0, 16'h0002, 2);
        check_case(16'hfffc, 1'b0, 16'h0008, 3);

        // Switch into encoder mode.
        toggle_mode();

        check_case(16'h0000, 1'b1, 16'h0000, 4);
        check_case(16'h0001, 1'b1, 16'h8007, 5);
        check_case(16'h0002, 1'b1, 16'h8019, 6);
        check_case(16'h07ff, 1'b1, 16'hffff, 7);

        // Mode should remain unchanged after button release.
        check_case(16'h0004, 1'b1, 16'h802a, 8);

        // Switch back into decoder mode.
        toggle_mode();

        check_case(16'h0000, 1'b0, 16'h0000, 9);
        check_case(16'hfffd, 1'b0, 16'h0004, 10);

        // Reset while in encoder mode.
        toggle_mode();
        check_case(16'h0001, 1'b1, 16'h8007, 11);

        @(negedge clk);
        rst = 1'b1;
        @(negedge clk);
        rst = 1'b0;
        #2;

        check_case(16'h0000, 1'b0, 16'h0000, 12);

        $display("PASS: all 12 main module test cases passed");
        $finish;
    end

    initial begin
        $dumpfile("main_out.vcd");
        $dumpvars(0, main_tb);
    end

endmodule
