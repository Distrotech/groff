.NH 1
Opaque Boxes
.PP
\*(id includes statements to blot out pieces
of a picture.
In this section we will sometimes place opaque boxes
without explicitly drawing any background.
In such cases, assume
that we have painted over
the area with pens as above.
.NH 2
Opaque Polygons
.PP
\*(id needs to know the vertices of a polygon in order
to opaque the area it covers.
The vertices are specified as a list in a
.IT bdlist
statement.
For instance, to opaque a rectangular region using the
.IT rect
box defined in Section 3, we could use the following statement:
.IS
...libfile rect
wavy {
	var start, end, perp, pt1, pt2, ht;
	perp = (0,1)*(start - end)/abs(start - end);
	pt1 = 0.25[start,end] + perp*ht;
	pt2 = 0.75[start,end] - perp*ht;
	conn start to pt1 to pt2 to end;
}
brush {
	var top, bot;
	var bwd, bht;
	var leftpt, rightpt;
	leftpt = 0.5*(top+bot) - bwd/2;
	rightpt = 0.5*(top+bot) +bwd/2;
	conn leftpt to rightpt
		using 7 wavy {
			ht = bht;
		}<start,end>;
}
background {
	conn (0,1) to (0,-1)
		using 7 brush {
			bwd = 2;
			bht = 0.1;
			}<top,bot>;
}
main {
	put background {
	};
	put rect {
		opaque;
		bdlist = sw, se, ne, nw;
		sw = (-0.4,-0.4);
		wd = ht = 1;
	};
}
.IF
.P1
put rect {
	opaque;
	bdlist = sw, se, ne, nw;
	sw = (-0.4,-0.4);
	wd = ht = 1;
};




.P2
.LP
The sides of the rectangle are drawn by
.IT rect :
they are not supplied automatically by the opaqueing routine.
If we wanted to save only the interior of the rectangle,
we could use almost the same statement:
.IS
...minx -1.0
...maxx 1.0
...miny -1.0
...maxy 1.0
main {
	put background {
	};
put rect {
	opaque exterior;
	bdlist = sw, se, ne, nw;
	sw = (-0.4,-0.4);
	wd = ht = 1;
};
}
.IF
.P1
put rect {
	opaque exterior;
	bdlist = sw, se, ne, nw;
	sw = (-0.4,-0.4);
	wd = ht = 1;
};
.P2
.PP
If we plan to opaque a lot of rectangles,
we should include a
.IT bdlist
in the definition of
.IT rect .
Such a default
.IT bdlist
would be referenced only if the parameter section
of the put statement included an opaque statement
.IT and
did not include its own
.IT bdlist .
.NH 2
Opaque Circular Arc Polygons
.PP
The edges of opaque regions can also be circular arcs.
.Ts
This generalization of the simple boundary statement
is the most recent addition to \*(id.
It avoids treating circles and their sectors and segments
as special cases, and makes opaqueing circular
arc polygons much easier.
.Te
.LP
To specify a circular arc edge, one gives its endpoints
and a point through which it passes;
this ``pass-through'' point is marked in the boundary
list by the symbol ``\f8^\fP''.
For example, the boundary list for the sector shown below is
.IS
...libfile sector
main {
	put background {
	};
put sector {
	center = (-1,-1);
	radius = 2;
	startang = 30;
	endang = 60;
	opaque;
};
}
.IF
.P1
boundary = center, cis(30), ^ cis(45), cis(60);





.P2
.PP
Another common opaque arc is the segment:
.IS
...libfile segment
main {
	put background {
	};
put segment {
	center = (-1,-1);
	radius = 2;
	startang = 0;
	endang = 90;
	opaque;
};
}
.IF
.P1
boundary = cis(0), ^ cis(45), cis(90);










.P2
.PP
One can construct an opaque circle out of two semicircular edges:
.IS
...libfile circle
main {
	put background {
	};
put circle {
	radius = 0.5;
	center = 0;
	opaque;
};
put circle {
	radius = 1;
	center = 0;
	opaque exterior;
};
}
.IF
.P1
boundary = cis(0), ^ cis(90), cis(180), ^ cis(270);






.P2
.LP
Here, the outer circle has an opaque exterior,
while the inner circle has an opaque interior.
.NH 2
Order is Important
.PP
Without the ability to opaque,
the order in which boxes are put does not matter.
But when some boxes are opaque, order obviously
.IT does
matter.
Put statements are executed
in the order in which they appear in the box definition.
When an opaque box is drawn, the opaquing is done
.IT first ,
then the lines of the box are drawn;
so, for instance, an opaque
.IT listnode
does include the line down its middle separating its
.IT info
field from its
.IT next
field.
.NH 2
Some Hard Facts
.PP
Neither text nor splines can be used to opaque objects,
nor will they be clipped properly if they are in a
picture and an opaque box is placed over them.
.Ts
The problem with text is that \*(id operates as a \*(tf preprocessor,
so it cannot determine anything about the size of the
text, and it needs to know that if it is to do anything
involving opaquing and text.
.Te
.Ts
The problem with splines is more subtle.
When a line or circular arc is chopped,
it is easy to specify the lines or circular arcs that remain.
But when a spline is chopped, the guiding points of the resulting curve pieces
are hard to determine.
.Te
