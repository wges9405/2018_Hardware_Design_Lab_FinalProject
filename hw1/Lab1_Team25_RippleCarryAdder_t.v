`timescale 1ns/1ps

module FullAdder;
reg [4-1:0] a = 4'b0;
reg [4-1:0] b = 4'b0;
reg cin = 1'b0;
wire [4:0] out;

RippleCarryAdder F1 (
  .a (a),
  .b (b),
  .cin (cin),
  .cout (out [4]),
  .sum (out [3:0])
);

initial begin
  repeat (2 ** 9) begin
    #1 {a, b, cin} = {a, b, cin} + 1'b1;
  end
  #1 $finish;
end

endmodule
