`timescale 10ns/1ps

module Stopwatch (clk, rst_n, start, AN, segment);
  input clk, rst_n, start;
  output [4-1:0] AN;
  output [8-1:0] segment;
  
  wire rst_n_debounced, rst_n_one_pulse;
  wire start_debounced, start_one_pulse;
  wire [4-1:0] digit3, digit2, digit1, digit0;
  
  Debounce D_start ( .clk(clk), .pb(start), .pb_debounced(start_debounced));
  Onepulse O_start ( .clk(clk), .pb_debounced(start_debounced), .pb_one_pulse(start_one_pulse) );
  
  Debounce D_rst ( .clk(clk), .pb(rst_n), .pb_debounced(rst_n_debounced));
  Onepulse O_rst ( .clk(clk), .pb_debounced(rst_n_debounced), .pb_one_pulse(rst_n_one_pulse) );
  
  Finite_State_Machine FSM (
	.clk(clk), 
	.rst_n(!rst_n_one_pulse), 
	.start(start_one_pulse), 
	.digit3(digit3), 
	.digit2(digit2), 
	.digit1(digit1), 
	.digit0(digit0)
  );
  
  AN_replace Ar ( .clk(clk), .rst_n(!rst_n_one_pulse), .AN(AN) );
  Binary_to_Segment BtoS (AN, digit3, digit2, digit1, digit0, segment);
endmodule

module Debounce (clk, pb, pb_debounced);
  input pb, clk;
  output pb_debounced;
  reg [4-1:0] DFF;

  assign pb_debounced = ((DFF == 4'b1111) ? 1'b1 : 1'b0);
  
  always @(posedge clk) begin
    DFF[3:1] <= DFF[2:0];
    DFF[0] <= pb;
  end
endmodule

module Onepulse (clk, pb_debounced, pb_one_pulse);
  input pb_debounced, clk;
  output pb_one_pulse;
  
  reg pb_debounced_delay, pb_one_pulse;
  
  always @(posedge clk) begin
    pb_one_pulse <= pb_debounced & !pb_debounced_delay;
    pb_debounced_delay <= pb_debounced;
  end
endmodule

module Finite_State_Machine (clk, rst_n, start, digit3, digit2, digit1, digit0);
  input clk, rst_n, start;
  output reg [4-1:0] digit3, digit2, digit1, digit0;
  reg [4-1:0] next_digit3, next_digit2, next_digit1, next_digit0;
  reg [2-1:0] state, next_state;
  reg [24-1:0] counter, next_counter;
  parameter RESET = 2'b00, WAIT = 2'b01, COUNT = 2'b10;
  
  always @ (posedge clk) begin
	if(!rst_n)begin
		counter <= 24'd0;
		state <= RESET;
		{digit3,digit2,digit1,digit0} <= 16'd0;
	end
	else begin
		counter <= next_counter;
		state <= next_state;
		{digit3,digit2,digit1,digit0} = (counter == 24'd0) ? {next_digit3,next_digit2,next_digit1,next_digit0} : {digit3,digit2,digit1,digit0};
	end
  end
  
  always @ (*) begin
	next_counter = (counter == 24'd9999999) ? 24'd0 : (counter + 24'b1);
  end
  
  always@(*)begin
	case(state)
		RESET: begin
			next_state = WAIT;
			{next_digit3,next_digit2,next_digit1,next_digit0} = 16'd0;
		end
		WAIT: begin
			next_state = (start) ? COUNT : state;
			{next_digit3,next_digit2,next_digit1,next_digit0} = 16'd0;
		end
		COUNT: begin
			next_state = ({digit3,digit2,digit1,digit0} = 16'b1001_1001_0101_1001) ? WAIT : state;
			
			if({digit3,digit2,digit1,digit0} = 16'b1001_1001_0101_1001)
				{next_digit3,next_digit2,next_digit1,next_digit0} = 16'b0;
			else begin
				next_digit0 = (digit0 == 4'b1001) ? 4'd0 : digit0 + 1'b1;
				if ({digit3,digit2,digit1,digit0} = 16'bxxxx_xxxx_xxxx_1001) next_digit1 = (digit1 == 4'b1001) ? 4'd0 : digit1 + 1'b1;
				else next_digit1 = digit1;
				if ({digit3,digit2,digit1,digit0} = 16'bxxxx_xxxx_0101_1001) next_digit2 = (digit2 == 4'b0101) ? 4'd0 : digit2 + 1'b1;
				else next_digit2 = digit2;
				if ({digit3,digit2,digit1,digit0} = 16'bxxxx_1001_0101_1001) next_digit3 = (digit3 == 4'b1001) ? 4'd0 : digit3 + 1'b1;
				else next_digit3 = digit3;
			end
		end
		default: begin
			next_state = state;
			{next_digit3,next_digit2,next_digit1,next_digit0} = {digit3,digit2,digit1,digit0};
		end
	endcase
  end
endmodule

module AN_replace (clk, rst_n, AN);
  input clk, rst_n;
  output reg [4-1:0] AN;
  reg [17-1:0] counter, next_counter;
  
  always @ (posedge clk) begin
	if (!rst_n)begin
		counter <= 17'd0;
		AN <= 4'b1110;
	end
	else begin
		counter <= next_counter;
		case(next_counter[16:15])
			2'b00: AN <= 4'b1110;
			2'b01: AN <= 4'b1101;
			2'b10: AN <= 4'b1011;
			2'b11: AN <= 4'b0111;
		endcase
	end
  end
  
  always @ (*) begin
	next_counter = counter + 17'b1;
  end
endmodule

module Binary_to_Segment (AN, digit3, digit2, digit1, digit0, segment);
  input [4-1:0] AN;
  input [4-1:0] digit3, digit2, digit1, digit0;
  output reg [8-1:0] segment;
  
  always @(*) begin
	if (AN == 4'b0111) begin
	  case (digit3)
		4'd0:		segment = 8'b11000000;
		4'd1:		segment = 8'b11111001;
		4'd2:		segment = 8'b10100100;
		4'd3:		segment = 8'b10110000;
		4'd4:		segment = 8'b10011001;
		4'd5:		segment = 8'b10010010;
		4'd6:		segment = 8'b10000010;
		4'd7:		segment = 8'b11111000;
		4'd8:		segment = 8'b10000000;
		4'd9:		segment = 8'b10010000;
		default:	segment = 8'b11111111;
	  endcase
	end
	else if (AN == 4'b1011) begin
	  case (digit2)
		4'd0:		segment = 8'b11000000;
		4'd1:		segment = 8'b11111001;
		4'd2:		segment = 8'b10100100;
		4'd3:		segment = 8'b10110000;
		4'd4:		segment = 8'b10011001;
		4'd5:		segment = 8'b10010010;
		default:	segment = 8'b11111111;
	  endcase
	end
	else if (AN == 4'b1101) begin
	  case (digit1)
		4'd0:		segment = 8'b01000000;
		4'd1:		segment = 8'b01111001;
		4'd2:		segment = 8'b00100100;
		4'd3:		segment = 8'b00110000;
		4'd4:		segment = 8'b00011001;
		4'd5:		segment = 8'b00010010;
		4'd6:		segment = 8'b00000010;
		4'd7:		segment = 8'b01111000;
		4'd8:		segment = 8'b00000000;
		4'd9:		segment = 8'b00010000;
		default:	segment = 8'b01111111;
	  endcase
	end
	else if (AN == 4'b1110) begin
	  case (digit0)
		4'd0:		segment = 8'b11000000;
		4'd1:		segment = 8'b11111001;
		4'd2:		segment = 8'b10100100;
		4'd3:		segment = 8'b10110000;
		4'd4:		segment = 8'b10011001;
		4'd5:		segment = 8'b10010010;
		4'd6:		segment = 8'b10000010;
		4'd7:		segment = 8'b11111000;
		4'd8:		segment = 8'b10000000;
		4'd9:		segment = 8'b10010000;
		default:	segment = 8'b11111111;
	  endcase
	end
  end
endmodule
