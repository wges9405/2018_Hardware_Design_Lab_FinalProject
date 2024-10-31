`timescale 1ns/1ps

module Memory_t;
  reg clk = 1'b0, ren = 1'b1, wen = 1'b1;
  reg [5:0] addr = 6'b0;
  reg [7:0] din = 8'b0;
  wire [7:0] dout;
  parameter cyc = 4;
  
  Memory M1 ( .clk(clk),
			  .ren(ren),
			  .wen(wen),
			  .din(din),
			  .addr(addr),
			  .dout(dout)
  );
  
  always #(cyc/2) clk = ~clk;
  
  initial begin
	#(cyc)
	wen = !wen;
	addr = 6'd63;
	din = 8'd4;
	#(cyc)
	addr = 6'd45;
	din = 8'd8;
	#(cyc)
	addr = 6'd8;
	din = 8'd35;
	#(cyc)
	addr = 6'd26;
	din = 8'd77;
	#(cyc)
	wen = !wen;
	addr = 6'd0;
	din = 8'd0;
	#(cyc*3)
	ren = !ren;
	addr = 6'd8;
	#(cyc)
	addr = 6'd26;
	#(cyc)
	addr = 6'd63;
	#(cyc)
	addr = 6'd45;
	#(cyc)
	ren = !ren;
	addr = 6'd0;
	#(cyc*3)
	$finish;
  end
endmodule