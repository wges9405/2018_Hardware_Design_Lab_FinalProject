`timescale 1ns/1ps

module Mealy_Sequence_Detector (clk, rst_n, in, dec);
	input clk, rst_n;
	input in;
	output dec;
	
	parameter S0 = 4'd0;
	parameter S1 = 4'd1, S2 = 4'd2, S3 = 4'd3;
	parameter S4 = 4'd4, S5 = 4'd5, S6 = 4'd6;
	parameter N2 = 4'd7, N3 = 4'd8;
	
	reg [3:0] state, next_state;
	reg dec;
	
	always @(posedge clk) begin
		if (!rst_n) state <= S0;
		else state <= next_state;
	end
	
	always @* begin
		case (state)
			S0: begin
				if (in) begin
					next_state = S1;
					dec = 1'b0;
				end
				else begin
					next_state = S4;
					dec = 1'b0;
				end
			end
			S1: begin
				if (in) begin
					next_state = S2;
					dec = 1'b0;
				end
				else begin
					next_state = N2;
					dec = 1'b0;
				end
			end
			S2: begin
				if (in) begin
					next_state = N3;
					dec = 1'b0;
				end
				else begin
					next_state = S3;
					dec = 1'b0;
				end
			end
			S3: begin
				next_state = S0;
				if (in) dec = 1'b0;
				else dec = 1'b1;
			end
			
			S4: begin
				if (in) begin
					next_state = N2;
					dec = 1'b0;
				end
				else begin
					next_state = S5;
					dec = 1'b0;
				end
			end
			S5: begin
				if (in) begin
					next_state = S6;
					dec = 1'b0;
				end
				else begin
					next_state = N3;
					dec = 1'b0;
				end
			end
			S6: begin
				next_state = S0;
				if (in) dec = 1'b1;
				else dec = 1'b0;
			end
			
			N2: begin
				next_state = N3;
				dec = 1'b0;
			end
			N3: begin
				next_state = S0;
				dec = 1'b0;
			end
			default: begin
				next_state = S0;
				dec = 1'b0;
			end
		endcase
	end
endmodule
