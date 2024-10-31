`timescale 1ns / 1ps

module pmod_step_driver(rst, dir, clk, en, signal);
    input rst, dir, clk, en;
    output reg [3:0] signal;

    localparam sig4 = 3'b001;
    localparam sig3 = 3'b011;
    localparam sig2 = 3'b010;
    localparam sig1 = 3'b110;
    localparam sig0 = 3'b000;

    reg [2:0] present_state, next_state;

    always@(*)begin
        case(present_state)
        sig4: 		next_state = (dir && en) ? sig1 : (en) ? sig3 : sig0;
        sig3: 		next_state = (dir && en) ? sig4 : (en) ? sig2 : sig0;
        sig2: 		next_state = (dir && en) ? sig3 : (en) ? sig1 : sig0;
        sig1: 		next_state = (dir && en) ? sig2 : (en) ? sig4 : sig0;
        sig0: 		next_state = (en) ? sig1 : sig0;
        default: 	next_state = sig0; 
        endcase
    end 
    
    always@(posedge clk, posedge rst)begin
        if (rst) 	present_state = sig0;
        else 		present_state = next_state;
    end
         
    always@(*)begin
    	case(present_state)
    		sig0: 		signal = 4'b0000;
    		sig1: 		signal = 4'b0001;
    		sig2: 		signal = 4'b0010;
    		sig3: 		signal = 4'b0100;
    		sig4: 		signal = 4'b1000;
    		default: 	signal = 4'b0000;
    	endcase
    end
endmodule
