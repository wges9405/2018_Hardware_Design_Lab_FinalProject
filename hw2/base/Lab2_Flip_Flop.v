`timescale 1ns/1ps

module Flip_Flop (clk, d, q);
  input clk;
  input d;
  output q;
  wire nclk, Y;
  
  not n1 (nclk, clk);
  
  Latch Master (
    .clk (nclk),
    .d (d),
    .q (Y)
  );

  Latch Slave (
    .clk (clk),
    .d (Y),
    .q (q)
  );
endmodule

module Latch (clk, d, q);
  input clk;
  input d;
  output q;
  wire w1, w2, w4, nd;
  
  not N1(nd, d);
  nand Na1 (w1, d, clk);
  nand Na2 (w2, nd, clk);
  nand Na3 (w3, w1, w4);
  nand Na4 (w4, w2, w3);
  and a1 (q, w3, w3);
endmodule


