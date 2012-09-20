#!@PERLPATH@ -w
#
#	pdfmom		: Frontend to run groff -mom to produce PDFs
#	Deri James	: Friday 16 Mar 2012
#

# Copyright (C) 2012 Free Software Foundation, Inc.
#      Written by Deri James <deri@chuzzlewit.demon.co.uk>
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# groff is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
my @cmd;
my $dev='pdf';

$ENV{PATH}=$ENV{GROFF_BIN_PATH}.':'.$ENV{PATH} if exists($ENV{GROFF_BIN_PATH});

while (my $c=shift)
{
    if (substr($c,0,2) eq '-T')
    {
	if (length($c) > 2)
	{
	    $dev=substr($c,2);
	}
	else
	{
	    $dev=shift;
	}

	next;
    }
    elsif ($c eq '-z' or $c eq '-Z')
    {
	$dev=$c;
	next;
    }

    elsif ($c eq '-v')
    {
	print "GNU pdfmom (groff) version @VERSION@\n";
	exit;
    }

    push(@cmd,$c);
}

my $cmdstring=join(' ',@cmd);

if ($dev eq 'pdf')
{
    system("groff -Tpdf -dPDF.EXPORT=1 -mom -z $cmdstring 2>&1 | grep '^.ds' | groff -Tpdf -mom - $cmdstring");
}
elsif ($dev eq 'ps')
{
    system("pdfroff -mpdfmark -mom --no-toc $cmdstring");
}
elsif ($dev eq '-z') # pseudo dev - just compile for warnings
{
    system("groff -Tpdf -mom -z $cmdstring");
}
elsif ($dev eq '-Z') # pseudo dev - produce troff output
{
    system("groff -Tpdf -mom -Z $cmdstring");
}
else
{
    print STDERR "Not compatible with device '-T $dev'\n";
    exit 1;
}

