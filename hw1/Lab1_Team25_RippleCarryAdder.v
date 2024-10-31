`timescale 1ns/1ps

module RippleCarryAdder (a, b, cin, cout, sum);
  input [4-1:0] a, b;
  input cin;
  output [4-1:0] sum;
  output cout;

  wire [4-1:0] c;

  one_bit_full_adder F1 ( .a(a[0]), .b(b[0]), .cin(cin), .cout(c[1]), .s(sum[0]) );
  one_bit_full_adder F2 ( .a(a[1]), .b(b[1]), .cin(c[1]), .cout(c[2]), .s(sum[1]) );
  one_bit_full_adder F3 ( .a(a[2]), .b(b[2]), .cin(c[2]), .cout(c[3]), .s(sum[2]) );
  one_bit_full_adder F4 ( .a(a[3]), .b(b[3]), .cin(c[3]), .cout(cout), .s(sum[3]) );
endmodule


module one_bit_full_adder (a, b, cin, s, cout);
  input a, b, cin;
  output s, cout;

  wire chain, m, k ,l;
  ///sum
  ex_or eo1 (a, b, chain);
  ex_or eo2 (cin, chain, s);
  ///cout
  and (m, a, b);
  and (k, b, cin);
  and (l, cin, a);
  or (cout, m, k, l);
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