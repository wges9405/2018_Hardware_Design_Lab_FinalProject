`timescale 1ns/1ps

module Multiplier (a, b, p);
  input [4-1:0] a, b;
  output [8-1:0] p;
  wire [4-1:0] tmp_p1, tmp_p2, tmp_p3, tmp_p4;
  wire [5-1:0] tmp_p5, tmp_p6;
  wire [2-1:0] carry;
  wire invalid;
  
  Mul_2bit M0 ( .a(a[1:0]), .b(b[1:0]), .p({tmp_p1[3:2], p[1:0]}) );
  Mul_2bit M1 ( .a(a[3:2]), .b(b[1:0]), .p(tmp_p2) );
  Mul_2bit M2 ( .a(a[1:0]), .b(b[3:2]), .p(tmp_p3) );
  Mul_2bit M3 ( .a(a[3:2]), .b(b[3:2]), .p(tmp_p4) );
  
  four_bit_Full_Adder F1 ( .a({2'b0, tmp_p1[3:2]}),
						   .b(tmp_p2),
						   .cin(1'b0),
						   .cout(tmp_p5[4]),
						   .sum(tmp_p5[3:0])
  );
  four_bit_Full_Adder F2 ( .a(tmp_p5[3:0]),
						   .b(tmp_p3),
						   .cin(1'b0),
						   .cout(tmp_p6[4]),
						   .sum({tmp_p6[3:2],p[3:2]})
  );
  one_bit_Full_Adder O1 ( .a(tmp_p5[4]),
						  .b(tmp_p6[4]),
						  .cin(1'b0),
						  .cout(carry[1]),
						  .sum(carry[0])
  );
  four_bit_Full_Adder F3 ( .a({carry, tmp_p6[3:2]}),
						   .b(tmp_p4),
						   .cin(1'b0),
						   .cout(invalid),
						   .sum(p[7:4])
  );
endmodule

module Mul_2bit (a, b, p);
  input [2-1:0] a, b;
  output [4-1:0] p;
  wire w1, w2, w3, c1;
  
  and A0 (p[0], a[0], b[0]);
  
  and A1 (w1, a[1], b[0]);
  and A2 (w2, a[0], b[1]);
  one_bit_Full_Adder F1 ( .a(w1), .b(w2), .cin(1'b0), .cout(c1), .sum(p[1]) );
  
  and A3 (w3, a[1], b[1]);
  one_bit_Full_Adder F2 ( .a(w3), .b(1'b0), .cin(c1), .cout(p[3]), .sum(p[2]) );
endmodule

module one_bit_Full_Adder (a, b, cin, cout, sum);
  input a, b, cin;
  output cout, sum;
  wire w1, w2, w3, w4;
  
  and A1 (w1, a, b);
  and A2 (w2, b, cin);
  and A3 (w3, cin, a);
  or O1 (cout, w1, w2, w3);
  xor Xo1 (w4, a, b);
  xor Xo2 (sum, w4, cin);
endmodule

module four_bit_Full_Adder (a, b, cin, cout, sum);
  input [4-1:0] a, b;
  input cin;
  output [4-1:0] sum;
  output cout;

  wire [4-1:0] c;

  one_bit_Full_Adder O1 ( .a(a[0]), .b(b[0]), .cin(cin), .cout(c[1]), .sum(sum[0]) );
  one_bit_Full_Adder O2 ( .a(a[1]), .b(b[1]), .cin(c[1]), .cout(c[2]), .sum(sum[1]) );
  one_bit_Full_Adder O3 ( .a(a[2]), .b(b[2]), .cin(c[2]), .cout(c[3]), .sum(sum[2]) );
  one_bit_Full_Adder O4 ( .a(a[3]), .b(b[3]), .cin(c[3]), .cout(cout), .sum(sum[3]) );
endmodule