`timescale 1ns/1ps

module Seven_Segment_LED (sum, a, b, c, d, e, f, g);
  input [4-1:0] sum;
  output a, b, c, d, e, f, g;
  
  wire [4-1:0] nsum;
  wire m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15;
  
  not n1 (nsum[0], sum[0]);
  not n2 (nsum[1], sum[1]);
  not n3 (nsum[2], sum[2]);
  not n4 (nsum[3], sum[3]);
  
  and a1 (m0, nsum[3], nsum[2], nsum[1], nsum[0]);
  and a2 (m1, nsum[3], nsum[2], nsum[1], sum[0]);
  and a3 (m2, nsum[3], nsum[2], sum[1], nsum[0]);
  and a4 (m3, nsum[3], nsum[2], sum[1], sum[0]);
  and a5 (m4, nsum[3], sum[2], nsum[1], nsum[0]);
  and a6 (m5, nsum[3], sum[2], nsum[1], sum[0]);
  and a7 (m6, nsum[3], sum[2], sum[1], nsum[0]);
  and a8 (m7, nsum[3], sum[2], sum[1], sum[0]);
  and a9 (m8, sum[3], nsum[2], nsum[1], nsum[0]);
  and a10 (m9, sum[3], nsum[2], nsum[1], sum[0]);
  and a11 (m10, sum[3], nsum[2], sum[1], nsum[0]);
  and a12 (m11, sum[3], nsum[2], sum[1], sum[0]);
  and a13 (m12, sum[3], sum[2], nsum[1], nsum[0]);
  and a14 (m13, sum[3], sum[2], nsum[1], sum[0]);
  and a15 (m14, sum[3], sum[2], sum[1], nsum[0]);
  and a16 (m15, sum[3], sum[2], sum[1], sum[0]);
  
  or o1 (a, m1, m4, m11, m13);
  or o2 (b, m5, m6, m11, m12, m14, m15);
  or o3 (c, m2, m12, m14, m15);
  or o4 (d, m1, m4, m7, m10, m15);
  or o5 (e, m1, m3, m4, m5, m7, m9);
  or o6 (f, m1, m2, m3, m7, m13);
  or o7 (g, m0, m1, m7, m12);
endmodule

module Carry_Look_Ahead_Adder (a, b, cin, cout, ledA, ledB, ledC, ledD, ledE, ledF, ledG, AN);
  input [4-1:0] a, b;
  input cin;
  output cout;
  wire [4-1:0] sum;
  output ledA, ledB, ledC, ledD, ledE, ledF, ledG;
  output [4-1:0] AN;

  wire [4-1:0] p;
  wire [4-1:0] g;
  wire c1, c2, c3;
  wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10;
  wire tmp_cout;

  and aa1 (AN[3], 1, 1);
  and aa2 (AN[2], 1, 1);
  and aa3 (AN[1], 1, 1);
  and aa4 (AN[0], 0, 0);
  
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
  or o4 (tmp_cout, g[3], w7, w8, w9, w10);
  not n1 (cout, tmp_cout);

  one_bit_full_adder fa1 (a[0], b[0], cin, sum[0]);
  one_bit_full_adder fa2 (a[1], b[1], c1, sum[1]);
  one_bit_full_adder fa3 (a[2], b[2], c2, sum[2]);
  one_bit_full_adder fa4 (a[3], b[3], c3, sum[3]);
  
  Seven_Segment_LED led1 (sum, ledA, ledB, ledC, ledD, ledE, ledF, ledG);
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