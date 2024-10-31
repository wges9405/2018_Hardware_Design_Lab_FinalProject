`timescale 1ns/1ps

module Binary_to_Grey_t;
  reg [4-1:0] din = 4'b0;
  wire [4-1:0] dout;
  integer i;
  parameter tail = (1 << 4);

  Binary_to_Grey B1(
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

