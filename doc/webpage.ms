.\" This file gives a small example how a web page could look like if created
.\" with groff.
.\"
.\"
.\" To make it work with other output devices also, we include www.tmac
.\" directly.
.\"
.nr PS 10
.nr VS 12
.if '\*[.T]'html' .nr LL 10i
.if r ps4html .nr LL 10i
.mso www.tmac
.
.de blm-macro
.  nr tmp \\n[.i]
.  LP
.  in \\n[tmp]u
..
.blm blm-macro
.
.HX 0
.
.defcolor darkred rgb 0.65f 0.1f 0.2f
.defcolor darkgreen rgb 0.1f 0.5f 0.2f
.defcolor darkblue rgb 0.1f 0.2f 0.6f
.
.ds GNU \m[darkred]G\m[]\m[darkgreen]N\m[]\m[darkblue]U\m[]
.
.HTL
.NHR
.
Home of Groff (GNU Troff).
.
.HTML-IMAGE-LEFT
.PSPIC -L gnu.eps 2i 2i
\v'-0.75i'\h'2.0i'\s[60]\*[GNU] Troff\s0
.HTML-IMAGE-END
.
.HnS 1
.HR
GNU Troff
.URL http://\:groff.ffii.org/ (Groff) 
\[em] a
.URL http://\:www.gnu.org/ GNU 
project.
Hosted by
.URL http://\:ffii.org/ FFII .
.HR
.HnE
.LK

.DC T HE darkred
groff (GNU Troff) software
is a typesetting package which reads plain text mixed with
formatting commands and produces formatted output.
Groff now supports HTML.
.\" Please see
.\" .URL "Groff Web Tips" "#Web Tips" .
.
.
.SH
Download

.URL "ftp://\:groff.ffii.org/\:pub/\:groff/" Germany 
|
.URL "ftp://\:ftp.gnu.org/\:gnu/\:groff/" USA 

.URL http://\:www.gnu.org/\:copyleft/\:gpl.html License 
|
.URL http://\:ffii.org/\:mailman/\:listinfo/\:groff/ "Mailing list" 
|
.URL "http://\:www.cs.vu.nl/\:~tmgil/\:misc/\:wingroff.html" "Groff for Windows" 

User issues lead:
.MTO Ted.Harding@\:nessie.mcc.ac.uk "Ted Harding"
.br
Technical issues lead:
.MTO wl@\:gnu.org "Werner Lemberg"
.
.
.SH
README

This is the GNU groff document formatting system.
The version number is given in the file VERSION.

Included in this release are implementations of troff, pic, eqn, tbl, refer,
the -man macros and the -ms macros, and drivers for PostScript, TeX dvi
format, HP LaserJet 4 printers, HTML format (still alpha), and
typewriter-like devices.
Also included is a modified version of the Berkeley -me macros, an enhanced
version of the X11 xditview previewer, and an implementation of the -mm
macros contributed by
.MTO jh@\:axis.se "J\(:orgen H\(:agg" .

See the file INSTALL for installation instructions.
You will require a C++ compiler.

The file NEWS describes recent user-visible changes to groff.

Groff is free software.
See the file COPYING for copying permission.

The file PROBLEMS describes various problems that have been encountered in
compiling, installing, and running groff.

For the moment, the documentation assumes that you are already familiar with
the Unix versions of troff, -man, -ms and the preprocessors.

The most recent released version of groff is always available by anonymous
ftp from ftp.gnu.org in the directory pub/\:gnu/\:groff.

A CVS repository is now available, containing the current development
version of groff.
You can access it with the commands:

.RS
.nf
.ft C
export CVSROOT=:pserver:anoncvs@anoncvs.ffii.org:/var/cvs
cvs login
cvs -z9 co groff
.ft P
.fi
.RE

(if the prompt for the password appears, just press the enter key).
After a successful login you no longer need the first two commands; an
update of a checked out repository should be done with:

.RS
.ft C
cvs -z9 update -dP
.ft P
.RE

Please read the info pages of cvs for further details.

Alternatively, you can download snapshots (which are updated twice a day)
from
.URL ftp://\:ftp.ffii.org/\:pub/\:groff/\:devel/\:groff-current.tar.gz here
or a diff file relative to the latest official groff release as:

.RS
.ft C
ftp://ftp.ffii.org/pub/groff/devel/groff-[version]-current.diff.gz
.ft P
.RE

Please report bugs using the form in the file BUG-REPORT; the idea of this
is to make sure that FSF has all the information it needs to fix the bug.
At the very least, read the BUG-REPORT form and make sure that you supply
all the information that it asks for.
Even if you are not sure that something is a bug, report it using
BUG-REPORT: this will enable us to determine whether it really is a bug or
not.

Three mailing lists are available:

.ULS
.LI
.MTO bug-groff@gnu.org bug-groff@gnu.org
for reporting bugs

.LI
.MTO groff@gnu.org groff@gnu.org
for general discussion of groff

.LI
.MTO groff-commit@ffii.org groff-commit@ffii.org
a read-only list showing logs of commitments to the CVS repository
.ULE

Note that groff@gnu.org is an alias for
.MTO groff@\:ffii.org groff@\:ffii.org ;
you must be subscribed to the `groff' and `groff-commit' lists to send mails.

To subscribe, send e-mail to [list]-request@[domain] (example:
.MTO groff-request@\:ffii.org groff-request@\:ffii.org )
with the word `subscribe' in either the
subject or body of the e-mail (don't include the quotes).

GNU groff was written by
.MTO jjc@\:jclark.com "James Clark" .
It is now maintained by
.MTO Ted.Harding@\:nessie.mcc.ac.uk "Ted Harding"
and
.MTO wl@\:gnu.org "Werner Lemberg" .
.br
.br
.
.
.SH
NEWS VERSION 1.18

This section describes recent user-visible changes in groff.  Bug
fixes are not described.  There are more details in the man pages.
.
.
.SH 2
Troff

.ULS
.LI
Color support has been added to troff and pic (and to two device drivers,
grops and grohtml -- other preprocessors and drivers will follow).  A new
function `defcolor' defines colors; the escape sequence `\em' sets the
drawing color, the escape sequence `\eM' specifies the background color for
closed objects created with \eD'...' commands.  Similar to fonts, `\emP' and
`\eMP' switch back to the previous color.  `\em' and `\eM' correspond to the
new troff output commands `m' and `DF'.

Outputting color can be disabled in troff and groff with the option -c
(it is always disabled in compatibility mode).

For defining color components as fractions between 0 and 1, a new scaling
indicator `f' has been defined: 1f = 65536u.  For testing whether a color
is defined (with .if and .ie), a new conditional operator `m' is
available.

More details can be found in the troff manual page.

.LI
It is now possible to have whitespace between the first and second dot (or
the name of the ending macro) to end a macro definition.  Example:
.RS
.nf
.ft C
\&.de !
\&..
\&.
\&.de foo
\&.  nop Hello, I'm `foo'.
\&.  nop I will now define `bar'.
\&.  de bar !
\&.    nop Hello, I'm `bar'.
\&.  !
\&..
.ft P
.fi
.RE

.LI
`.fn' is a new string-valued register which returns the (internal) real
font name; styles and families are properly concatenated.

.LI
The new request `fchar' can be used to provide fallback characters.  Its
syntax is the same as the `char' request; the only difference is that a
character defined with `.char' hides the glyph with the same name in the
current font, whereas a character defined with `.fchar' is checked only if
the particular glyph isn't found in the current font.  This test happens
before checking special fonts.

.LI
The new request `itc' is a variant of `.it' for which a line interrupted
with \ec counts as one input line.

.LI
A new escape sequence `\eO' is available (mainly for internal use with
grohtml).  Please see groff_diff.man and groff.texinfo for more details.

.LI
Two macros `AT' (AT&T) and `UC' (Univ. of California) have been added to
the man macros for compatibility with older BSD releases.

.LI
The `-xwidth' specifier in the mdoc macro package has been removed.  Its
functionality is now integrated directly into `-width'.  Similarly,
`-column' has been extended to has this functionality also.

.LI
A new macro `Ex' has been added to the mdoc macro package to document an
exit status.

.LI
`troff.man' has been split.  Differences to UNIX troff are now documented
in the new man page `groff_diff.man'.

.LI
groff_mwww.man' has been renamed to `groff_www.man'.  The file mwww.tmac
has been removed.

.LI
The macro `NO-AUTO-RULE' has been added to www.tmac; it suppresses the
generation of top and bottom rules which grohtml emits by default.
.ULE
.
.
.SH 2
groff

.ULS
.LI
The new command line `-c' disables color output (which is always disabled
in compatibility mode).
.ULE
.
.
.SH 2
pic

.ULS
.LI
New keywords `color' (or `colour', `colored', `coloured'), `outline' (or
`outlined'), and `shaded' are available.  `outline' sets the color of the
outline, `shaded' the fill color, and `color' sets both.  Example:
.RS
\fCcircle shaded "green" outline "black" ;\fP
.RE
Color support for TeX output is not implemented yet.
.ULE
.
.
.SH 2
Pic2graph

.ULS
.LI
A new script contributed by Eric S. Raymond <esr@thyrsus.com>.  It
converts a PIC diagram into a cropped image.  Since it uses gs and the PNM
library, virtually all graphics formats are available for output.
.ULE
.
.
.SH 2
grops

.ULS
.LI
Color support has been added.
.ULE
.
.
.SH 2
grohtml

.ULS
.LI
Color support for glyphs has been added.

.LI
New option `\fC-h\fP' to select the style of headings in HTML output.
.ULE
.
.
.SH 2
Miscellaneous

.ULS
.LI
A new manual page `\fCditroff.7\fP' is available.
.ULE
.
.HR
.
\s-2\fIThis document was produced using
.URL http://groff.ffii.org/ groff-\n[.x].\n[.y] .\s0\fP
.HR
.\" EOF
