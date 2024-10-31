`timescale 1ns/1ps

module Comparator_3bits (a, b, a_lt_b, a_gt_b, a_eq_b);
	input [3-1:0] a, b;
	output a_lt_b, a_gt_b, a_eq_b;

	wire [3-1:0] Na, Nb;
	wire or1, or2, or3;
	wire Nor1, Nor2, Nor3;
	wire gorl1, gorl2, gorl3;
	wire eq, gt;

	///The part of a_eq_b
	ex_or eo1 (a[2], b[2], or1);
	ex_or eo2 (a[1], b[1], or2);
	ex_or eo3 (a[0], b[0], or3);

	not n1 (Nor1, or1);
	not n2 (Nor2, or2);
	not n3 (Nor3, or3);

	and a1 (a_eq_b, Nor1, Nor2, Nor3);

	///The part of a_gt_b
	and a2 (gorl1, or1, a[2]);
	and a3 (gorl2, Nor1, or2, a[1]);
	and a4 (gorl3, Nor1, Nor2, or3, a[0]);

	or o1 (a_gt_b, gorl1, gorl2, gorl3);

	///The part of a_lt_b
	not n4 (eq, a_eq_b);
	not n5 (gt, a_gt_b);

	and a5 (a_lt_b, eq, gt);
endmodule


module ex_or (a, b, c);
	input a, b;
	output c;
	wire Na, Nb, and1, and2;

	not (Na, a);
	not (Nb, b);
	and (and1, Na, b);
	and (and2, Nb, a);
	or (c, and1, and2);
endmodule