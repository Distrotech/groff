#! /usr/bin/env perl

# groff_lilypond - integrate lilypond into groff files

# Source file position: <groff-source>/contrib/lilypond/groff_lilypond.pl
# Installed position: <prefix>/bin/groff_lilypond

# Copyright (C) 2013 Free Software Foundation, Inc.
# Written by Bernd Warken <groff-bernd.warken-72@web.de>.

# Last update: 09 Feb 2013

# This file is part of `groff'.

# `groff' is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# `groff' is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

########################################################################

use strict;
use warnings;

sub version {
    print "groff_lilypond version 0.1 is part of groff\n";
}

sub usage {
    print <<EOF
groff_lilypond [filename]
groff_lilypond -h|--help
groff_lilypond -v|--version
Read a roff file or standard input and transform `lilypond' parts
(everything between `.lilypond start' and `.lilypond end')
into temporary EPS-files that can be read by groff using `.PSPIC'.
See groff_lilypond(1)
EOF
}

foreach (@ARGV) {
    if (/(-v|--version)/) {
	&version;
	goto QUIT;
    } elsif (/(-h)|--help/) {
	&usage;
	goto QUIT;
    }
}


my $tempdir;
{
    my @tempdirs = ('/tmp', $ENV{'HOME'} . '/tmp');
    foreach (reverse @tempdirs) {
	if (-w) {
	    s<$></>;
	    s</+></>g;
	    my $sub = $_;
	    my $groff_tempdir = $sub . 'groff';
	    if (-e $groff_tempdir) {
		if (-w $groff_tempdir) {
		    $tempdir = $groff_tempdir;
		} else {
		    $tempdir = $sub;
		}
	    } else {
		if (mkdir $groff_tempdir, oct("0700")) {
		    $tempdir = $groff_tempdir;
		} else {
		    $tempdir = $sub;
		}
	    }
	    last;
	}
    }
}
$tempdir =~ s(/*$)(/);

my $file_time;
{
    use Time::HiRes qw[];
    (my $second, my $micro_second) = Time::HiRes::gettimeofday();
    $file_time = $second . $micro_second;
}

my $file_prefix = $tempdir . 'lilypond' . '_' . $file_time . '_';
my $file_number = 0;
my $file_numbered;
my $file_ly;

my $lilypond_mode = 0;

foreach (<>) {
    chomp;
    if (/^\.\s*lilypond\s+start/) {
	die "Line `.lilypond stop' expected." if ($lilypond_mode);
	$lilypond_mode = 1;
	$file_number++;
	$file_numbered = $file_prefix . $file_number;
	$file_ly =  $file_numbered . '.ly';
	open FILE_LY, ">", $file_ly or
	    die "cannot open .ly file: $!";
	next;
    } elsif (/^\.\s*lilypond\s+stop/) {
	die "Line `.lilypond start' expected." unless ($lilypond_mode);
	$lilypond_mode = 0;
	close FILE_LY;

	system "lilypond", "--pdf", "--output=$file_numbered", $file_ly and
	    die 'Program lilypond does not work.';
	# .pdf is added automatically
	system 'pdf2ps', $file_numbered . '.pdf', $file_numbered . '.ps' and
	    die 'Program pdf2ps does not work.';
	system 'ps2eps', $file_numbered . '.ps' and
	    die 'Program ps2eps does not work.';
	print '.PSPIC ' . $file_numbered  . '.eps' . "\n";

	next;
    } elsif ($lilypond_mode) {
	print FILE_LY $_ . "\n";
    } else {
	print $_ . "\n";
    }
}

unlink glob $file_prefix . "*.[a-df-z]*";

QUIT:
