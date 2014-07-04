#!/usr/bin/env perl

# groff ideal

# Source file position: <groff-source>/contrib/gideal/gideal.pl
# Installed position: <prefix>/bin/gideal

# Copyright (C) 2014
#   Free Software Foundation, Inc.

# Written by Bernd Warken <groff-bernd.warken-72@web.de>.

my $Latest_Update = '4 Jul 2014';
my $version = '0.9.5';

# This file is part of `gideal', which is part of `groff'.

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

use strict;
use warnings;

# temporary dir and files
use File::Temp qw/ tempfile tempdir /;

# needed for temporary dir
use File::Spec;

# for `copy' and `move'
use File::Copy;

# for fileparse, dirname and basename
use File::Basename;

# current working directory
use Cwd;

# $Bin is the directory where this script is located
use FindBin;

# for running the ideal parts with the `IS' and `I[EF]' programs and
# getting output also useful for shell programs
use IPC::System::Simple qw(capture capturex run runx system systemx);

# Perl package for complex numbers
use Math::Complex;


########################################################################
# system variables
########################################################################

$\ = "\n";    # adds newline at each print
$/ = "\n";    # newline separates input
$| = 1;       # flush after each print or write command


########################################################################
# read-only variables with double-@ construct
########################################################################

my $before_make;	# script before run of `make'
{
  my $at = '@';
  $before_make = 1 if '@VERSION@' eq "${at}VERSION${at}";
}

my %at_at;
my $gideal_dir;

if ($before_make) {
  my $gideal_source_dir = $FindBin::Bin;
  $at_at{'BINDIR'} = $gideal_source_dir;
  $at_at{'G'} = '';
} else {
  $at_at{'BINDIR'} = '@BINDIR@';
  $at_at{'G'} = '@g@';
}


########################################################################
# options
########################################################################

foreach (@ARGV) {
  if ( /^(-h|--h|--he|--hel|--help)$/ ) {
    print q(Usage for the `gideal' program:);
    print 'gideal [-] [--] [filespec...] normal file name arguments';
    print 'gideal [-h|--help]            gives usage information';
    print 'gideal [-v|--version]         displays the version number';
    print q(This program is a `groff' preprocessor that handles ideal ) .
      q(parts in `roff' files.);
    exit;
  } elsif ( /^(-v|--v|--ve|--ver|--vers|--versi|--versio|--version)$/ ) {
    print q(`gideal' version ) . $version . ' of ' . $Latest_Update;
    exit;
  }
}


#######################################################################
# temporary file
#######################################################################

my $out_file;
{
  my $template = 'gideal_' . "$$" . '_XXXX';
  my $tmpdir;
  foreach ($ENV{'GROFF_TMPDIR'}, $ENV{'TMPDIR'}, $ENV{'TMP'}, $ENV{'TEMP'},
           $ENV{'TEMPDIR'}, 'tmp', $ENV{'HOME'},
           File::Spec->catfile($ENV{'HOME'}, 'tmp')) {
    if ($_ && -d $_ && -w $_) {
      eval { $tmpdir = tempdir( $template,
                                CLEANUP => 1, DIR => "$_" ); };
      last if $tmpdir;
    }
  }
  $out_file = File::Spec->catfile($tmpdir, $template);
}


########################################################################
# input
########################################################################

my $nr = 0;
my @ideal;

my $ideal_mode = 0;
foreach (<>) {
  chomp;
  my $line = $_;
  my $is_start = $line =~ /^[.']\s*IS(|\s+.*)$/;	# start .IS
  my $is_end = $line =~ /^[.']\s*(I[EF])(|\s+.*)$/;	# stop .IE/.IF

  # .IE below ideal picture (after), .IF back at starting point (before)
  my $end_mode = $1;

  if ( $is_start ) {
    if ( $ideal_mode ) {
      print STDERR
	'Within a running ideal part, you called another .IS!';
      next;
    } else {	# new start
      $ideal_mode = 1;
      open OUT, '>', $out_file;
      @ideal = ();
      next;
    }
  }

  if ( $is_end ) {
    $ideal_mode = 0;
    close OUT;
    &do_ideal();
    next;
  }

  if ( $ideal_mode ) {	# normal `ideal' line, store in @ideal
    push @ideal, $line;
    next;
  } else {		# not related to `ideal', so print to STDOUT
    print $line;
    next;
  }
  next;
}


########################################################################
# &do_ideal()
########################################################################

sub do_ideal {
    $nr++;
    print '### ideal part number ' . $nr . ':';
    foreach (@ideal) {
      print $nr . '# ' . $_;
    }
    @ideal = ();
} # &do_ideal()


1;
########################################################################
### Emacs settings
# Local Variables:
# mode: CPerl
# End:
