module Basic2(
	//output wire [6:0] display,
	//output wire [3:0] digit,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire rst,
	input wire clk,
	output pmod_1,
	output pmod_2,
	output pmod_4
	);
	
	parameter [8:0] LEFT_SHIFT_CODES  = 9'b0_0001_0010;
	parameter [8:0] RIGHT_SHIFT_CODES = 9'b0_0101_1001;
	parameter [8:0] KEY_CODES [0:3] = {
		9'b0_0111_0000, // right_0 => 70
		9'b0_0110_1001, // right_1 => 69
		9'b0_0111_0010, // right_2 => 72
		9'b0_0101_1010	// enter => 5A
	};

	wire [511:0] key_down;
	wire [8:0] last_change;
	wire been_ready;
	wire key_0, key_1, key_2, key_e, rst_for_music_onepulse;;
	reg rst_for_music;
	reg speed, next_speed;
	reg director, next_director;
	
	KeyboardDecoder key_de (
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(been_ready),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
	
	TOP Music(
		.clk(clk),
		.reset(rst_for_music_onepulse),
		.speed(speed),
		.director(director),
		.pmod_1(pmod_1),
		.pmod_2(pmod_2),
		.pmod_4(pmod_4)
	);
	
	OnePulse op_reset (
		.signal_single_pulse(rst_for_music_onepulse),
		.signal(rst_for_music),
		.clock(clk)
	);
	
	OnePulse op_k0 (
		.signal_single_pulse(key_0),
		.signal(key_down[KEY_CODES[0]]),
		.clock(clk)
	);
	
	OnePulse op_k1 (
		.signal_single_pulse(key_1),
		.signal(key_down[KEY_CODES[1]]),
		.clock(clk)
	);
	
	OnePulse op_k2 (
		.signal_single_pulse(key_2),
		.signal(key_down[KEY_CODES[2]]),
		.clock(clk)
	);
	
	OnePulse op_ke (
		.signal_single_pulse(key_e),
		.signal(key_down[KEY_CODES[3]]),
		.clock(clk)
	);
	
	always @(posedge clk) begin
		if (rst) begin
			speed <= 1'b0;
			director <= 1'b0;
		end
		else begin
			speed <= next_speed;
			director <= next_director;
		end
	end
	
	always @* begin
		if (key_0 == 1'b1) begin
			rst_for_music = 1'b0;
			next_speed = speed;
			next_director = 1'b0;
		end
		else if (key_1 == 1'b1) begin
			rst_for_music = 1'b0;
			next_speed = speed;
			next_director = 1'b1;
		end
		else if (key_2 == 1'b1) begin
			rst_for_music = 1'b0;
			next_speed = speed + 1'b1;
			next_director = director;
		end
		else if (key_e == 1'b1) begin
			rst_for_music = 1'b1;
			next_speed = 1'b0;
			next_director = 1'b0;
		end
		else begin
			rst_for_music = 1'b0;
			next_speed = speed;
			next_director = director;
		end
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
	
	OnePulse op (
		.signal_single_pulse(pulse_been_ready),
		.signal(been_ready),
		.clock(clk)
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


module OnePulse (
	output reg signal_single_pulse,
	input wire signal,
	input wire clock
	);
	
	reg signal_delay;

	always @(posedge clock) begin
		if (signal == 1'b1 & signal_delay == 1'b0)
		  signal_single_pulse <= 1'b1;
		else
		  signal_single_pulse <= 1'b0;

		signal_delay <= signal;
	end
endmodule

module TOP (
		input clk,
		input reset,
		input speed,
		input director,
		output pmod_1,
		output pmod_2,
		output pmod_4
	);
	
	parameter DUTY_BEST = 10'd512;	//duty cycle=50%
	
	wire [31:0] freq;
	wire [3:0] ibeatNum;
	wire [31:0]beatFreq;
	
	assign pmod_2 = 1'd1;	//no gain(6dB)
	assign pmod_4 = 1'd1;	//turn-on
	assign BEAT_FREQ = (reset) ? 32'd1 : ((speed == 1'b1) ? 32'd2 : 32'd1);
	
	//Generate beat speed
	PWM_gen btSpeedGen ( .clk(clk), 
						 .reset(reset),
						 .freq(BEAT_FREQ),
						 .duty(DUTY_BEST), 
						 .PWM(beatFreq)
	);
		
	//manipulate beat
	PlayerCtrl playerCtrl_00 ( .clk(beatFreq),
							   .reset(reset),
							   .director(director),
							   .ibeat(ibeatNum)
	);	
		
	//Generate variant freq. of tones
	Music music00 ( .ibeatNum(ibeatNum),
					.tone(freq)
	);
	
	// Generate particular freq. signal
	PWM_gen toneGen ( .clk(clk), 
					  .reset(reset), 
					  .freq(freq),
					  .duty(DUTY_BEST), 
					  .PWM(pmod_1)
	);
endmodule

module PWM_gen (
		input wire clk,
		input wire reset,
		input [31:0] freq,
		input [9:0] duty,
		output reg PWM
	);

	wire [31:0] count_max = 100_000_000 / freq;
	wire [31:0] count_duty = count_max * duty / 1024;
	reg [31:0] count;
		
	always @(posedge clk, posedge reset) begin
		if (reset) 	begin
			count <= 0;
			PWM <= 1;
		end else if (count < count_max) begin
			count <= count + 1;
			if(count < count_duty)
				PWM <= 1;
			else
				PWM <= 0;
		end else begin
			count <= 0;
			PWM <= 0;
		end
	end
endmodule

module PlayerCtrl (
		input clk,
		input reset,
		input director,
		output reg [3:0] ibeat
	);
	parameter BEATLEAGTH = 14;

	always @(posedge clk, posedge reset) begin
		if (reset)
			ibeat <= 0;
		else begin
			if (director == 1'b0) begin
				if (ibeat < BEATLEAGTH) ibeat <= ibeat + 1;
				else ibeat <= ibeat;
			end
			else begin
				if (ibeat > 0) ibeat <= ibeat - 1;
				else ibeat <= ibeat;
			end
		end
	end
endmodule

module Music (
		input [3:0] ibeatNum,
		output reg [31:0] tone
	);
	
	parameter NM0 = 32'd20000;
	parameter NM1 = 32'd262;
	parameter NM2 = 32'd294;
	parameter NM3 = 32'd330;
	parameter NM4 = 32'd349;
	parameter NM5 = 32'd392;
	parameter NM6 = 32'd440;
	parameter NM7 = 32'd494;
	
	always @(*) begin
		case (ibeatNum)		// 1/4 beat
			4'd0 : tone = NM1;
			4'd1 : tone = NM2;
			4'd2 : tone = NM3;
			4'd3 : tone = NM4;
			4'd4 : tone = NM5;
			4'd5 : tone = NM6;
			4'd6 : tone = NM7;
			4'd7 : tone = NM1 << 1;
			4'd8 : tone = NM2 << 1;
			4'd9 : tone = NM3 << 1;
			4'd10 : tone = NM4 << 1;
			4'd11 : tone = NM5 << 1;
			4'd12 : tone = NM6 << 1;
			4'd13 : tone = NM7 << 1;
			4'd14 : tone = NM1 << 2;
			default : tone = NM0;
		endcase
	end
endmodule