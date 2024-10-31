`timescale 1ns/1ps

module Comparator_t;
reg [3-1:0] a = 3'b0;
reg [3-1:0] b = 3'b0;
wire a_lt_b, a_gt_b, a_eq_b;

Comparator_3bits C1 (
  .a (a),
  .b (b),
  .a_lt_b (a_lt_b),
  .a_gt_b (a_gt_b),
  .a_eq_b (a_eq_b)
);

initial begin
  repeat (2 ** 6) begin
    #1 {a, b} = {a, b} + 1'b1;
  end
  #1 $finish;
end

endmodule
