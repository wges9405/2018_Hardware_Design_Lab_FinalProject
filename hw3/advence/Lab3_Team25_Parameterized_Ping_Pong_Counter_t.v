`timescale 1ns/1ps

module Parameterized_Ping_Pong_Counter_t;
  parameter cyc = 2;
  
  reg clk, rst, en, flip;
  reg [3:0] max, min;
  wire dir;
  wire [3:0] out;

  Parameterized_Ping_Pong_Counter PPPC1 (
	.clk (clk), 
	.rst_n (rst), 
	.enable (en), 
	.flip (flip), 
	.max (max), 
	.min (min), 
	.direction (dir), 
	.out (out)
  );

  always #(cyc/2) clk = ~clk;
  
  initial begin
	clk = 1;
	rst = 1;
	en = 0;
	flip = 0;
	max = 4'd15;
	min = 4'd0;
	
	@(negedge clk);
	rst = 0;
	@(negedge clk);
	rst = 1;
	en = 1;
	
	#(cyc*38);
	flip = 1;
	#(cyc);
	flip = 0;
	#(cyc);
	#(cyc*16);
	en = 0;
	#(cyc*4);
	en = 1;
	#(cyc*20);
	rst = 0;
	min = 4'd8;
	max = 4'd11;
	#(cyc);
	rst = 1;
	#(cyc*16);
	min = 4'd15;
	max = 4'd0;
	#(cyc*4);
	min = 4'd0;
	max = 4'd15;
	#(cyc*16);
	
	$finish;
  end
endmodule
