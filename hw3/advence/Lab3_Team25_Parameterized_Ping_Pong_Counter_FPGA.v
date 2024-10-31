`timescale 10ns/1ps

module Top_module (clk, rst_n, flip, max, min, enable, AN, segment);
  input clk, rst_n, flip, enable;
  input [4-1:0] max, min;
  output [4-1:0] AN;	 ///[3:0] -> [left:right]
  output [8-1:0] segment;///[7,6,5,4,3,2,1,0] -> [DH,G,F,E,D,C,B,A]

  wire flip_debounced, flip_one_pulse;
  wire rst_n_debounced, rst_n_one_pulse;
  wire direction;
  wire [4-1:0] out;

  debounce D_flip ( .clk(clk), .pb(flip), .pb_debounced(flip_debounced));
  onepulse O_flip ( .clk(clk), .pb_debounced(flip_debounced), .pb_one_pulse(flip_one_pulse) );

  debounce D_rst ( .clk(clk), .pb(rst_n), .pb_debounced(rst_n_debounced));
  onepulse O_rst ( .clk(clk), .pb_debounced(rst_n_debounced), .pb_one_pulse(rst_n_one_pulse) );

  Parameterized_Ping_Pong_Counter P1 (
	.clk(clk),
	.rst_n(!rst_n_one_pulse),
	.flip(flip_one_pulse),
	.max(max),
	.min(min),
	.enable(enable),
	.direction(direction),
	.out(out)
  );

  AN_replace Ar ( .clk(clk), .rst_n(!rst_n_one_pulse), .AN(AN) );
  binary_to_segment bts( .AN(AN), .direction(direction), .digit(out), .segment(segment) );

endmodule

module AN_replace (clk, rst_n, AN);
  input clk, rst_n;
  output [4-1:0] AN;
  reg [4-1:0] AN;
  reg rst_n_for_AN;
  wire clk2_17;

  Divider_by_2_17 forAN ( .clk(clk), .rst_n(rst_n), .clk2_17(clk2_17) );

  always @(posedge clk2_17, negedge rst_n) begin
    if (!rst_n) rst_n_for_AN = 1'b0;
	else rst_n_for_AN = 1'b1;
  end

  always @(posedge clk2_17) begin
    if (!rst_n_for_AN) AN <= 4'b1110;
	else begin
	  AN[3:1] <= AN[2:0];
	  AN[0] <= AN[3];
	end
  end
endmodule

module binary_to_segment (AN, direction, digit, segment);
  input direction;
  input [4-1:0] AN, digit;
  output [8-1:0] segment;
  reg [8-1:0] segment;

  always @* begin
    if (AN == 4'b0111 || AN == 4'b1011) begin
	  if (direction == 1'b0) segment = 8'b11011100;
	  else segment = 8'b11100011;
	end
	else if (AN == 4'b1101) begin
	  if (digit > 4'b1001) segment = 8'b11111001;
	  else segment = 8'b11000000;
	end
	else if (AN == 4'b1110) begin
	  case (digit)
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
	    4'd10:		segment = 8'b11000000;
		4'd11:		segment = 8'b11111001;
		4'd12:		segment = 8'b10100100;
		4'd13:		segment = 8'b10110000;
		4'd14:		segment = 8'b10011001;
		4'd15:		segment = 8'b10010010;
		default:	segment = 8'b11111111;
	  endcase
	end
  end
endmodule

module Parameterized_Ping_Pong_Counter (clk, rst_n, enable, flip, max, min, direction, out);
  input clk, rst_n, enable, flip;
  input [4-1:0] max, min;
  output direction;
  output [4-1:0] out;

  reg [4-1:0] curr_counter, next_counter;
  reg curr_dir, next_dir;
  reg flip_for_PPC, rst_n_for_PPC;
  wire clk2_26;

  Divider_by_2_26 forDIGIT ( .clk(clk), .rst_n(rst_n), .clk2_26(clk2_26) );

  assign out = curr_counter;
  assign direction = curr_dir;

  always @(posedge clk2_26, posedge flip) begin
    if (flip) flip_for_PPC = 1'b1;
	else flip_for_PPC = 1'b0;
  end

  always @(posedge clk2_26, negedge rst_n) begin
    if (!rst_n) rst_n_for_PPC = 1'b0;
	else rst_n_for_PPC = 1'b1;
  end

  always @(posedge clk2_26) begin
	if (!rst_n_for_PPC) begin
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
	  if (flip_for_PPC) begin
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



module Divider_by_2_17 (clk, rst_n, clk2_17);
  input clk, rst_n;
  output [17-1:0] clk2_17;
  reg [17-1:0] counter;

  assign clk2_17 = counter[16];

  always @ (posedge clk) begin
	if (!rst_n) counter <= 17'd0;
	else counter <= counter + 1'b1;
  end
endmodule

module Divider_by_2_26 (clk, rst_n, clk2_26);
  input clk, rst_n;
  output [26-1:0] clk2_26;
  reg [26-1:0] counter;

  assign clk2_26 = counter[25];

  always @ (posedge clk) begin
	if (!rst_n) counter <= 26'd0;
	else counter <= counter + 1'b1;
  end
endmodule

module debounce (clk, pb, pb_debounced);
  input pb, clk;
  output pb_debounced;
  reg [4-1:0] DFF;

  assign pb_debounced = ((DFF == 4'b1111) ? 1'b1 : 1'b0);

  always @(posedge clk) begin
    DFF[3:1] <= DFF[2:0];
    DFF[0] <= pb;
  end
endmodule

module onepulse (clk, pb_debounced, pb_one_pulse);
  input pb_debounced, clk;
  output pb_one_pulse;

  reg pb_debounced_delay, pb_one_pulse;

  always @(posedge clk) begin
    pb_one_pulse <= pb_debounced & !pb_debounced_delay;
    pb_debounced_delay <= pb_debounced;
  end
endmodule
