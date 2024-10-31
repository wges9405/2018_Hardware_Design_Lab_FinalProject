`timescale 1ns/1ps

module Multiplier_t;
reg [4-1:0] a = 4'b0;
reg [4-1:0] b = 4'b0;
wire [8-1:0] p;
integer error;

Multiplier M1 (
  .a (a),
  .b (b),
  .p (p)
);

initial begin
  error = 0;
  repeat (2 ** 8) begin
    #1
	if (p != a * b) begin
		$display ("Error occured(a=%b, b=%b, p=%b)", a, b, p);
		error = error + 1;
	end
	{a, b} = {a, b} + 1'b1;
  end
  $display("%d error(s)", error);
  #1 $finish;
end

endmodule
