#! /usr/bin/env perl
# grog - guess options for groff command
# Inspired by doctype script in Kernighan & Pike, Unix Programming
# Environment, pp 306-8.

# Source file position: <groff-source>/src/roff/grog/grog.pl
# Installed position: <prefix>/bin/grog

# Copyright (C) 1993, 2006, 2009, 2011-2012, 2014
#               Free Software Foundation, Inc.
# Written by James Clark, maintained by Werner Lemberg.
# Rewritten and put under GPL by Bernd Warken <groff-bernd.warken-72@web.de>.

# This file is part of `grog', which is part of `groff'.

# `groff' is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.

# `groff' is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see
# <http://www.gnu.org/licenses/gpl-2.0.html>.

########################################################################
our $Last_Update = '10 Jun 2014';
########################################################################

require v5.6;

use warnings;
use strict;

# $Bin is the directory where this script is located
use FindBin;

my $before_make;	# script before run of `make'
{
  my $at = '@';
  $before_make = 1 if '@VERSION@' eq "${at}VERSION${at}";
}


our %at_at;
my $file_perl_test_pl;
my $grog_dir;

if ($before_make) { # before installation
  my $grog_source_dir = $FindBin::Bin;
  $at_at{'BINDIR'} = $grog_source_dir;
  $grog_dir = $grog_source_dir;
  $file_perl_test_pl = File::Spec->catfile($grog_source_dir,
					   'perl_test.pl');
  my $top = $grog_source_dir . '/../../../';
  open FILE, '<', $top . 'VERSION' ||
    die 'Could not open top file VERSION.';
  my $version = <FILE>;
  chomp $version;
  close FILE;
  open FILE, '<', $top . 'REVISION' ||
    die 'Could not open top file REVISION.';
  my $revision = <FILE>;
  chomp $revision;
  $at_at{'GROFF_VERSION'} = $version . '.' . $revision;
} else { # after installation}
  $at_at{'GROFF_VERSION'} = '@VERSION@';
  $at_at{'BINDIR'} = '@BINDIR@';
  $grog_dir = '@grog_dir@';
  $file_perl_test_pl = File::Spec->catfile($grog_dir,
					   'perl_test.pl');
}

die "$grog_dir is not an existing directory;" unless -d $grog_dir;

unshift(@INC, $grog_dir);

require 'subs.pl';

our $Prog = $0;
{
  my ($v, $d, $f) = File::Spec->splitpath($Prog);
  $Prog = $f;
}


&minus_args();



foreach my $file ( @ARGV ) { # test for each file name in the arguments
  unless ( open(FILE, $file eq "-" ? $file : "< $file") ) {
    print STDERR "$Prog: can't open \`$file\': $!";
    next;
  }

  my $line = <FILE>;

  if ( defined $line ) {
    if ( $line ) {
      chomp $line;
      unless ( &do_first_line( $line, $file ) ) {	# not an option line
	&do_line( $line, $file );
      }
    } else {
      # empty first line
    }
  } else {	# empty file, go to next filearg
    close (FILE);
    next;
  }

  while (<FILE>) {
    chomp;
    &do_line( $_, $file );
  }
  close(FILE);

}

&make_groff_line();


1;
########################################################################
### Emacs settings
# Local Variables:
# mode: CPerl
# End:
