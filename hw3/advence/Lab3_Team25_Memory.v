`timescale 1ns/1ps

module Memory (clk, ren, wen, addr, din, dout);
  input clk;
  input ren, wen;
  input [6-1:0] addr;
  input [8-1:0] din;
  output reg [8-1:0] dout;
  reg [8-1:0] mem [0:64-1];
  
  always @(posedge clk)begin
	if(ren == 0)begin //read
		if(mem[addr] === 8'bx)begin
			dout = 8'b0;
		end
		else begin
			dout = mem[addr];
		end
	end
	else if(wen == 0 && ren == 1)begin //write
		mem[addr] = din;
		dout = 8'b0;
	end
	else begin
		dout = 8'b0;
	end
  end
  
endmodule
