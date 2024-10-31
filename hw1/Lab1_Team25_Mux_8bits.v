`timescale 1ns/1ps

module Mux_8bits (a, b, sel, f);
  input [8-1:0] a, b;
  input sel;
  output [8-1:0] f;

  wire Nsel;
  wire [8-1:0] p, q;

  not N (Nsel, sel);
  and A[7:0] (p, sel, a);
  and B[7:0] (q, Nsel, b);
  or C[7:0] (f, p, q);
endmodule
