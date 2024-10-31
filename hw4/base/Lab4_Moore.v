`timescale 1ns/1ps

module Moore (clk, rst_n, in, out, state);
  input clk, rst_n, in;
  output out;
  output [2-1:0] state;
  
  parameter S0 = 2'b00;
  parameter S1 = 2'b01;
  parameter S2 = 2'b10;
  parameter S3 = 2'b11;
  
  reg [1:0] curr_state, next_state;
  assign out = (curr_state == S1 || curr_state == S3) ?1 :0;
  assign state = curr_state;
  
  always @(posedge clk) begin
	if (!rst_n) curr_state <= S0;
	else curr_state <= next_state;
  end
  
  always @* begin
	case(curr_state)
	  S0: begin
	    if (in) next_state = S1;
		else next_state = curr_state;
	  end
	  S1: begin
	    if (in) next_state = curr_state;
		else next_state = S2;
	  end
	  S2: begin
	    if (in) next_state = S3;
		else next_state = S0;
	  end
	  S3:begin
	    if (in) next_state = S1;
		else next_state = S2;
	  end
    endcase
  end
endmodule