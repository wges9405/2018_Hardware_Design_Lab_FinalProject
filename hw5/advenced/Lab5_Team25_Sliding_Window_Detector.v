`timescale 1ns/1ps

module Sliding_Window_Detector (clk, rst_n, in, dec1, dec2);
	input clk, rst_n;
	input in;
	output dec1, dec2;
	
	parameter F0 = 3'd0, F1 = 3'd1, F2 = 3'd2, F3 = 3'd3, F4 = 3'd4;
	parameter S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3;
	
	reg [2:0] state1, next_state1;
	reg [1:0] state2, next_state2;
	reg dec1, dec2;
	
	always @(posedge clk) begin
		if (!rst_n) begin
			state1 <= F0;
			state2 <= S0;
		end
		else begin
			state1 <= next_state1;
			state2 <= next_state2;
		end
	end
	
	always @* begin
		case (state1)
			F0: begin
				if (in) begin
					next_state1 = F1;
					dec1 = 1'b0;
				end
				else begin
					next_state1 = F0;
					dec1 = 1'b0;
				end
			end
			F1: begin
				if (in) begin
					next_state1 = F3;
					dec1 = 1'b0;
				end
				else begin
					next_state1 = F2;
					dec1 = 1'b0;
				end
			end
			F2: begin
				if (in) begin
					next_state1 = F1;
					dec1 = 1'b1;
				end
				else begin
					next_state1 = F0;
					dec1 = 1'b0;
				end
			end
			F3: begin
				if (in) begin
					next_state1 = F4;
					dec1 = 1'b0;
				end
				else begin
					next_state1 = F2;
					dec1 = 1'b0;
				end
			end
			F4: begin
				next_state1 = F4;
				dec1 = 1'b0;
			end
			default: begin
				next_state1 = state1;
				dec1 = 1'b0;
			end
		endcase
	end
	
	always @* begin
		case (state2)
			S0: begin
				if (in) begin
					next_state2 = S0;
					dec2 = 1'b0;
				end
				else begin
					next_state2 = S1;
					dec2 = 1'b0;
				end
			end
			S1: begin
				if (in) begin
					next_state2 = S2;
					dec2 = 1'b0;
				end
				else begin
					next_state2 = S1;
					dec2 = 1'b0;
				end
			end
			S2: begin
				if (in) begin
					next_state2 = S3;
					dec2 = 1'b0;
				end
				else begin
					next_state2 = S1;
					dec2 = 1'b0;
				end
			end
			S3: begin
				if (in) begin
					next_state2 = S0;
					dec2 = 1'b0;
				end
				else begin
					next_state2 = S1;
					dec2 = 1'b1;
				end
			end
			default: begin
				next_state2 = state2;
				dec2 = 1'b0;
			end
		endcase
	end
endmodule
