`timescale 1ns/1ps

module Ping_Pong_Counter (clk, rst_n, enable, direction, out);
  input clk, rst_n, enable;
  output direction;
  output [4-1:0] out;
  
  reg [4-1:0] cur_out, next_out;
  reg cur_dir, next_dir;
  
  assign out = cur_out;
  assign direction = cur_dir;
  
  always @ (posedge clk, negedge rst_n)
    begin
	  if (!rst_n && clk)
	    begin
		  cur_dir <= 1'b0;
		  cur_out <= 4'b0;
		end
	  else
	    begin
	      cur_dir <= next_dir;
		  cur_out <= next_out;
		end
	end
  
  always @ (*) begin
	if (enable) begin
	  if (cur_dir == 1'b0) begin
		next_dir = cur_dir;
		if (cur_out == 4'b1111) begin
		  next_out = cur_out - 1'b1;
		  next_dir = cur_dir + 1'b1;
		end
		else
		  next_out = cur_out + 1'b1;			
	  end
	  
	  else if (cur_dir == 1'b1) begin
	    next_dir = cur_dir;
		if (cur_out == 4'b0) begin
		  next_out = cur_out + 1'b1;
		  next_dir = cur_dir + 1'b1;
		end
		else
		  next_out = cur_out - 1'b1;
	  end
	end
	else
	    begin
		  next_dir = cur_dir;
		  next_out = cur_out;
		end
	end
endmodule