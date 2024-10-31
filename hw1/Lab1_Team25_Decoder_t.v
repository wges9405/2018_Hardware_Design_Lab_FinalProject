`timescale 1ns/1ps

module Decoder4_to_16_tb;
  reg [4-1:0] din = 4'b0;
  wire [16-1:0] dout;
  integer i;
  parameter tail = (1 << 4);

  Decoder D1(
    .din (din),
    .dout (dout)
  );

  initial begin
    for (i = 0 ; i < tail ; i = i + 1) begin
	  #1 din = din + 1'b1;
	end
	#1 $finish;
  end
endmodule

