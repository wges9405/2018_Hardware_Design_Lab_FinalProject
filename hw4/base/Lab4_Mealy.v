`timescale 1ns/1ps

module Mealy (clk, rst_n, in, out, state);
  input clk, rst_n, in;
  output out;
  output [1:0] state;
  
  parameter S0 = 2'b00;
  parameter S1 = 2'b01;
  parameter S2 = 2'b10;
  
  reg [1:0] curr_state, next_state;
  reg out;
  assign state = curr_state;
  
  always @(posedge clk) begin
	if (!rst_n) curr_state <= S0;
	else curr_state <= next_state;
  end
  
  always @* begin
    case (curr_state)
	  S0: begin
	    if (in) begin
		  next_state = S1;
		  out = 1;
		end
		else begin
		  next_state = S0;
		  out = 0;
		end
	  end
	  
	  S1: begin
	    if (in) begin
		  next_state = S2;
		  out = 0;
		end
		else begin
		  next_state = S1;
		  out = 1;
		end
	  end
	  
	  S2: begin
	    if (in) begin
		  next_state = S1;
		  out = 0;
		end
		else begin
		  next_state = S0;
		  out = 0;
		end
	  end
	endcase
  end
endmodule