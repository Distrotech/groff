#! /usr/bin/env perl

# groff_lilypond - integrate lilypond into groff files

# Source file position: <groff-source>/contrib/lilypond/groff_lilypond.pl
# Installed position: <prefix>/bin/groff_lilypond

# Copyright (C) 2013 Free Software Foundation, Inc.
# Written by Bernd Warken <groff-bernd.warken-72@web.de>.

# Last update: 12 Feb 2013

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

my $version = 'v0.3';

# for temporary directories see @tempdirs

my $eps_mode = 'ly2eps';
{
    my $minus_minus = 0;
    my @FILES = ();
    foreach (@ARGV) {
	if ($minus_minus) {
	    push @FILES, $_;
	    next;
	}
	if (/^--$/) { # argument `--'
	    $minus_minus = 1;
	    next;
	} elsif (/^(-|[^-].*)$/) { # argument `-' or file name
	    push @FILES, $_;
	    next;
	} elsif (/^(-v|--version).*$/) {
	    &version;
	    goto QUIT;
	} elsif (/^(-h|--help).*$/) {
	    &usage;
	    goto QUIT;
	} elsif (/^--pdf2eps.*$/) {
	    $eps_mode = 'pdf2eps';
	    shift;
	} elsif (/^--ly2eps.*$/) {
	    $eps_mode = 'ly2eps';
	    shift;
	} else {
	    die "wrong argument for groff_lilypond: $_";
	}
    }
    @ARGV = @FILES;
}

my $dir_time;
{
    $dir_time = localtime(time());
    $dir_time =~  tr/: /_/;

    use Time::HiRes qw[];
    (my $second, my $micro_second) = Time::HiRes::gettimeofday();

    $dir_time = $dir_time . '_' . $micro_second;
}

my $tempdir;
{
    use File::Path qw[];

    use Cwd qw[];
    my $cwd = Cwd::getcwd();
    $cwd =~ s(/*$)(/tmp);

    my $home = $ENV{'HOME'};
    $home =~ s(/*$)(/tmp);

    my @tempdirs = ('/tmp',  $home, $cwd);
    foreach (@tempdirs) {
	if (-e $_) {   # exists
	    if (-d) {  # is directory
		next unless (-w $_);   # not writable
	    }
	} else {       #  does not exist
	    File::Path::make_path $_, {mask=>oct('0700')} or next;
	}
	# directory $_ exists and is writable
	my $dir = $_;
	$dir =~ s(/+)(/)g;
	$dir =~ s(/*$)(/groff);
	if (-e $dir) {     # exists
	    next unless (-d $dir); # if no dir
	    next unless (-w $dir); # if not writable
	} else {
	    File::Path::make_path $dir, {mask=>oct('0700')} or next;
	}

	$dir =~ s(/*$)(/$dir_time);
	File::Path::make_path $dir, {mask=>oct('0700')} or next;
	not -e $dir or not -d $dir or not -w $dir and next;

	$tempdir = $dir; # tmp/groff/time
	last;
    }
}
$tempdir =~ s(/*$)(/);

my $file_prefix = $tempdir . 'ly' . '_';
my $ly_number = 0;
my $file_numbered;

my $file_ly;
my $lilypond_mode = 0;

foreach (<>) {
    chomp;
    if (/^(\.\s*lilypond\s+include)(.*$)/) { # `.lilypond include file...'
	my $args = $2;
	$args =~ s/\s*$//;
	my @files = ();
	while ($args) {
	    if ($args =~ /^\s+"([^"]+)"(.*)$/) { # ` "file name"...'
		push @files, $1;
		$args = $2;
	    } elsif ($args =~ /^\s+'([^']+)'(.*)$/) { # ` 'file name'...'
		push @files, $1;
		$args = $2;
	    } elsif ($args =~ /^\s+(\S+)(.*)$/) { # ` filename...'
		push @files, $1;
		$args = $2;
	    }
	}
	unless ($lilypond_mode) { # then FILE_LY must be opened
	    $ly_number++;
	    $file_numbered = $file_prefix . $ly_number;
	    $file_ly =  $file_numbered . '.ly';

	    open FILE_LY, ">", $file_ly or
		die "cannot open .ly file: $!";
	}

	foreach (@files) { # included .ly files
	    my $file = $_;
	    unless ($file) {
		print STDERR "Empty file name at `.lilypond include'\n";
		next;
	    }
	    unless (-e $file) {
		print STDERR
		    "File `$file' at `.lilypond include' does not exist.\n";
		next;
	    }
	    unless (-r $file) {
		print STDERR
		    "File `$file' at `.lilypond include' is not readable.\n";
		next;
	    }

	    open FILE, "<", "$file" # for reading
		or die "file `$file' could not be read: $!";
	    foreach (<FILE>) {
		chomp;
		print FILE_LY $_ . "\n";
	    }
	    close FILE;
	}
	unless ($lilypond_mode) {
	    close FILE_LY;
	    &create_eps;
	}
    } elsif (/^\.\s*lilypond\s+start/) { # `.lilypond start'
	die "Line `.lilypond stop' expected." if ($lilypond_mode);
	$lilypond_mode = 1;
	$ly_number++;
	$file_numbered = $file_prefix . $ly_number;
	$file_ly =  $file_numbered . '.ly';
	open FILE_LY, ">", $file_ly or
	    die "cannot open .ly file: $!";
	next;
    } elsif (/^\.\s*lilypond\s+stop/) { # `.lilypond stop'
	die "Line `.lilypond start' expected." unless ($lilypond_mode);
	$lilypond_mode = 0;
	close FILE_LY;
	&create_eps;
	next;
    } elsif ($lilypond_mode) {
	print FILE_LY $_ . "\n";
    } else {
	print $_ . "\n";
    }
}

# unlink glob $file_prefix . "*.[a-df-z]*";

sub create_eps() {
    if ($eps_mode =~ /^pdf2eps$/) { # `--pdf2eps'
	# `$ lilypond --pdf --output=file_with_no_extension file.ly'
	# .pdf is added automatically
	system "lilypond", "--pdf", "--output=$file_numbered", $file_ly
	    and die 'Program lilypond does not work.';
	# `$ pdf2ps file.pdf file.ps'
	system 'pdf2ps', $file_numbered . '.pdf', $file_numbered . '.ps'
	    and die 'Program pdf2ps does not work.';
	# `$ ps2eps file.ps'
	system 'ps2eps', $file_numbered . '.ps'
	    and die 'Program ps2eps does not work.';

	# print into groff output
	print '.PSPIC ' . $file_numbered  . '.eps' . "\n";
    } elsif ($eps_mode =~ /^ly2eps$/) { # `--ly2eps'
	# `$ lilypond --ps -dbackend=eps -dgs-load-fonts
	#      output=file_without_extension file.ly'
	# extensions are added automatically
	system 'lilypond', '--ps', '-dbackend=eps',
	'-dgs-load-fonts', "--output=$file_numbered", $file_ly
	    and die 'Program lilypond does not work.';

	foreach (glob $file_numbered . '-*' . '.eps') {
	    print '.PSPIC ' . $_ . "\n";
	}

    } else {
	die "Wrong eps mode: $eps_mode";
    }
}

sub version {
    print "groff_lilypond version $version is part of groff\n";
}

sub usage {
    print <<EOF
groff_lilypond [options] [filename]
groff_lilypond -h|--help
groff_lilypond -v|--version
Read a roff file or standard input and transform `lilypond' parts
(everything between `.lilypond start' and `.lilypond end')
into temporary EPS-files that can be read by groff using `.PSPIC'.
Options are
--pdf2eps
--ly2eps
for influencing the way how the EPS files for roff display are generated.
EOF
}


QUIT:
