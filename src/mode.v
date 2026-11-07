// Toggle mode via a TFF
module mode_toggle(
    input wire clk,
    input wire rst,
    input wire t,
    output reg mode
);
    //  alway run this at the clocks positive edge
    // always @* is logic that responds when it's inputs change
    always @(posedge clk) begin
        if (rst) mode <= 1'b0; // The default state is 0
        else if (t) mode <= ~mode; 
    end
endmodule