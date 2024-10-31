`timescale 1ns/1ps

module CLA;
reg [4-1:0] a = 4'b0;
reg [4-1:0] b = 4'b0;
reg cin = 1'b0;
wire [4:0] out;
integer error;

Carry_Look_Ahead_Adder F1 (
  .a (a),
  .b (b),
  .cin (cin),
  .cout (out [4]),
  .sum (out [3:0])
);

initial begin
  error = 0;
  repeat (2 ** 9) begin
    #1
	if (out[4:0] != a + b + cin) begin
		$display ("Error occured(a=%b, b=%b, cin=%b, out=%b)", a, b, cin, out);
		error = error + 1;
	end
    {a, b, cin} = {a, b, cin} + 1'b1;
  end
  $display("%d error(s)", error);
  #1 $finish;
end

endmodule
