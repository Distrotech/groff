.\"------------
.\" Cover sheet. Memorandum type 0
.\" version 0.10
.\" MT covers will be maintained at low priority.
.\"------------
.PH "''''"
.OH "''''"
.EH "''''"
.de cov@print-title
.MOVE 5.6c 1.5c
.S 8
subject:
.br
.sp -1.4
.S
.in 1.2c
.\" .MOVE \\n[misc*cur-bline]u 2.7c
.nf
.B
.cov*title
.R
.fi
.PGFORM
..
.\"------------
.de cov@print-authors
.MOVE 6.5c 13.5c
.S 8
\\$1:
.br
.S
.sp -1
.in 0.8c
.B
.nr cov*i 0 1
.while \\n+[cov*i]<=\\n[cov*au] \{\
\\*[cov*au!\\n[cov*i]!1]
.br
.\}
.R
.PGFORM
..
.\"------------
.de cov@print-date
.MOVE 5.6c 13.5c
.S 8
\\$1:
.br
.S
.sp -1
.in 0.8c
.B "\\*[cov*new-date]"
.br
.PGFORM
..
.\"------------
.de cov@print-firm
.MOVE 4c 0 17.7c
.S 18
.rj \\n[cov*title-size]
\fB\\*[cov*firm]\fP
.S
.PGFORM
..
.\"------------
.de cov@print-abstract
.MOVE 8.1c
.ce
\fI\\$1\fP
.SP 1c
.ev cov*ev
.init@reset
.nf
.ll \\n[@ll]u
.if d cov*abstract .cov*abstract
.ev
..
.\"-----------------
.if !d cov*mt-printed \{\
.	cov@print-firm
.	cov@print-title subject
.	cov@print-date date
.	cov@print-authors from
.	cov@print-abstract ABSTRACT
.	SP 1.7c
.	ce
\fIMEMORANDUM FOR FILE\fP
.	pg@enable-top-trap
.	pg@enable-trap
.	ds cov*mt-printed
.\}
