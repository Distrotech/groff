.\"------------
.\" Cover sheet. Mostly like ms cover.
.\" version 0.8
.\"------------
.de cov@print-title
.nf
.in 0
.ce \\n[cov*title-size]
.cov*title
.fi
..
.\"------------
.de cov@print-authors
.nr cov*i 0 1
.while \\n+[cov*i]<=\\n[cov*au] \{\
.	ce
\fI\\*[cov*au!\\n[cov*i]!1]\fP
.\}
..
.\"------------
.de cov@print-abstract
.DS CB
.cov*abstract
.DE
..
.\"------------
.de cov@print-date
.S 8
.ce
\\*[cov*new-date]
..
.\"-----------------
.sp 8
.cov@print-title
.\"
.sp 2
.S 12
.cov@print-authors
.\"
.sp 2
.cov@print-date
.sp 4
.S 10
.cov@print-abstract
.pg@enable-top-trap
.bp 1
.pg@enable-trap
