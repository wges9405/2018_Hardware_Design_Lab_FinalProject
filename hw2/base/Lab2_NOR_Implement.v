`timescale 1ns/1ps

module NOR_Implement (a, b, sel, out);
  input [2:0] sel;
  input a, b;
  output out;
  wire [7:0] Dout;
  wire [6:0] Gout;
  wire [6:0] Tout;
  wire w1;
  
  Decoder_3_to_8 D1 (.sel(sel), .Dout(Dout));
  
  not_nor N1 ( .A(a), .B(b), .Gout(Gout[0]) );
  nor N2 ( Gout[1], a, b );
  and_nor N3 ( .A(a), .B(b), .Gout(Gout[2]) );
  or_nor N4 ( .A(a), .B(b), .Gout(Gout[3]) );
  xor_nor N5 ( .A(a), .B(b), .Gout(Gout[4]) );
  xnor_nor N6 ( .A(a), .B(b), .Gout(Gout[5]) );
  nand_nor N7 ( .A(a), .B(b), .Gout(Gout[6]) );
  
  and_nor A1 ( .A(Dout[0]), .B(Gout[0]), .Gout(Tout[0]) );
  and_nor A2 ( .A(Dout[1]), .B(Gout[1]), .Gout(Tout[1]) );
  and_nor A3 ( .A(Dout[2]), .B(Gout[2]),  .Gout(Tout[2]) );
  and_nor A4 ( .A(Dout[3]), .B(Gout[3]), .Gout(Tout[3]) );
  and_nor A5 ( .A(Dout[4]), .B(Gout[4]), .Gout(Tout[4]) );
  and_nor A6 ( .A(Dout[5]), .B(Gout[5]), .Gout(Tout[5]) );
  or_nor O1 ( .A(Dout[6]), .B(Dout[7]), .Gout(w1) );
  and_nor A7 ( .A(w1), .B(Gout[6]), .Gout(Tout[6]) );
  
  or_nor_7 A8 (.out(out), .A(Tout[0]), .B(Tout[1]), .C(Tout[2]), .D(Tout[3]), .E(Tout[4]), .F(Tout[5]), .G(Tout[6]));
endmodule

module Decoder_3_to_8 (sel, Dout);
  input [2:0] sel;
  output [7:0] Dout;
  wire [2:0] Nsel;

  not_nor N1 ( .Gout(Nsel[0]), .A(sel[0]) , .B(sel[0]) );
  not_nor N2 ( .Gout(Nsel[1]), .A(sel[1]) , .B(sel[1]) );
  not_nor N3 ( .Gout(Nsel[2]), .A(sel[2]) , .B(sel[2]) );
  nor O1 (Dout[0], sel[2], sel[1], sel[0]);
  nor O2 (Dout[1], sel[2], sel[1], Nsel[0]);
  nor O3 (Dout[2], sel[2], Nsel[1], sel[0]);
  nor O4 (Dout[3], sel[2], Nsel[1], Nsel[0]);
  nor O5 (Dout[4], Nsel[2], sel[1], sel[0]);
  nor O6 (Dout[5], Nsel[2], sel[1], Nsel[0]);
  nor O7 (Dout[6], Nsel[2], Nsel[1], sel[0]);
  nor O8 (Dout[7], Nsel[2], Nsel[1], Nsel[0]);
endmodule

module not_nor (A, B, Gout);
  input A, B;
  output Gout;
  
  nor n1(Gout, A, A);
endmodule

module or_nor (A, B, Gout);
  input A, B;
  output Gout;
  wire w1;
  
  nor n1 (w1, A, B);
  not_nor n2 ( .Gout(Gout), .A(w1), .B(w1) );
endmodule

module and_nor (A, B, Gout);
  input A, B;
  output Gout;
  wire w1, w2;
  
  not_nor n1 ( .Gout(w1), .A(A), .B(A) );
  not_nor n2 ( .Gout(w2), .A(B), .b(B) );
  nor n3 (Gout, w1, w2);  
endmodule

module nand_nor (A, B, Gout);
  input A, B;
  output Gout;
  wire w1, w2, w3;
    
  not_nor n1 ( .Gout(w1), .A(A), .B(A) );
  nor n2 (w2, B, B);
  nor n3 (w3, w1, w2);
  nor n4 (Gout, w3, w3);  
endmodule

module xor_nor (A, B, Gout);
  input A, B;
  output Gout;
  wire w1, w2, w3, w4, w5;
  
  nor n1 (w1, A, A);
  nor n2 (w2, B, B);
  nor n3 (w3, w1, B);
  nor n4 (w4, w2, A);
  nor n5 (w5, w3, w4);
  nor n6 (Gout, w5, w5);
endmodule

module xnor_nor (A, B, Gout);
  input A, B;
  output Gout;
  wire w1, w2, w3, w4;
    
  nor n1 (w1, A, A);
  nor n2 (w2, B, B);
  nor n3 (w3, w1, B);
  nor n4 (w4, w2, A);
  nor n5 (Gout, w3, w4);
endmodule

module or_nor_7 (A, B, C, D, E, F, G, out);
  input A, B, C, D, E ,F ,G;
  output out;
  wire w1;
  
  nor (w1, A, B, C, D, E ,F ,G);
  nor (out, w1, w1);
endmodule