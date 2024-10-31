`timescale 1ns/1ps

module Clock_Divider (clk, rst_n, sel, clk1_2, clk1_3, clk1_4, clk1_8, dclk);
  input clk, rst_n;
  input [2-1:0] sel;
  output clk1_2, clk1_3, clk1_4, clk1_8, dclk;

  Divider_by_2 D2 ( .clk(clk), .rst_n(rst_n), .clk1_2(clk1_2) );
  Divider_by_2 D4 ( .clk(clk1_2), .rst_n(rst_n), .clk1_2(clk1_4) );
  Divider_by_2 D8 ( .clk(clk1_4), .rst_n(rst_n), .clk1_2(clk1_8) );
  Divider_by_3 D3 ( .clk(clk), .rst_n(rst_n), .clk1_3(clk1_3) );
  
  Mux_4_to_1 M1 ( .in({clk1_3, clk1_8, clk1_4, clk1_2}), .sel(sel) , .out(dclk));
endmodule

module Mux_4_to_1 (in, sel, out);
  input [4-1:0] in;
  input [2-1:0] sel;
  output out;
  
  assign out = in[sel];
endmodule

module Divider_by_2 (clk, rst_n, clk1_2);
  input clk, rst_n;
  output clk1_2;
  reg next_clk, cur_clk;
  
  assign clk1_2 = cur_clk;
  
  always @ (posedge clk, negedge rst_n)
    begin
	  if (rst_n==0 && clk)
		  cur_clk <= 1;
	  else
	      cur_clk <= next_clk;
	end
  
  always @ (clk)
    begin
	  next_clk = !cur_clk;
	end
endmodule


module Divider_by_3 (clk, rst_n, clk1_3);
  input clk, rst_n;
  output clk1_3;
  reg next_clk, cur_clk;
  reg [2-1:0] next_counter, cur_counter;
  
  assign clk1_3 = cur_clk;
  
  always @ (posedge clk,  negedge rst_n)
    begin
	  if (!rst_n && clk)
	    begin
		  cur_clk <= 1'b0;
		  cur_counter <= 2'b00;
		end
	  else
	    begin
		  cur_clk <= next_clk;
		  if (next_counter == 2'b10)
			cur_counter <= 2'b00;
		  else
			cur_counter <= next_counter+1'b1;
		end
	end
	
  always @ (*)
    begin
	  next_counter = cur_counter;
	  if (next_counter == 2'b01)
		  next_clk = cur_clk;
	  else
		  next_clk = !cur_clk;
	end
endmodule