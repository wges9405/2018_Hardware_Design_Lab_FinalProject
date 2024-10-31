`timescale 1ns / 1ps

module pmod_step_interface(clk, rst, direction_x, direction_y, en_x, en_y, signal_out_x, signal_out_y);
    input clk, rst, direction_x, direction_y, en_x, en_y;
    output [3:0] signal_out_x, signal_out_y;
    wire dclk;
    
    clock_div t (.clk(clk), .rst(rst), .dclk(dclk));     
    
    pmod_step_driver control_x ( .rst(rst), .dir(direction_x), .clk(dclk), .en(en_x), .signal(signal_out_x));   
    pmod_step_driver control_y ( .rst(rst), .dir(direction_y), .clk(dclk), .en(en_y), .signal(signal_out_y));
endmodule

module fpga_connect(CLK100MHZ, RESET, sw, btC, JA, JB, JC, led);
	input RESET, btC, CLK100MHZ;
	input [2:0] sw;
	output [5:0] led; // led[0] finish    led[1] start    led[2] x    led[3] y    led[4] dot   led[5] RESET
	output[3:0] JB, JC;
	output JA;
	
	wire dir_x, dir_y, en_x, en_y, dot;
    
	// center controller
	process p(.rst(RESET), .CLK100MHZ(CLK100MHZ), .start(btC), .picture(wanted), .finish(led[0]), .dir_x(dir_x), .dir_y(dir_y), .en_x(en_x), .en_y(en_y), .dot(dot) );
	
	// motor controller
	pmod_step_interface s(.clk(CLK100MHZ), .rst(RESET), .direction_x(dir_x), .direction_y(dir_y), .en_x(en_x), .en_y(en_y), .signal_out_x(JB), .signal_out_y(JC) );
	
	// electromagnet control
	assign JA = ~dot;
	
	// led controller
	assign led[5:1] = {RESET, dot, en_y, en_x, btC};
	
endmodule 