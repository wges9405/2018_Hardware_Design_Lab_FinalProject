`timescale 1ns/1ps

module Binary_to_Grey (din, dout);
  input [4-1:0] din;
  output [4-1:0] dout;
  wire w1, w2, w3, w4;
  wire n1, n2, n3;
  
  and A1 (dout[3], din[3], din[3]);
  
  ex_or E1 ( .c(dout[2]), .a(din[2]), .b(din[3]) );
  
  not N1 (n1, din[1]);
  not N2 (n2, din[2]);
  and A2 (w1, n2, din[1]);
  and A3 (w2, din[2], n1);
  or O1 (dout[1], w1, w2);
  
  ex_or E2 ( .c(dout[0]), .a(din[0]), .b(din[1]) );
  
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
/*
module Binary_to_Grey (din, dout);
  input [4-1:0] din;
  output [4-1:0] dout;
  wire [16-1:0] Tout;
  
  Decoder_4_to_16 D1 ( .Din(din), .Dout(Tout) );
  OneHot_to_Grey_code O1 ( .Gin(Tout), .Gout(dout) );
    
endmodule

module OneHot_to_Grey_code (Gin, Gout);
  input [16-1:0] Gin;
  output [4-1:0] Gout;
  
  or O0 (Gout[0], Gin[1], Gin[2], Gin[5], Gin[6], Gin[9], Gin[10], Gin[13], Gin[14]);
  or O1 (Gout[1], Gin[2], Gin[3], Gin[4], Gin[5], Gin[10], Gin[11], Gin[12], Gin[13]);
  or O2 (Gout[2], Gin[4], Gin[5], Gin[6], Gin[7], Gin[8], Gin[9], Gin[10], Gin[11]);
  or O3 (Gout[3], Gin[8], Gin[9], Gin[10], Gin[11], Gin[12], Gin[13], Gin[14], Gin[15]);  
  
endmodule

module Decoder_4_to_16 (Din, Dout);
  input [4-1:0] Din;
  output [16-1:0] Dout;
  wire [4-1:0] Ndi;
  
  not N1 [4-1:0] (Ndi, Din);
  and A0 (Dout[0], Ndi[3], Ndi[2], Ndi[1], Ndi[0]);
  and A1 (Dout[1], Ndi[3], Ndi[2], Ndi[1], Din[0]);
  and A2 (Dout[2], Ndi[3], Ndi[2], Din[1], Ndi[0]);
  and A3 (Dout[3], Ndi[3], Ndi[2], Din[1], Din[0]);
  and A4 (Dout[4], Ndi[3], Din[2], Ndi[1], Ndi[0]);
  and A5 (Dout[5], Ndi[3], Din[2], Ndi[1], Din[0]);
  and A6 (Dout[6], Ndi[3], Din[2], Din[1], Ndi[0]);
  and A7 (Dout[7], Ndi[3], Din[2], Din[1], Din[0]);
  and A8 (Dout[8], Din[3], Ndi[2], Ndi[1], Ndi[0]);
  and A9 (Dout[9], Din[3], Ndi[2], Ndi[1], Din[0]);
  and A10 (Dout[10], Din[3], Ndi[2], Din[1], Ndi[0]);
  and A11 (Dout[11], Din[3], Ndi[2], Din[1], Din[0]);
  and A12 (Dout[12], Din[3], Din[2], Ndi[1], Ndi[0]);
  and A13 (Dout[13], Din[3], Din[2], Ndi[1], Din[0]);
  and A14 (Dout[14], Din[3], Din[2], Din[1], Ndi[0]);
  and A15 (Dout[15], Din[3], Din[2], Din[1], Din[0]);
  
endmodule*/