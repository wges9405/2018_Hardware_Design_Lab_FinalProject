`timescale 1ns/1ps

module Greatest_Common_Divisor (clk, rst_n, start, a, b, done, gcd);
  input clk, rst_n;
  input start;
  input [8-1:0] a;
  input [8-1:0] b;
  output reg done;
  output reg [8-1:0] gcd;
  
  parameter WAIT = 2'b00;
  parameter CAL = 2'b01;
  parameter FINISH = 2'b10;
  reg [2-1:0] state, next_state;
  reg [8-1:0] cur_a, next_a;
  reg [8-1:0] cur_b, next_b;
  
  always@(posedge clk)begin
	if(!rst_n)begin
		state <= WAIT;
		cur_a <= a;
		cur_b <= b;
	end
	else begin
		state <= next_state;
		cur_a <= next_a;
		cur_b <= next_b;
	end
  end
  
  always@(*)begin
	case(state)
		WAIT: begin
			done = 1'b0;
			gcd = 8'd0;
			next_a = a;
			next_b = b;
			if(start == 1)begin
				next_state = CAL;
			end
			else begin
				next_state = WAIT;
			end
		end
		CAL: begin
			done = 1'b0;
			gcd = 8'd0;
			if(cur_a == 0 || cur_b == 0)begin
				next_state = FINISH;
				if(cur_a == 0)begin
					next_a = cur_b;
					next_b = cur_a;
				end
				else begin
					next_a = cur_a;
					next_b = cur_b;
				end
			end
			else begin
				next_state = CAL;
				if(cur_a > cur_b)begin
					next_a = cur_a - cur_b;
					next_b = cur_b;
				end
				else begin
					next_a = cur_a;
					next_b = cur_b - cur_a;
				end
			end
		end
		FINISH: begin
			done = 1'b1;
			gcd = cur_a;
			next_state = WAIT;
			next_a = cur_a;
			next_b = cur_b;
		end
		default: begin
			next_state = state;
			next_a = cur_a;
			next_b = cur_b;
		end
	endcase
  end
  
endmodule
