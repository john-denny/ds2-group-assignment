// Synchronize and debounce the active-high mode button.
// DEBOUNCE_CYCLES defaults to 10 ms on the Basys 3's 100 MHz clock.
module button_debounce #(
    parameter DEBOUNCE_CYCLES = 1_000_000
)(
    input wire clk,
    input wire rst,
    input wire button_in,
    output reg press_pulse
);
    localparam COUNTER_WIDTH = (DEBOUNCE_CYCLES <= 1) ? 1 : $clog2(DEBOUNCE_CYCLES);

    reg button_sync_1;
    reg button_sync_2;
    reg button_state;
    reg [COUNTER_WIDTH-1:0] stable_count;

    always @(posedge clk) begin
        if (rst) begin
            button_sync_1 <= 1'b0;
            button_sync_2 <= 1'b0;
            button_state <= 1'b0;
            stable_count <= {COUNTER_WIDTH{1'b0}};
            press_pulse <= 1'b0;
        end else begin
            button_sync_1 <= button_in;
            button_sync_2 <= button_sync_1;
            press_pulse <= 1'b0;

            if (button_sync_2 == button_state) begin
                stable_count <= {COUNTER_WIDTH{1'b0}};
            end else if (stable_count == DEBOUNCE_CYCLES - 1) begin
                button_state <= button_sync_2;
                stable_count <= {COUNTER_WIDTH{1'b0}};
                if (button_sync_2)
                    press_pulse <= 1'b1;
            end else begin
                stable_count <= stable_count + 1'b1;
            end
        end
    end
endmodule

// Toggle mode once for each debounced press.
module mode_toggle #(
    parameter DEBOUNCE_CYCLES = 1_000_000
)(
    input wire clk,
    input wire rst,
    input wire t,
    output reg mode
);
    wire press_pulse;

    button_debounce #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) debounce(
        .clk(clk),
        .rst(rst),
        .button_in(t),
        .press_pulse(press_pulse)
    );

    always @(posedge clk) begin
        if (rst)
            mode <= 1'b0;
        else if (press_pulse)
            mode <= ~mode;
    end
endmodule
