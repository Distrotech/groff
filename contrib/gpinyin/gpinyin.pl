#! /usr/bin/env perl

# gpinyin - European-like Chinese writing `pinyin' into `groff'

# Source file position: <groff-source>/contrib/gpinyin/gpinyin.pl
# Installed position: <prefix>/bin/gpinyin

# Copyright (C) 2014
#   Free Software Foundation, Inc.

# Written by Bernd Warken <groff-bernd.warken-72@web.de>.

my $Latest_Update = '8 Aug 2014';
my $version = '0.9.2';

# This file is part of `gpinyin', which is part of `groff'.

# `groff' is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.

# `groff' is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You can find a copy of the GNU General Public License in the internet
# at <http://www.gnu.org/licenses/gpl-2.0.html>.

########################################################################

use strict;
use warnings;
#use diagnostics;

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

# for running the perl parts with the `Perl' programs and getting output
# also useful for shell programs
use IPC::System::Simple qw(capture capturex run runx system systemx);


########################################################################
# system variables and exported variables
########################################################################

$\ = "\n";	# final part for print command

########################################################################
# read-only variables with double-@ construct
########################################################################

our $File_split_env_sh;
our $File_version_sh;
our $Groff_Version;

my $before_make;		# script before run of `make'
{
  my $at = '@';
  $before_make = 1 if '@VERSION@' eq "${at}VERSION${at}";
}

my %at_at;
my $file_gpinyin_test_pl;
my $groffer_libdir;

if ($before_make) {
  my $gpinyin_source_dir = $FindBin::Bin;
  $at_at{'BINDIR'} = $gpinyin_source_dir;
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
    print q(Usage for the `gpinyin' program:);
    print 'gpinyin [-] [--] [filespec...] normal file name arguments';
    print 'gpinyin [-h|--help]            gives usage information';
    print 'gpinyin [-v|--version]         displays the version number';
    print q(This program is a `groff' preprocessor that handles ) .
      q(pinyin parts in `roff' files.);
    exit;
  } elsif ( /^(-v|--v|--ve|--ver|--vers|--versi|--versio|--version)$/ ) {
    print q(`gpinyin' version ) . $version . ' of ' . $Latest_Update;
    exit;
  }
}


1;
########################################################################
### Emacs settings
# Local Variables:
# mode: CPerl
# End:
