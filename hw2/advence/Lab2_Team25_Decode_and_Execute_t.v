`timescale 1ns/1ps

module Decode_and_Execute_t;
reg [3-1:0] op_code = 3'b0;
reg [4-1:0] rs = 4'b0;
reg [4-1:0] rt = 4'b0;
wire [4-1:0] rd;
integer error;

Decode_and_Execute D1 (
  .op_code (op_code),
  .rs (rs),
  .rt (rt),
  .rd (rd)
);

initial begin
  error = 0;
  repeat (2 ** 11) begin
    #1
	if (op_code==0) begin
		if (rd != rs + rt) begin
			$display ("Error occured(op_code=%b, rs=%b, rt=%b, rd=%b)", op_code, rs, rt, rd);
			error = error + 1;
		end
	end
	else if (op_code==1) begin
		if (rd != rs - rt) begin
			$display ("Error occured(op_code=%b, rs=%b, rt=%b, rd=%b)", op_code, rs, rt, rd);
			error = error + 1;
		end
	end
	else if (op_code==2) begin
		if (rd != rs + 1'b1) begin
			$display ("Error occured(op_code=%b, rs=%b, rt=%b, rd=%b)", op_code, rs, rt, rd);
			error = error + 1;
		end
	end
	else if (op_code==3) begin
		if (rd[3] != !(rs[3]|rt[3]) || rd[2] != !(rs[2]|rt[2]) || rd[1] != !(rs[1]|rt[1]) || rd[0] != !(rs[0]|rt[0])) begin
			$display ("Error occured(op_code=%b, rs=%b, rt=%b, rd=%b)", op_code, rs, rt, rd);
			error = error + 1;
		end
	end
	else if (op_code==4) begin
		if (rd[3] != !(rs[3]&rt[3]) || rd[2] != !(rs[2]&rt[2]) || rd[1] != !(rs[1]&rt[1]) || rd[0] != !(rs[0]&rt[0])) begin
			$display ("Error occured(op_code=%b, rs=%b, rt=%b, rd=%b)", op_code, rs, rt, rd);
			error = error + 1;
		end
	end
	else if (op_code==5) begin
		if (rd != rs >> 2) begin
			$display ("Error occured(op_code=%b, rs=%b, rt=%b, rd=%b)", op_code, rs, rt, rd);
			error = error + 1;
		end
	end
	else if (op_code==6) begin
		if (rd != rs << 1) begin
			$display ("Error occured(op_code=%b, rs=%b, rt=%b, rd=%b)", op_code, rs, rt, rd);
			error = error + 1;
		end
	end
	else if (op_code==7) begin
		if (rd != rs * rt) begin
			$display ("Error occured(op_code=%b, rs=%b, rt=%b, rd=%b)", op_code, rs, rt, rd);
			error = error + 1;
		end
	end
	{rt, rs, op_code} = {rt, rs, op_code} + 1'b1;
  end
  $display("%d error(s)", error);
  #1 $finish;
end

endmodule
