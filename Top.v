`timescale 1ns/1ps

module Top (
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire clk,
	input wire rst,
	input wire switch,
	output pmod_1,
	output pmod_2,
	output pmod_4,
	output [3:0] AN,
	output [7:0] segment,
	output [3:0] signal //for 4 servomotors
	);
	
	wire rst_db, rst_op;
	Debounce DB_rst (clk, rst, rst_db);
	Onepulse OP_rst (clk, rst_db, rst_op);
	
	Music_Box MB (
		.clk(clk),
		.reset(rst_op),
		.pmod_1(pmod_1),
		.pmod_2(pmod_2),
		.pmod_4(pmod_4)
	);
	
  	parameter [8:0] KEY_CODES [0:9] = {
		9'b0_0111_0101, // up => 75
		9'b0_0111_0010, // down => 72
		9'b0_0110_1011, // left => 6B
		9'b0_0111_0100, // right => 74
		9'b0_0001_1011, // S => 1B
		9'b0_0001_1101, // W => 1D
		9'b0_0001_1100, // A => 1C
		9'b0_0010_0011, // D => 23
		9'b0_0101_1010,	// Enter => 5A
		9'b0_0010_1001	// Spacebar => 29
	};
	
	wire [511:0] key_down;
	wire [8:0] last_change;
	wire key_valid;
	
	KeyboardDecoder KD (
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(key_valid),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst_op),
		.clk(clk)
    );
	
	wire [7:0] key;
	assign key[0] = key_down[KEY_CODES[0]];
	assign key[1] = key_down[KEY_CODES[1]];
	assign key[2] = key_down[KEY_CODES[2]];
	assign key[3] = key_down[KEY_CODES[3]];
	assign key[4] = key_down[KEY_CODES[4]];
	assign key[5] = key_down[KEY_CODES[5]];
	assign key[6] = key_down[KEY_CODES[6]];
	assign key[7] = key_down[KEY_CODES[7]];
	
	wire start_db, start_op;
	Debounce DB_start (clk, key_down[KEY_CODES[8]], start_db);
	Onepulse OP_start (clk, start_db, start_op);
	
	wire catch_db, catch_op;
	Debounce DB_catch (clk, key_down[KEY_CODES[9]], catch_db);
	Onepulse OP_catch (clk, catch_db, catch_op);
	
	wire [1:0] direction_x, direction_y, direction_z, direction_claw;
	wire [5:0] timer;
	
	Claw_Machine CM (
		.clk(clk),
		.rst(rst_op),
		.switch(switch),
		.start_button(start_op),
		.catch_button(catch_op),
		.key(key),
		.timer(timer),
		.out_x(direction_x),
		.out_y(direction_y),
		.out_z(direction_z),
		.out_claw(direction_claw)
	);
	
	AN_Replace ANR (clk, rst_op, AN);
	Segment_Display SD (AN, timer, segment);
	
	Servo_Motor_PWM_Gen S1 (clk, rst, direction_x, signal[0]);
	Servo_Motor_PWM_Gen S2 (clk, rst, direction_y, signal[1]);
	Servo_Motor_PWM_Gen S3 (clk, rst, direction_z, signal[2]);
	Servo_Motor_PWM_Gen S4 (clk, rst, direction_claw, signal[3]);
endmodule

module Claw_Machine (
	input clk,
	input rst,
	input switch,
	input start_button,
	input catch_button,
	input [7:0] key,
	output reg [5:0] timer,
	output reg [1:0] out_x, out_y, out_z, out_claw
	);
	
	reg [29:0] position_x, position_y, position_z, position_claw;
	reg [29:0] next_position_x, next_position_y, next_position_z, next_position_claw;
	reg [5:0] next_timer;
	reg [29:0] count, next_count;
	reg [2:0] state, next_state;
	parameter IDLE = 3'd0, MOVE = 3'd1, CATCH = 3'd2, BACK = 3'd3, HACK = 3'd4;
	parameter TIME_LIMIT = 6'd30, MAX_X = 30'd5_0000_0000, MAX_Y = 30'd5_0000_0000, MAX_Z = 30'd4_0000_0000, MAX_CLAW = 30'd3000_0000;
	
	/* DFF */
	always @ (posedge clk) begin
		if(rst) begin
			state <= IDLE;
			timer <= 6'd0;
			count <= 30'd0;
			position_x <= 30'd0;
			position_y <= 30'd0;
			position_z <= 30'd0;
			position_claw <= 30'd0;
		end
		else begin
			state <= next_state;
			timer <= next_timer;
			count <= next_count;
			position_x <= next_position_x;
			position_y <= next_position_y;
			position_z <= next_position_z;
			position_claw <= next_position_claw;
		end
	end
	
	/* state */
	always @ (*) begin
		case(state)
			IDLE: begin
				next_count = count;
				if(start_button == 1'b1) begin
					next_state = (switch == 1'b1) ? HACK : MOVE;
					next_timer = (switch == 1'b1) ? timer : TIME_LIMIT;
				end
				else begin
					next_state = state;
					next_timer = timer;
				end
			end
			MOVE: begin
				next_state = (timer == 6'd0 || catch_button == 1'b1) ? CATCH : state;
				next_timer = (count == 30'd100000000) ? timer - 1'b1 : timer;
				next_count = (count == 30'd100000000 || timer == 6'd0 || catch_button == 1'b1) ? 30'd0 : count + 1'b1;
			end
			CATCH: begin
				next_state = (count == 30'd600000000) ? BACK : state; //6 secs
				next_timer = timer;
				next_count = (count == 30'd600000000) ? 30'd0 : count + 1'b1;
			end
			BACK: begin
				next_state = (count == MAX_CLAW + MAX_CLAW) ? IDLE : state;
				next_timer = timer;
				if(position_x == 0 && position_y == 0 && position_z == 0) begin
					next_count = (count == MAX_CLAW + MAX_CLAW) ? 30'd0 : count + 1'b1;
				end
				else next_count = count;
			end
			HACK: begin
				next_state = (catch_button == 1'b1) ? IDLE : state;
				next_timer = timer;
				next_count = count;
			end
			default: begin
				next_state = state;
				next_timer = timer;
				next_count = count;
			end
		endcase
	end
	
	/* x-axis */
	//正轉->遠離洞口，反轉->靠近洞口
	always @ (*) begin
		case(state)
			IDLE: begin
				next_position_x = position_x;
				out_x = 2'b00;
			end
			MOVE: begin
				if(key[1:0] == 2'b01) begin
					next_position_x = (position_x == MAX_X) ? position_x : position_x + 1'b1;
					out_x = (position_x == MAX_X) ? 2'b00 : key[1:0];
				end
				else if(key[1:0] == 2'b10) begin
					next_position_x = (position_x == 30'd0) ? position_x : position_x - 1'b1;
					out_x = (position_x == 30'd0) ? 2'b00 : key[1:0];
				end
				else begin 
					next_position_x = position_x;
					out_x = 2'b00;
				end
			end
			CATCH: begin
				next_position_x = position_x;
				out_x = 2'b00;
			end
			BACK: begin
				next_position_x = (position_x == 30'd0) ? position_x : position_x - 1'b1;
				out_x = (position_x == 30'd0) ? 2'b00 : 2'b10;
			end
			HACK: begin
				next_position_x = position_x;
				out_x = key[1:0];
			end
			default: begin
				next_position_x = position_x;
				out_x = 2'b00;
			end
		endcase
	end
	
	/* y-axis */
	//反轉->遠離洞口，正轉->靠近洞口
	//馬達裝反了，所以out_y有做反向處理
	always @ (*) begin
		case(state)
			IDLE: begin
				next_position_y = position_y;
				out_y = 2'b00;
			end
			MOVE: begin
				if(key[3:2] == 2'b01) begin
					next_position_y = (position_y == MAX_Y) ? position_y : position_y + 1'b1;
					out_y = (position_y == MAX_Y) ? 2'b00 : 2'b10;
				end
				else if(key[3:2] == 2'b10) begin
					next_position_y = (position_y == 30'd0) ? position_y : position_y - 1'b1;
					out_y = (position_y == 30'd0) ? 2'b00 : 2'b01;
				end
				else begin 
					next_position_y = position_y;
					out_y = 2'b00;
				end
			end
			CATCH: begin
				next_position_y = position_y;
				out_y = 2'b00;
			end
			BACK: begin
				next_position_y = (position_y == 30'd0) ? position_y : position_y - 1'b1;
				out_y = (position_y == 30'd0) ? 2'b00 : 2'b01;
			end
			HACK: begin
				next_position_y = position_y;
				out_y[0] = key[3];
				out_y[1] = key[2];
			end
			default: begin
				next_position_y = position_y;
				out_y = 2'b00;
			end
		endcase
	end
	
	/* z-axis */
	//正轉->向下，反轉->向上
	always @ (*) begin
		case(state)
			IDLE: begin
				next_position_z = position_z;
				out_z = 2'b00;
			end
			MOVE: begin
				next_position_z = position_z;
				out_z = 2'b00;
			end
			CATCH: begin
				next_position_z = MAX_Z;
				if(count >= MAX_CLAW && count < MAX_CLAW + MAX_Z) out_z = 2'b01;
				else out_z = 2'b00;
			end
			BACK: begin
				next_position_z = (position_z == 30'd0) ? position_z : position_z - 1'b1;
				out_z = (position_z == 30'd0) ? 2'b00 : 2'b10;
			end
			HACK: begin
				next_position_z = position_z;
				out_z = key[5:4];
			end
			default: begin
				next_position_z = position_z;
				out_z = 2'b00;
			end
		endcase
	end
	
	/* claw */
	//正轉->張開，反轉->夾緊
	always @ (*) begin
		case(state)
			IDLE: begin
				next_position_claw = position_claw;
				out_claw = 2'b00;
			end
			MOVE: begin
				next_position_claw = position_claw;
				out_claw = 2'b00;
			end
			CATCH: begin
				next_position_claw = position_claw;
				if(count < MAX_CLAW) out_claw = 2'b01;
				else if(count >= MAX_CLAW + MAX_Z && count < MAX_CLAW + MAX_Z + MAX_CLAW) out_claw = 2'b10;
				else out_claw = 2'b00;
			end
			BACK: begin
				next_position_claw = position_claw;
				if(count > 30'd0 && count < MAX_CLAW) out_claw = 2'b01;
				else if(count >= MAX_CLAW && count < MAX_CLAW + MAX_CLAW) out_claw = 2'b10;
				else out_claw = 2'b00;
			end
			HACK: begin
				next_position_claw = position_claw;
				out_claw = key[7:6];
			end
			default: begin
				next_position_claw = position_claw;
				out_claw = 2'b00;
			end
		endcase
	end
endmodule

module Servo_Motor_PWM_Gen (clk, rst, dir, signal);
	input clk, rst;
	input [1:0] dir;
	output reg signal;
	reg [29:0] count;
	parameter POS = 30'd10_0000, NEG = 30'd20_0000, STOP = 30'd15_0000, WAVELENGTH = 30'd200_0000;
	reg [29:0] dir_count;
	
	always @ (posedge clk) begin
		if(rst) begin
			count <= 30'd0;
			signal <= 1'b0;
		end
		else begin
			count <= (count < WAVELENGTH) ? count + 1'b1 : 30'd0;
			signal <= (count < dir_count) ? 1'b1 : 1'b0;
		end
	end
	
	always @ (*) begin
		case(dir)
			2'b01: begin
				dir_count = POS;
			end
			2'b10: begin
				dir_count = NEG;
			end
			default: begin
				dir_count = STOP;
			end
		endcase
	end
endmodule

module Debounce (clk, pb, pb_debounced);
	input clk, pb;
	output pb_debounced;
	reg [3:0] DFF;
	
	assign pb_debounced = (DFF == 4'b1111) ? 1'b1 : 1'b0;
	
	always @(posedge clk) begin
		DFF[3:1] <= DFF[2:0];
		DFF[0] <= pb;
	end
endmodule

module Onepulse (clk, signal, signal_op);
	input clk, signal;
	output reg signal_op;
	reg signal_delay;
	
	always @(posedge clk) begin
		signal_delay <= signal;
		
		if(signal_delay == 1'b0 && signal == 1'b1)
			signal_op <= 1'b1;
		else
			signal_op <= 1'b0;
	end
endmodule

module AN_Replace (clk, rst, AN);
	input clk, rst;
	output reg [3:0] AN;
	reg [29:0] count;
	
	always @ (posedge clk) begin
		if(rst) begin
			count <= 30'd0;
			AN <= 4'b1110;
		end
		else begin
			if(count[16] == 1) begin
				count <= 30'd0;
				AN[3:1] <= AN[2:0];
				AN[0] <= AN[3];
			end
			else begin
				count <= count + 1'b1;
				AN <= AN;
			end
		end
	end
endmodule

module Segment_Display (AN, timer, segment);
	input [3:0] AN;
	input [5:0] timer;
	output reg [7:0] segment;
	
	always @ (*) begin
		case(AN)
			4'b0111: segment = 8'b11111111;
			4'b1011: segment = 8'b11111111;
			4'b1101: begin
				case(timer)
					6'd0:		segment = 8'b11000000;
					6'd1:		segment = 8'b11000000;
					6'd2:		segment = 8'b11000000;
					6'd3:		segment = 8'b11000000;
					6'd4:		segment = 8'b11000000;
					6'd5:		segment = 8'b11000000;
					6'd6:		segment = 8'b11000000;
					6'd7:		segment = 8'b11000000;
					6'd8:		segment = 8'b11000000;
					6'd9:		segment = 8'b11000000;
					6'd10:		segment = 8'b11111001;
					6'd11:		segment = 8'b11111001;
					6'd12:		segment = 8'b11111001;
					6'd13:		segment = 8'b11111001;
					6'd14:		segment = 8'b11111001;
					6'd15:		segment = 8'b11111001;
					6'd16:		segment = 8'b11111001;
					6'd17:		segment = 8'b11111001;
					6'd18:		segment = 8'b11111001;
					6'd19:		segment = 8'b11111001;
					6'd20:		segment = 8'b10100100;
					6'd21:		segment = 8'b10100100;
					6'd22:		segment = 8'b10100100;
					6'd23:		segment = 8'b10100100;
					6'd24:		segment = 8'b10100100;
					6'd25:		segment = 8'b10100100;
					6'd26:		segment = 8'b10100100;
					6'd27:		segment = 8'b10100100;
					6'd28:		segment = 8'b10100100;
					6'd29:		segment = 8'b10100100;
					6'd30:		segment = 8'b10110000;
					default:	segment = 8'b11111111;
				endcase
			end
			4'b1110: begin
				case(timer)
					6'd0:		segment = 8'b11000000;
					6'd1:		segment = 8'b11111001;
					6'd2:		segment = 8'b10100100;
					6'd3:		segment = 8'b10110000;
					6'd4:		segment = 8'b10011001;
					6'd5:		segment = 8'b10010010;
					6'd6:		segment = 8'b10000010;
					6'd7:		segment = 8'b11111000;
					6'd8:		segment = 8'b10000000;
					6'd9:		segment = 8'b10010000;
					6'd10:		segment = 8'b11000000;
					6'd11:		segment = 8'b11111001;
					6'd12:		segment = 8'b10100100;
					6'd13:		segment = 8'b10110000;
					6'd14:		segment = 8'b10011001;
					6'd15:		segment = 8'b10010010;
					6'd16:		segment = 8'b10000010;
					6'd17:		segment = 8'b11111000;
					6'd18:		segment = 8'b10000000;
					6'd19:		segment = 8'b10010000;
					6'd20:		segment = 8'b11000000;
					6'd21:		segment = 8'b11111001;
					6'd22:		segment = 8'b10100100;
					6'd23:		segment = 8'b10110000;
					6'd24:		segment = 8'b10011001;
					6'd25:		segment = 8'b10010010;
					6'd26:		segment = 8'b10000010;
					6'd27:		segment = 8'b11111000;
					6'd28:		segment = 8'b10000000;
					6'd29:		segment = 8'b10010000;
					6'd30:		segment = 8'b11000000;
					default:	segment = 8'b11111111;
				endcase
			end
			default: segment = 8'b11111111;
		endcase
	end
endmodule

module KeyboardDecoder(
	output reg [511:0] key_down,
	output wire [8:0] last_change,
	output reg key_valid,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire rst,
	input wire clk
    );
    
    parameter [1:0] INIT			= 2'b00;
    parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
    parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
    parameter [1:0] WAIT_RELEASE    = 2'b11;
    
	parameter [7:0] IS_INIT			= 8'hAA;
    parameter [7:0] IS_EXTEND		= 8'hE0;
    parameter [7:0] IS_BREAK		= 8'hF0;
    
    reg [9:0] key;		// key = {been_extend, been_break, key_in}
    reg [1:0] state;
    reg been_ready, been_extend, been_break;
    
    wire [7:0] key_in;
    wire is_extend;
    wire is_break;
    wire valid;
    wire err;
    
    wire [511:0] key_decode = 1 << last_change;
    assign last_change = {key[9], key[7:0]};
    
    KeyboardCtrl_0 inst (
		.key_in(key_in),
		.is_extend(is_extend),
		.is_break(is_break),
		.valid(valid),
		.err(err),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
	
	Onepulse op (
		.signal_op(pulse_been_ready),
		.signal(been_ready),
		.clk(clk)
	);
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		state <= INIT;
    		been_ready  <= 1'b0;
    		been_extend <= 1'b0;
    		been_break  <= 1'b0;
    		key <= 10'b0_0_0000_0000;
    	end else begin
    		state <= state;
			been_ready  <= been_ready;
			been_extend <= (is_extend) ? 1'b1 : been_extend;
			been_break  <= (is_break ) ? 1'b1 : been_break;
			key <= key;
    		case (state)
    			INIT : begin
    					if (key_in == IS_INIT) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready  <= 1'b0;
							been_extend <= 1'b0;
							been_break  <= 1'b0;
							key <= 10'b0_0_0000_0000;
    					end else begin
    						state <= INIT;
    					end
    				end
    			WAIT_FOR_SIGNAL : begin
    					if (valid == 0) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready <= 1'b0;
    					end else begin
    						state <= GET_SIGNAL_DOWN;
    					end
    				end
    			GET_SIGNAL_DOWN : begin
						state <= WAIT_RELEASE;
						key <= {been_extend, been_break, key_in};
						been_ready  <= 1'b1;
    				end
    			WAIT_RELEASE : begin
    					if (valid == 1) begin
    						state <= WAIT_RELEASE;
    					end else begin
    						state <= WAIT_FOR_SIGNAL;
    						been_extend <= 1'b0;
    						been_break  <= 1'b0;
    					end
    				end
    			default : begin
    					state <= INIT;
						been_ready  <= 1'b0;
						been_extend <= 1'b0;
						been_break  <= 1'b0;
						key <= 10'b0_0_0000_0000;
    				end
    		endcase
    	end
    end
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		key_valid <= 1'b0;
    		key_down <= 511'b0;
    	end else if (key_decode[last_change] && pulse_been_ready) begin
    		key_valid <= 1'b1;
    		if (key[8] == 0) begin
    			key_down <= key_down | key_decode;
    		end else begin
    			key_down <= key_down & (~key_decode);
    		end
    	end else begin
    		key_valid <= 1'b0;
			key_down <= key_down;
    	end
    end

endmodule