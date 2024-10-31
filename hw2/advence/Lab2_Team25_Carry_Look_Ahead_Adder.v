`timescale 1ns/1ps

module Carry_Look_Ahead_Adder (a, b, cin, cout, sum);
  input [4-1:0] a, b;
  input cin;
  output cout;
  output [4-1:0] sum;

  wire [4-1:0] p;
  wire [4-1:0] g;
  wire c1, c2, c3;
  wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10;

  ex_or eo1 (a[0], b[0], p[0]);
  ex_or eo2 (a[1], b[1], p[1]);
  ex_or eo3 (a[2], b[2], p[2]);
  ex_or eo4 (a[3], b[3], p[3]);

  and a1 (g[0], a[0], b[0]);
  and a2 (g[1], a[1], b[1]);
  and a3 (g[2], a[2], b[2]);
  and a4 (g[3], a[3], b[3]);

  and a5 (w1, p[0], cin);
  or o1 (c1, g[0], w1);
  
  and a6 (w2, p[1], g[0]);
  and a7 (w3, p[1], p[0], cin);
  or o2 (c2, g[1], w2, w3);
  
  and a8 (w4, p[2], g[1]);
  and a9 (w5, p[2], p[1], g[0]);
  and a10 (w6, p[2], p[1], p[0], cin);
  or o3 (c3, g[2], w4, w5, w6);
  
  and a11 (w7, p[3], g[2]);
  and a12 (w8, p[3], p[2], g[1]);
  and a13 (w9, p[3], p[2], p[1], g[0]);
  and a14 (w10, p[3], p[2], p[1], p[0], cin);
  or o4 (cout, g[3], w7, w8, w9, w10);

  one_bit_full_adder fa1 (a[0], b[0], cin, sum[0]);
  one_bit_full_adder fa2 (a[1], b[1], c1, sum[1]);
  one_bit_full_adder fa3 (a[2], b[2], c2, sum[2]);
  one_bit_full_adder fa4 (a[3], b[3], c3, sum[3]);
endmodule

module ex_or (a, b, c);
  input a, b;
  output c;
  wire Na, Nb, and1, and2;

  not (Na, a);
  not (Nb, b);
  and (and1, Na, b);
  and (and2, Nb, a);
  or (c, and1, and2);
endmodule

module one_bit_full_adder (a, b, cin, s);
  input a, b, cin;
  output s;

  wire chain;
  ///sum
  ex_or eo1 (a, b, chain);
  ex_or eo2 (cin, chain, s);
endmodule