`timescale 1ns/1ps

module Comparator_3bits (a, b, lt0, lt1, lt2, eq0, eq1, eq2, eq3, eq4, eq5, eq6, eq7, eq8, eq9, gt0, gt1, gt2);
	input [3-1:0] a, b;
	output lt0, lt1, lt2, eq0, eq1, eq2, eq3, eq4, eq5, eq6, eq7, eq8, eq9, gt0, gt1, gt2;

	wire [3-1:0] Na, Nb;
	wire or1, or2, or3;
	wire Nor1, Nor2, Nor3;
	wire gorl1, gorl2, gorl3;
	wire lt, eq, gt;

	///The part of a_eq_b
	ex_or eo1 (a[2], b[2], or1);
	ex_or eo2 (a[1], b[1], or2);
	ex_or eo3 (a[0], b[0], or3);

	not n1 (Nor1, or1);
	not n2 (Nor2, or2);
	not n3 (Nor3, or3);

	and a1 (eq0, Nor1, Nor2, Nor3);
	not n4 (eq, eq0);
	not n6 (eq1, eq2, eq3, eq4, eq5, eq6, eq7, eq8, eq9, eq);

	///The part of a_gt_b
	and a2 (gorl1, or1, a[2]);
	and a3 (gorl2, Nor1, or2, a[1]);
	and a4 (gorl3, Nor1, Nor2, or3, a[0]);

	or o1 (gt0, gorl1, gorl2, gorl3);
	not n5 (gt, gt0);
	not n7 (gt1, gt2, gt);

	///The part of a_lt_b
	and a5 (lt0, eq, gt);
	not n8 (lt, lt0);
	not n9 (lt1, lt2, lt);
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