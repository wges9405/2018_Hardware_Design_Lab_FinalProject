`timescale 1ns/1ps

module Decode_and_Execute (op_code, rs, rt, rd);
  input [3-1:0] op_code;
  input [4-1:0] rs, rt;
  output [4-1:0] rd;
  wire [8-1:0] mux;
  wire [4-1:0] op0, op1, op2, op3, op4, op5, op6, op7;
  wire [4-1:0] tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;
  
  Decoder_3_to_8 D1 ( .din(op_code), .dout(mux) );
  Add add ( .a(rs), .b(rt), .c(tmp0) );
  Sub sub ( .a(rs), .b(rt), .c(tmp1) );
  Inc inc ( .a(rs), .b(rt), .c(tmp2) );
  Nor norr ( .a(rs), .b(rt), .c(tmp3) );
  Nand nandd ( .a(rs), .b(rt), .c(tmp4) );
  Div div ( .a(rs), .b(rt), .c(tmp5) );
  Mul mul1 ( .a(rs), .b(rt), .c(tmp6) );
  Mul_4bit mul2 ( .a(rs), .b(rt), .p(tmp7) );
  
  and a0_0 (op0[0], tmp0[0], mux[0]);
  and a0_1 (op0[1], tmp0[1], mux[0]);
  and a0_2 (op0[2], tmp0[2], mux[0]);
  and a0_3 (op0[3], tmp0[3], mux[0]);
  
  and a1_0 (op1[0], tmp1[0], mux[1]);
  and a1_1 (op1[1], tmp1[1], mux[1]);
  and a1_2 (op1[2], tmp1[2], mux[1]);
  and a1_3 (op1[3], tmp1[3], mux[1]);
  
  and a2_0 (op2[0], tmp2[0], mux[2]);
  and a2_1 (op2[1], tmp2[1], mux[2]);
  and a2_2 (op2[2], tmp2[2], mux[2]);
  and a2_3 (op2[3], tmp2[3], mux[2]);
  
  and a3_0 (op3[0], tmp3[0], mux[3]);
  and a3_1 (op3[1], tmp3[1], mux[3]);
  and a3_2 (op3[2], tmp3[2], mux[3]);
  and a3_3 (op3[3], tmp3[3], mux[3]);
  
  and a4_0 (op4[0], tmp4[0], mux[4]);
  and a4_1 (op4[1], tmp4[1], mux[4]);
  and a4_2 (op4[2], tmp4[2], mux[4]);
  and a4_3 (op4[3], tmp4[3], mux[4]);
  
  and a5_0 (op5[0], tmp5[0], mux[5]);
  and a5_1 (op5[1], tmp5[1], mux[5]);
  and a5_2 (op5[2], tmp5[2], mux[5]);
  and a5_3 (op5[3], tmp5[3], mux[5]);
  
  and a6_0 (op6[0], tmp6[0], mux[6]);
  and a6_1 (op6[1], tmp6[1], mux[6]);
  and a6_2 (op6[2], tmp6[2], mux[6]);
  and a6_3 (op6[3], tmp6[3], mux[6]);
  
  and a7_0 (op7[0], tmp7[0], mux[7]);
  and a7_1 (op7[1], tmp7[1], mux[7]);
  and a7_2 (op7[2], tmp7[2], mux[7]);
  and a7_3 (op7[3], tmp7[3], mux[7]);
  
  or O1[4-1:0] ( rd, op0, op1, op2, op3, op4, op5, op6, op7 );
  
  
endmodule

module Add (a, b, c);
  input [4-1:0] a, b;
  output [4-1:0] c;
  wire cout;
  
  four_bit_Full_Adder F1 ( .a(a), .b(b), .cin(1'b0), .cout(cout), .sum(c) );
endmodule

module Sub (a, b, c);
  input [4-1:0] a, b;
  output [4-1:0] c;
  wire [4-1:0] Nb, tcb;
  wire cout1, cout2;
  
  not N1[4-1:0] (Nb, b);
  four_bit_Full_Adder F1 ( .a(Nb), .b(1'b0), .cin(1'b1), .cout(cout1), .sum(tcb) );
  four_bit_Full_Adder F2 ( .a(a), .b(tcb), .cin(1'b0), .cout(cout2), .sum(c) );
endmodule

module Inc (a, b, c);
  input [4-1:0] a, b;
  output [4-1:0] c;
  wire cout;
  
  four_bit_Full_Adder F1 ( .a(a), .b(1'b0), .cin(1'b1), .cout(cout), .sum(c));
endmodule

module Nor (a, b, c);
  input [4-1:0] a, b;
  output [4-1:0] c;
  
  nor N1[4-1:0] (c, a, b);
endmodule

module Nand (a, b, c);
  input [4-1:0] a, b;
  output [4-1:0] c;
  
  nand N1[4-1:0] (c, a, b);
endmodule

module Div (a, b, c);
  input [4-1:0] a, b;
  output [4-1:0] c;
  
  and A1 (c[0], a[2], a[2]);
  and A2 (c[1], a[3], a[3]);
  not N1 (c[2], 1'b1);
  not N2 (c[3], 1'b1);
endmodule

module Mul (a, b, c);
  input [4-1:0] a, b;
  output [4-1:0] c;
  wire [4-1:0] na;
 
  not N1 (c[0], 1'b1);
  and A1 (c[1], a[0], a[0]);
  and A2 (c[2], a[1], a[1]);
  and A3 (c[3], a[2], a[2]);
endmodule

module Mul_4bit (a, b, p);
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


module Decoder_3_to_8 (din, dout);
  input [3-1:0] din;
  output [8-1:0] dout;
  wire [3-1:0] Ndi;
  
  not N1[3-1:0] (Ndi, din);
  and A0 (dout[0], Ndi[2], Ndi[1], Ndi[0]);
  and A1 (dout[1], Ndi[2], Ndi[1], din[0]);
  and A2 (dout[2], Ndi[2], din[1], Ndi[0]);
  and A3 (dout[3], Ndi[2], din[1], din[0]);
  and A4 (dout[4], din[2], Ndi[1], Ndi[0]);
  and A5 (dout[5], din[2], Ndi[1], din[0]);
  and A6 (dout[6], din[2], din[1], Ndi[0]);
  and A7 (dout[7], din[2], din[1], din[0]);
endmodule

module one_bit_Full_Adder (a, b, cin, cout, sum);
  input a, b, cin;
  output cout, sum;
  wire w1, w2, w3;
  
  and A1 (w1, a, b);
  and A2 (w2, b, cin);
  and A3 (w3, cin, a);
  or O1 (cout, w1, w2, w3);
  xor Xo1 (sum, a, b, cin);
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