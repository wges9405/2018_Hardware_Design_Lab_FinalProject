`timescale 1ns/1ps 

module Parameterized_Ping_Pong_Counter (clk, rst_n, enable, flip, max, min, direction, out);
  input clk, rst_n;
  input enable;
  input flip;
  input [4-1:0] max;
  input [4-1:0] min;
  output direction;
  output [4-1:0] out;
  
  reg [4-1:0] curr_counter, next_counter;
  reg curr_dir, next_dir;
  
  assign out = curr_counter;
  assign direction = curr_dir;
  
  always @(posedge clk) begin
	if (!rst_n) begin
	  curr_counter <= min;
	  curr_dir <= 1'b0;
	end
	else begin
	  curr_counter <= next_counter;
	  curr_dir <= next_dir;
	end
  end
  
  always @* begin
    if (!enable || max <= min || curr_counter > max || curr_counter < min) begin
	  next_counter = curr_counter;
	  next_dir = curr_dir;
	end
	else begin
	  if (flip) begin
	    if (curr_dir == 1'b0)
		  next_counter = curr_counter - 1'b1;
		else
		  next_counter = curr_counter + 1'b1;
		next_dir = !curr_dir;
	  end
	  else begin
	    if (curr_dir == 1'b0) begin
		  if (curr_counter == max) begin
			next_counter = curr_counter - 1'b1;
			next_dir = !curr_dir;
		  end
		  else begin
		    next_counter = curr_counter + 1'b1;
			next_dir = curr_dir;
		  end
		end
		else begin
		  if (curr_counter == min) begin
		    next_counter = curr_counter + 1'b1;
			next_dir = !curr_dir;
		  end
		  else begin
		    next_counter = curr_counter - 1'b1;
			next_dir = curr_dir;
		  end
		end
	  end
	end
  end
endmodule
