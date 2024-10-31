`timescale 1ns / 1ps

module clock_div(clk, rst, dclk);
    input clk, rst;
    output reg dclk;
    
    localparam define_speed = 26'd10_0000;

    reg [25:0] count, next_count;

    always@(posedge clk, posedge rst) begin
        if (rst)	count = 26'b0;
        else		count = next_count;
    end
    
    assign next_count = (count == define_speed) ? 26'b0 : count + 1'b1;
    assign dclk = (count == define_speed) ? ~dclk : dclk;
endmodule
