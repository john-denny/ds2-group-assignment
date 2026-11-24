`timescale 1ns/1ps

module main_tb();

    localparam DISPLAY_REFRESH_CYCLES = 4;

    reg clk;
    reg rst;
    reg mode_button;
    reg [15:0] input_bits;
    wire [15:0] device_led;
    wire [6:0] segments;
    wire [3:0] enable;
    wire decimal;

    main #(
        .BUTTON_DEBOUNCE_CYCLES(4),
        .DISPLAY_REFRESH_CYCLES(DISPLAY_REFRESH_CYCLES)
    ) dut(
        .clk(clk),
        .rst(rst),
        .mode_button(mode_button),
        .input_bits(input_bits),
        .device_led(device_led),
        .segments(segments),
        .enable(enable),
        .decimal(decimal)
    );

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

    // Hold long enough to pass the small simulation debounce interval.
    task toggle_mode;
        input integer hold_cycles;
        integer i;
        begin
            @(negedge clk);
            mode_button = 1'b1;
            for (i = 0; i < hold_cycles; i = i + 1)
                @(negedge clk);
            mode_button = 1'b0;
            repeat (6) @(negedge clk);
            #2;
        end
    endtask

    task bounce_mode_button;
        begin
            // Short pulses must be rejected by the debounce filter.
            @(negedge clk);
            mode_button = 1'b1;
            @(negedge clk);
            mode_button = 1'b0;
            repeat (3) @(negedge clk);
            mode_button = 1'b1;
            @(negedge clk);
            mode_button = 1'b0;
            repeat (5) @(negedge clk);
            #2;
        end
    endtask

    // Wait for a selected digit and check its active-low segment pattern.
    task check_display_digit;
        input [3:0] expected_enable;
        input [6:0] expected_segments;
        input integer case_number;
        integer cycles_waited;
        begin
            cycles_waited = 0;
            while (enable !== expected_enable &&
                   cycles_waited < DISPLAY_REFRESH_CYCLES * 5 + 2) begin
                @(negedge clk);
                cycles_waited = cycles_waited + 1;
            end

            #1;
            if (enable !== expected_enable)
                $fatal(1, "Display case %0d: enable=%b expected=%b",
                       case_number, enable, expected_enable);
            if (segments !== expected_segments)
                $fatal(1, "Display case %0d: enable=%b segments=%b expected=%b",
                       case_number, enable, segments, expected_segments);
            if (decimal !== 1'b1)
                $fatal(1, "Display case %0d: decimal=%b expected off (1)",
                       case_number, decimal);
        end
    endtask

    // Check one complete scan. Digit 0 is rightmost; digit 3 is leftmost.
    task check_display_frame;
        input [6:0] digit0_segments;
        input [6:0] digit1_segments;
        input [6:0] digit2_segments;
        input [6:0] digit3_segments;
        input integer case_number;
        begin
            check_display_digit(4'b1110, digit0_segments, case_number);
            check_display_digit(4'b1101, digit1_segments, case_number);
            check_display_digit(4'b1011, digit2_segments, case_number);
            check_display_digit(4'b0111, digit3_segments, case_number);
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
        // Syndrome 1 maps to LED 0; syndrome 3 maps to LED 2.
        check_case(16'hfffe, 1'b0, 16'h0001, 2);
        check_display_frame(7'b1111111, 7'b1111111, 7'b1111111,
                           7'b0100001, 15); // Single error: display decoder label d.
        check_case(16'hfffc, 1'b0, 16'h0000, 3);
        check_display_frame(7'b0000110, 7'b0100100, 7'b1111111,
                           7'b0100001, 16); // Double error: display d2E.
        check_case(16'hfffb, 1'b0, 16'h0004, 14);

        bounce_mode_button();
        check_case(16'h0000, 1'b0, 16'h0000, 13);

        // Switch into encoder mode.
        toggle_mode(8);

        check_case(16'h0000, 1'b1, 16'h0000, 4);
        check_case(16'h0001, 1'b1, 16'h8007, 5);
        check_display_frame(7'b1111111, 7'b1111111, 7'b1111111,
                           7'b0000110, 17); // Valid encoder input: display E.
        check_case(16'h0002, 1'b1, 16'h8019, 6);
        check_case(16'h1000, 1'b1, 16'h0000, 18);
        check_display_frame(7'b1000000, 7'b1111001, 7'b1111111,
                           7'b0000110, 18); // Invalid encoder input: display E10.
        check_case(16'h07ff, 1'b1, 16'hffff, 7);

        // Mode should remain unchanged after button release.
        check_case(16'h0004, 1'b1, 16'h802a, 8);

        // Switch back into decoder mode.
        toggle_mode(8);

        check_case(16'h0000, 1'b0, 16'h0000, 9);
        check_case(16'hfffd, 1'b0, 16'h0002, 10);

        // Reset while in encoder mode.
        toggle_mode(8);
        check_case(16'h0001, 1'b1, 16'h8007, 11);

        @(negedge clk);
        rst = 1'b1;
        @(negedge clk);
        rst = 1'b0;
        #2;

        check_case(16'h0000, 1'b0, 16'h0000, 12);

        $display("PASS: main functional, display, and debounce checks passed");
        $finish;
    end

    initial begin
        $dumpfile("main_out.vcd");
        $dumpvars(0, main_tb);
    end

endmodule
