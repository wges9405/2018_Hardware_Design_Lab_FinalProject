`timescale 1ns/1ps

module Traffic_Light_Controller (clk, rst_n, lr_has_car, hw_light, lr_light);
	input clk, rst_n;
	input lr_has_car;
	output [3-1:0] hw_light;
	output [3-1:0] lr_light;
	
	parameter HGLR = 3'd0, HYLR = 3'd1, HRLR1 = 3'd2, HRLG = 3'd3, HRLY = 3'd4, HRLR2 = 3'd5;
	parameter RED = 3'b100, YEL = 3'b010, GRE = 3'b001; 
	
	reg [2:0] state, next_state;
	reg [4:0] count_G;
	reg [2:0] count_Y;
	reg G_to_Y, Y_to_R;
	reg [2:0] hw_light, lr_light;
	
	always @(posedge clk) begin
		if (!rst_n) begin
			state <= HGLR;
			count_G <= 5'b1;
			count_Y <= 3'b0;
		end
		else begin
			state <= next_state;
			if (next_state == HGLR || next_state == HRLG) begin
				count_G <= count_G + 1'b1;
				count_Y <= 3'b0;
			end
			else if (next_state == HYLR || next_state == HRLY) begin
				count_G <= 5'b0;
				count_Y <= count_Y + 1'b1;
			end
			else begin
				count_G <= 5'b0;
				count_Y <= 3'b0;
			end
		end
	end
	
	always @* begin
		if (state == HGLR || state == HRLG) begin
			G_to_Y = (count_G == 5'd25) ? 1'b1 : G_to_Y;
			Y_to_R = 1'b0;
		end
		else if (state == HYLR || state == HRLY) begin
			G_to_Y = 1'b0;
			Y_to_R = (count_Y == 3'd5) ? 1'b1 : Y_to_R;
		end
		else begin
			G_to_Y = 1'b0;
			Y_to_R = 1'b0;
		end
	end
	
	always @* begin
		case (state)
			HGLR:	 next_state = (G_to_Y && lr_has_car) ? HYLR : state;
			HYLR: 	 next_state = (Y_to_R) ? HRLR1 : state;
			HRLR1:	 next_state = HRLG;
			HRLG: 	 next_state = (G_to_Y) ? HRLY : state;
			HRLY: 	 next_state = (Y_to_R) ? HRLR2 : state;
			HRLR2:	 next_state = HGLR;
			default: next_state = state;
		endcase
	end
	always @* begin
		if 		(state == HGLR) {hw_light, lr_light} = {GRE, RED};
 		else if (state == HRLG) {hw_light, lr_light} = {RED, GRE};
		else if (state == HYLR) {hw_light, lr_light} = {YEL, RED};
		else if (state == HRLY) {hw_light, lr_light} = {RED, YEL};
		else if (state == HRLR1 || state == HRLR2) {hw_light, lr_light} = {RED, RED};
		else 					{hw_light, lr_light} = {hw_light, lr_light};
	end
endmodule
