`timescale 1ns/1ps

`define CYC 4

module Traffic_Light_Controller_t;
	reg clk = 1'b1;
	reg rst_n = 1'b1;
	reg lr_has_car = 1'b0;
	wire [2:0] hw_light, lr_light;
	
	Traffic_Light_Controller TLC(
		.clk(clk),
		.rst_n(rst_n),
		.lr_has_car(lr_has_car),
		.hw_light(hw_light),
		.lr_light(lr_light)
	);
	
	always #(`CYC/2) clk = ~clk;
	
	initial begin
		#(`CYC/2) rst_n = ~rst_n;
		#(`CYC) rst_n = ~rst_n;
		#(`CYC*20) lr_has_car = ~lr_has_car;
		#(`CYC*50) lr_has_car = ~lr_has_car;
		#(`CYC*50) $finish;
	end
endmodule