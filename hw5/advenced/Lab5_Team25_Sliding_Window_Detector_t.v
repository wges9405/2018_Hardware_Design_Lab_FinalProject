`timescale 1ns/1ps

`define CYC 4

module Sliding_Window_Detector_t;
  reg clk = 1'b1;
  reg rst_n = 1'b0;
  reg in = 1'b0;
  wire dec1, dec2;
  
  Sliding_Window_Detector SWD (
	.clk (clk),
	.rst_n (rst_n),
	.in (in),
	.dec1 (dec1),
	.dec2 (dec2)
  );
  
  always #(`CYC / 2) clk = ~clk;
  
  initial begin
	// Dec1
	@ (negedge clk) in = 1'b0; rst_n = 1'b1;
	@ (negedge clk) in = 1'b0;
	@ (negedge clk) in = 1'b1;
	@ (negedge clk) in = 1'b0;
	
	@ (negedge clk) in = 1'b1;
	@ (negedge clk) in = 1'b0;
	@ (negedge clk) in = 1'b1;
	@ (negedge clk) in = 1'b1;
	
	@ (negedge clk) in = 1'b1;
	@ (negedge clk) in = 1'b0;
	@ (negedge clk) in = 1'b1;
	@ (negedge clk) in = 1'b0;
	
	@ (negedge clk) in = 1'b1;
	@ (negedge clk) in = 1'b0;
	@ (negedge clk) in = 1'b1;
	@ (negedge clk) in = 1'b0;
	@ (negedge clk) in = 1'b1;
	
	// Dec2
	@ (negedge clk) in = 1'b0;
	@ (negedge clk) in = 1'b0;
	@ (negedge clk) in = 1'b1;
	@ (negedge clk) in = 1'b0;
	
	@ (negedge clk) in = 1'b0;
	@ (negedge clk) in = 1'b0;
	@ (negedge clk) in = 1'b0;
	@ (negedge clk) in = 1'b1;
	
	@ (negedge clk) in = 1'b1;
	@ (negedge clk) in = 1'b0;
	@ (negedge clk) in = 1'b1;
	@ (negedge clk) in = 1'b1;
	
	@ (negedge clk) in = 1'b0;
	@ (negedge clk) in = 1'b1;
	@ (negedge clk) in = 1'b1;
	@ (negedge clk) in = 1'b0;
	@ (negedge clk) in = 1'b1;
	
	@ (negedge clk) $finish;
  end
  
endmodule