`timescale 1ns/1ps

module Mealy_Sequence_Detector (clk, rst_n, in, dec);
  input clk, rst_n;
  input in;
  output reg dec;
  
  parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011;
  parameter nS1 = 3'b100, nS2 = 3'b101, nS3 = 3'b110;
  reg [2:0] state, next_state;
  
  always@(posedge clk)begin
	if(!rst_n)begin
		state <= S0;
	end
	else begin
		state <= next_state;
	end
  end
  
  always@(*)begin
	case(state)
		S0: begin
			if(in == 1)begin
				next_state = S1;
				dec = 0;
			end
			else begin
				next_state = nS1;
				dec = 0;
			end
		end
		S1: begin
			if(in == 1)begin
				next_state = nS2;
				dec = 0;
			end
			else begin
				next_state = S2;
				dec = 0;
			end
		end
		S2: begin
			if(in == 1)begin
				next_state = nS3;
				dec = 0;
			end
			else begin
				next_state = S3;
				dec = 0;
			end
		end
		S3: begin
			if(in == 1)begin
				next_state = S0;
				dec = 1;
			end
			else begin
				next_state = S0;
				dec = 0;
			end
		end
		nS1: begin
			if(in == 1)begin
				next_state = nS2;
				dec = 0;
			end
			else begin
				next_state = nS2;
				dec = 0;
			end
		end
		nS2: begin
			if(in == 1)begin
				next_state = nS3;
				dec = 0;
			end
			else begin
				next_state = nS3;
				dec = 0;
			end
		end
		nS3: begin
			if(in == 1)begin
				next_state = S0;
				dec = 0;
			end
			else begin
				next_state = S0;
				dec = 0;
			end
		end
		default: begin
			next_state = state;
		end
	endcase
  end  
endmodule
