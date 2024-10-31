`timescale 1ns/1ps

module Decoder (din, dout);
  input [4-1:0] din;
  output [16-1:0] dout;

  wire [4-1:0] Ndi;

  not N0 (Ndi[0], din[0]);
  not N1 (Ndi[1], din[1]);
  not N2 (Ndi[2], din[2]);
  not N3 (Ndi[3], din[3]);

  and Out0 (dout[0], din[0], din[1], din[2], din[3]);
  and Out1 (dout[1], Ndi[0], din[1], din[2], din[3]);
  and Out2 (dout[2], din[0], Ndi[1], din[2], din[3]);
  and Out3 (dout[3], Ndi[0], Ndi[1], din[2], din[3]);
  and Out4 (dout[4], din[0], din[1], Ndi[2], din[3]);
  and Out5 (dout[5], Ndi[0], din[1], Ndi[2], din[3]);
  and Out6 (dout[6], din[0], Ndi[1], Ndi[2], din[3]);
  and Out7 (dout[7], Ndi[0], Ndi[1], Ndi[2], din[3]);
  
  and Out8 (dout[8], Ndi[0], Ndi[1], Ndi[2], Ndi[3]);
  and Out9 (dout[9], din[0], Ndi[1], Ndi[2], Ndi[3]);
  and Out10 (dout[10], Ndi[0], din[1], Ndi[2], Ndi[3]);
  and Out11 (dout[11], din[0], din[1], Ndi[2], Ndi[3]);
  and Out12 (dout[12], Ndi[0], Ndi[1], din[2], Ndi[3]);
  and Out13 (dout[13], din[0], Ndi[1], din[2], Ndi[3]);
  and Out14 (dout[14], Ndi[0], din[1], din[2], Ndi[3]);
  and Out15 (dout[15], din[0], din[1], din[2], Ndi[3]);
endmodule
