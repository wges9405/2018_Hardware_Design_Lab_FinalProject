module Top (
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire clk,
	input wire rst,
	output [3:0] vgaRed,
	output [3:0] vgaGreen,
	output [3:0] vgaBlue,
	output hsync,
	output vsync
	);
	
	wire rst_db;
	wire rst_op;
	
	Debounce Db_rst(
		.clk(clk),
		.pb(rst),
		.pb_debounced(rst_db)
	);
	
	OnePulse op_rst(
		.signal_single_pulse(rst_op),
		.signal(rst_db),
		.clock(clk)
	);
	
  	parameter [8:0] KEY_CODES [0:6] = {
		9'b0_0111_0101, // up => 75
		9'b0_0111_0010, // down => 72
		9'b0_0110_1011, // left => 6B
		9'b0_0111_0100, // right => 74
		9'b0_0100_1101,	// p => 4D
		9'b0_0010_1010,	// v => 2A
		9'b0_0011_0011	// h => 33
	};
	
	wire [511:0] key_down;
	
	wire [8:0] last_change;
	wire key_valid;
	
	KeyboardDecoder KD1(
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(key_valid),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst_op),
		.clk(clk)
    );
	
	wire [6:0] key_db;
	wire [6:0] key;
	
	Debounce Db1(
		.clk(clk),
		.pb(key_down[KEY_CODES[0]]),
		.pb_debounced(key_db[0])
	);
	
	Debounce Db2(
		.clk(clk),
		.pb(key_down[KEY_CODES[1]]),
		.pb_debounced(key_db[1])
	);
	
	Debounce Db3(
		.clk(clk),
		.pb(key_down[KEY_CODES[2]]),
		.pb_debounced(key_db[2])
	);
	
	Debounce Db4(
		.clk(clk),
		.pb(key_down[KEY_CODES[3]]),
		.pb_debounced(key_db[3])
	);
	
	Debounce Db5(
		.clk(clk),
		.pb(key_down[KEY_CODES[4]]),
		.pb_debounced(key_db[4])
	);
	
	Debounce Db6(
		.clk(clk),
		.pb(key_down[KEY_CODES[5]]),
		.pb_debounced(key_db[5])
	);
	
	Debounce Db7(
		.clk(clk),
		.pb(key_down[KEY_CODES[6]]),
		.pb_debounced(key_db[6])
	);
	
	OnePulse op1(
		.signal_single_pulse(key[0]),
		.signal(key_db[0]),
		.clock(clk)
	);
	
	OnePulse op2(
		.signal_single_pulse(key[1]),
		.signal(key_db[1]),
		.clock(clk)
	);
	
	OnePulse op3(
		.signal_single_pulse(key[2]),
		.signal(key_db[2]),
		.clock(clk)
	);
	
	OnePulse op4(
		.signal_single_pulse(key[3]),
		.signal(key_db[3]),
		.clock(clk)
	);
	
	OnePulse op5(
		.signal_single_pulse(key[4]),
		.signal(key_db[4]),
		.clock(clk)
	);
	
	OnePulse op6(
		.signal_single_pulse(key[5]),
		.signal(key_db[5]),
		.clock(clk)
	);
	
	OnePulse op7(
		.signal_single_pulse(key[6]),
		.signal(key_db[6]),
		.clock(clk)
	);
	
	wire [3:0] dir;
	wire scroll, flip_v, flip_h;
	
	Trasform tf(
		.clk(clk),
		.rst(rst_op),
		.key(key),
		.dir(dir),
		.scroll(scroll),
		.flip_v(flip_v),
		.flip_h(flip_h)
	);
	
	wire [11:0] data;
	wire clk_25MHz;
	wire clk_22;
	wire [16:0] pixel_addr;
	wire [11:0] pixel;
	wire valid;
	wire [9:0] h_cnt; //640
	wire [9:0] v_cnt; //480
	
	assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel : 12'h0;
	
	clock_divisor clk_wiz_0_inst(
		.clk(clk),
		.clk1(clk_25MHz),
		.clk22(clk_22)
	);

	mem_addr_gen mem_addr_gen_inst(
		.clk(clk_22),
		.rst(rst_op),
		.h_cnt(h_cnt),
		.v_cnt(v_cnt),
		.dir(dir),
		.scroll(scroll),
		.flip_v(flip_v),
		.flip_h(flip_h),
		.pixel_addr(pixel_addr)
	);
	
	blk_mem_gen_0 blk_mem_gen_0_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr),
		.dina(data[11:0]),
		.douta(pixel)
	); 
	
	vga_controller vga_inst(
		.pclk(clk_25MHz),
		.reset(rst_op),
		.hsync(hsync),
		.vsync(vsync),
		.valid(valid),
		.h_cnt(h_cnt),
		.v_cnt(v_cnt)
	);
	
endmodule

module Trasform (
	input clk,
	input rst,
	input [6:0] key,
	output reg [3:0] dir,
	output reg scroll,
	output reg flip_v,
	output reg flip_h
	);
	
	reg [3:0] next_dir;
	reg next_scroll, next_flip_v, next_flip_h;
	
	always @(posedge clk) begin
		if(rst) begin
			dir <= 4'b0001;
			scroll <= 1'b0;
			flip_v <= 1'b0;
			flip_h <= 1'b0;
		end
		else begin
			dir <= next_dir;
			scroll <= next_scroll;
			flip_v <= next_flip_v;
			flip_h <= next_flip_h;
		end
	end
	
	always @(*) begin
		case(key[3:0])
			4'b0001: begin
				next_dir = 4'b0001;
			end
			4'b0010: begin
				next_dir = 4'b0010;
			end
			4'b0100: begin
				next_dir = 4'b0100;
			end
			4'b1000: begin
				next_dir = 4'b1000;
			end
			default: begin
				next_dir = dir;
			end
		endcase
	end
	
	always @(*) begin
		if(key[4] == 1'b1) begin
			next_scroll = !scroll;
		end
		else begin
			next_scroll = scroll;
		end
	end
	
	always @(*) begin
		if(key[5] == 1'b1) begin
			next_flip_v = !flip_v;
		end
		else begin
			next_flip_v = flip_v;
		end
	end
	
	always @(*) begin
		if(key[6] == 1'b1) begin
			next_flip_h = !flip_h;
		end
		else begin
			next_flip_h = flip_h;
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

module Debounce (clk, pb, pb_debounced);
  input pb, clk;
  output pb_debounced;
  reg [4-1:0] DFF;

  assign pb_debounced = ((DFF == 4'b1111) ? 1'b1 : 1'b0);
  
  always @(posedge clk) begin
    DFF[3:1] <= DFF[2:0];
    DFF[0] <= pb;
  end
endmodule

module mem_addr_gen(
	input clk,
	input rst,
	input [9:0] h_cnt,
	input [9:0] v_cnt,
	input [3:0] dir,
	input scroll,
	input flip_v,
	input flip_h,
	output [16:0] pixel_addr
	);
	
	reg [9:0] position_v;
	reg [9:0] position_h;
	reg [9:0] h, v;
	
	always @ (*) begin
		if(flip_h) h = 639 - (h_cnt + position_h) % 640;
		else h = (h_cnt + position_h) % 640;
	end
	
	always @ (*) begin
		if(flip_v) v = 479 - (v_cnt + position_v) % 480;
		else v = (v_cnt + position_v) % 480;
	end
	
	assign pixel_addr = ( (h>>1) + 320 * (v>>1) ) % 76800; //640*480 --> 320*240 
	
	always @ (posedge clk or posedge rst) begin
		if(rst) begin
			position_v <= 0;
			position_h <= 0;
		end
		else if(!scroll) begin
			position_v <= position_v;
			position_h <= position_h;
		end
		else begin
			case(dir)
				4'b0001: begin
					position_h <= position_h;
					
					if(position_v < 479)
						position_v <= position_v + 1;
					else
						position_v <= 0;
				end
				4'b0010: begin
					position_h <= position_h;
					
					if(position_v > 0)
						position_v <= position_v - 1;
					else
						position_v <= 479;
				end
				4'b0100: begin
					position_v <= position_v;
					
					if(position_h < 639)
						position_h <= position_h + 1;
					else
						position_h <= 0;
				end
				4'b1000: begin
					position_v <= position_v;
					
					if(position_h > 0)
						position_h <= position_h - 1;
					else
						position_h <= 639;
				end
				default: begin
					position_v <= position_v;
					position_h <= position_h;
				end
			endcase
		end
	end
    
endmodule

module vga_controller 
  (
    input wire pclk,reset,
    output wire hsync,vsync,valid,
    output wire [9:0]h_cnt,
    output wire [9:0]v_cnt
    );
    
    reg [9:0]pixel_cnt;
    reg [9:0]line_cnt;
    reg hsync_i,vsync_i;
    wire hsync_default, vsync_default;
    wire [9:0] HD, HF, HS, HB, HT, VD, VF, VS, VB, VT;

   
    assign HD = 640;
    assign HF = 16;
    assign HS = 96;
    assign HB = 48;
    assign HT = 800; 
    assign VD = 480;
    assign VF = 10;
    assign VS = 2;
    assign VB = 33;
    assign VT = 525;
    assign hsync_default = 1'b1;
    assign vsync_default = 1'b1;
     
    always@(posedge pclk)
        if(reset)
            pixel_cnt <= 0;
        else if(pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
             else
                pixel_cnt <= 0;

    always@(posedge pclk)
        if(reset)
            hsync_i <= hsync_default;
        else if((pixel_cnt >= (HD + HF - 1))&&(pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default; 
    
    always@(posedge pclk)
        if(reset)
            line_cnt <= 0;
        else if(pixel_cnt == (HT -1))
                if(line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;
                    
    always@(posedge pclk)
        if(reset)
            vsync_i <= vsync_default; 
        else if((line_cnt >= (VD + VF - 1))&&(line_cnt < (VD + VF + VS - 1)))
            vsync_i <= ~vsync_default; 
        else
            vsync_i <= vsync_default; 
                    
    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));
    
    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt:10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt:10'd0;
           
endmodule

module clock_divisor(clk1, clk, clk22);
	input clk;
	output clk1;
	output clk22;
	reg [21:0] num;
	wire [21:0] next_num;
	
	always @(posedge clk) begin
		num <= next_num;
	end
	
	assign next_num = num + 1'b1;
	assign clk1 = num[1];
	assign clk22 = num[21];
endmodule
