`define NM1 32'd392 //G_freq
`define NM2 32'd440 //A_freq
`define NM3 32'd494 //B_freq
`define NM4 32'd524 //C_freq
`define NM5 32'd588 //D_freq
`define NM6 32'd660 //E_freq
`define NM7 32'd740 //#F_freq
`define NM0 32'd20000 //slience (over freq.)

module Music (
	input [8:0] ibeatNum,	
	output reg [31:0] tone
);

always @(*) begin
	case (ibeatNum)
		8'd0 : tone = `NM1;
		8'd1 : tone = `NM1;
		8'd2 : tone = `NM1;
		8'd3 : tone = `NM1;
		8'd4 : tone = `NM1;
		8'd5 : tone = `NM1;
		8'd6 : tone = `NM1;
		8'd7 : tone = `NM1;
		8'd8 : tone = `NM0;
		8'd9 : tone = `NM0;
		8'd10 : tone = `NM0;
		8'd11 : tone = `NM0;
		8'd12 : tone = `NM5 >> 1;
		8'd13 : tone = `NM5 >> 1;
		8'd14 : tone = `NM6 >> 1;
		8'd15 : tone = `NM6 >> 1;
		
		8'd16 : tone = `NM1;
		8'd17 : tone = `NM1;
		8'd18 : tone = `NM6 >> 1;
		8'd19 : tone = `NM6 >> 1;
		8'd20 : tone = `NM5 >> 1;
		8'd21 : tone = `NM5 >> 1;
		8'd22 : tone = `NM6 >> 1;
		8'd23 : tone = `NM6 >> 1;
		8'd24 : tone = `NM5;
		8'd25 : tone = `NM5;
		8'd26 : tone = `NM5;
		8'd27 : tone = `NM5;
		8'd28 : tone = `NM5;
		8'd29 : tone = `NM5;
		8'd30 : tone = `NM3;
		8'd31 : tone = `NM3;
		
		8'd32 : tone = `NM6;
		8'd33 : tone = `NM6;
		8'd34 : tone = `NM7;
		8'd35 : tone = `NM7;
		8'd36 : tone = `NM6;
		8'd37 : tone = `NM6;
		8'd38 : tone = `NM5;
		8'd39 : tone = `NM5;
		8'd40 : tone = `NM3;
		8'd41 : tone = `NM3;
		8'd42 : tone = `NM3;
		8'd43 : tone = `NM3;
		8'd44 : tone = `NM3;
		8'd45 : tone = `NM3;
		8'd46 : tone = `NM0;
		8'd47 : tone = `NM0;
		
		8'd48 : tone = `NM6;
		8'd49 : tone = `NM6;
		8'd50 : tone = `NM7;
		8'd51 : tone = `NM7;
		8'd52 : tone = `NM6;
		8'd53 : tone = `NM6;
		8'd54 : tone = `NM5;
		8'd55 : tone = `NM5;
		8'd56 : tone = `NM3;
		8'd57 : tone = `NM3;
		8'd58 : tone = `NM5;
		8'd59 : tone = `NM5;
		8'd60 : tone = `NM5;
		8'd61 : tone = `NM5;
		8'd62 : tone = `NM1;
		8'd63 : tone = `NM1;
		
		8'd64 : tone = `NM6 >> 1;
		8'd65 : tone = `NM6 >> 1;
		8'd66 : tone = `NM1;
		8'd67 : tone = `NM1;
		8'd68 : tone = `NM2;
		8'd69 : tone = `NM2;
		8'd70 : tone = `NM3;
		8'd71 : tone = `NM3;
		8'd72 : tone = `NM2;
		8'd73 : tone = `NM2;
		8'd74 : tone = `NM2;
		8'd75 : tone = `NM2;
		8'd76 : tone = `NM2;
		8'd77 : tone = `NM2;
		8'd78 : tone = `NM0;
		8'd79 : tone = `NM0;
		
		8'd80 : tone = `NM1;
		8'd81 : tone = `NM1;
		8'd82 : tone = `NM2;
		8'd83 : tone = `NM2;
		8'd84 : tone = `NM1;
		8'd85 : tone = `NM1;
		8'd86 : tone = `NM6 >> 1;
		8'd87 : tone = `NM6 >> 1;
		8'd88 : tone = `NM5 >> 1;
		8'd89 : tone = `NM5 >> 1;
		8'd90 : tone = `NM5;
		8'd91 : tone = `NM5;
		8'd92 : tone = `NM5;
		8'd93 : tone = `NM5;
		8'd94 : tone = `NM3;
		8'd95 : tone = `NM3;
		
		8'd96 : tone = `NM6;
		8'd97 : tone = `NM6;
		8'd98 : tone = `NM7;
		8'd99 : tone = `NM7;
		8'd100 : tone = `NM6;
		8'd101 : tone = `NM6;
		8'd102 : tone = `NM5;
		8'd103 : tone = `NM5;
		8'd104 : tone = `NM3;
		8'd105 : tone = `NM3;
		8'd106 : tone = `NM3;
		8'd107 : tone = `NM3;
		8'd108 : tone = `NM3;
		8'd109 : tone = `NM3;
		8'd110 : tone = `NM0;
		8'd111 : tone = `NM0;
		
		8'd112 : tone = `NM6;
		8'd113 : tone = `NM6;
		8'd114 : tone = `NM7;
		8'd115 : tone = `NM7;
		8'd116 : tone = `NM6;
		8'd117 : tone = `NM6;
		8'd118 : tone = `NM5;
		8'd119 : tone = `NM5;
		8'd120 : tone = `NM3;
		8'd121 : tone = `NM3;
		8'd122 : tone = `NM5 >> 1;
		8'd123 : tone = `NM5 >> 1;
		8'd124 : tone = `NM5 >> 1;
		8'd125 : tone = `NM5 >> 1;
		8'd126 : tone = `NM3;
		8'd127 : tone = `NM3;
		
		default : tone = `NM0;
	endcase
end

endmodule