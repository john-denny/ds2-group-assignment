module seven_segment_display(
  input wire clk,
  input wire rst,
  input wire mode,
  input wire_error present,
  output reg [6:0] segments,
  output reg [3:0] enable,
  output wire decimal
);

  //counter to switch through each segment (as if all at the same time)
  reg [15:0] refresh_counter;
  reg [1:0] digit;

  //At 100 MHz, each clock cycle is 10 ns
  //Counting 65,536 cycles thus takes 0.655 ms
  always @(posedge clk) begin
    if(rst)
      begin
        refresh_counter <= 16'd0;
        digit <= 2'd0;
      end
    else if refresh_counter == 16'd65535
      begin
        //after 0.655 ms, select digit
        refrsh_counter <= 16'd0;
        digit <= digit + 2'd1;
      end
    else
      begin
        refresh_counter <= refresh_counter + 16'd1;
      end
  end

  assign decimal = 1'b1; // keep decimal point off

  //Basys-3 is active-low
  //segments[6:0] order: g, f, e, d, c, b, a
  always @(*)
    begin
      //default - everything off
      enable = 4'b1111;
      segments = 7'b1111111;

      case(digit)
        2'd0:
          begin
            //enable[0] = 0 enables rightmost; 0 for encoder, E for decoder
            enable = 4'b1110;
            if(error_present)
              segments = mode ? 7'b1000000 : 7'b0000110;
            else
              segments = 7'b1111111 //blank for no error
          end

        2'd1:
          begin
            //second from rightmost; I (small l) for encoder, 2 for decoder
            enable = 4'b1101;
            if(error_present)
              segments = mode ? 7'b1111001 : 7'b0100100;
            else
              segments = 7'b1111111 //blank for no error
          end

        2'd2:
          begin
            //third from rightmost; left blank
            enable = 4'b1011;
            segments = 7'b1111111;

        2'd3:
          begin
            //leftmost; E for encoder, d for decoder
            enable = 4'b0111;
            segments = mode ? 7'b0000110 : 7'0100001;
          end
      endcase
    end
endmodule    
  


            
