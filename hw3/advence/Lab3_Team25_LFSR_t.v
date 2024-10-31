`timescale 1ns/1ps

module LFSR_t;
  reg clk=1'b1;
  reg rst_n=1'b1;
  wire out;
  parameter cyc = 4;
  
  LFSR L1( .clk(clk),
           .rst_n(rst_n),
           .out(out)
  );
  
  always # (cyc/2) clk = ~clk;
  
  initial
    begin
	  #(cyc/2) rst_n = 1'b0;
	  #(cyc*3/2) rst_n = 1'b1;
	  #(cyc*9)
	  $finish;
	end
endmodule