`timescale 1ns/1ps

`define CYC 4

module Greatest_Common_Divisor_t;
  reg clk = 1'b1;
  reg rst_n = 1'b1;
  reg start = 1'b0;
  reg [8-1:0] a = 8'd0;
  reg [8-1:0] b = 8'd0;
  wire done;
  wire [8-1:0] gcd;
  
  Greatest_Common_Divisor GCD (
	.clk (clk),
	.rst_n (rst_n),
	.start (start),
	.a (a),
	.b (b),
	.done (done),
	.gcd (gcd)
  );
  
  always #(`CYC / 2) clk = ~clk;
  
  initial begin
	@ (negedge clk) rst_n = 1'b0;
	@ (negedge clk) a = 8'd48; b = 8'd32; rst_n = 1'b1;
	@ (negedge clk) start = 1'b1;
	@ (negedge clk) start = 1'b0;
	# (`CYC*10)
	
	@ (negedge clk) a = 8'd21; b = 8'd36;
	@ (negedge clk) start = 1'b1;
	@ (negedge clk) start = 1'b0;
	# (`CYC*10)
	
	@ (negedge clk) a = 8'd16; b = 8'd16;
	@ (negedge clk) start = 1'b1;
	@ (negedge clk) start = 1'b0;
	# (`CYC*10)
	
	@ (negedge clk) a = 8'd0; b = 8'd0;
	@ (negedge clk) start = 1'b1;
	@ (negedge clk) start = 1'b0;
	# (`CYC*10)
	
	@ (negedge clk) $finish;
  end
  
endmodule