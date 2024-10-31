`timescale 1ns/1ps

module Mux_8bits_tb;
reg [8-1:0] a = 8'b0;
reg [8-1:0] b = 8'b0;
reg sel = 1'b0;
wire [8-1:0] f;

Mux_8bits mux(
  .a (a),
  .b (b),
  .sel (sel),
  .f (f)
);

initial  begin
  repeat (2 ** 17) begin
    #1 {a, b, sel} = {a, b, sel} + 1'b1;
  end
  #1 $finish;
end

endmodule
