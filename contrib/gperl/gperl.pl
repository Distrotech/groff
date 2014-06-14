#! /usr/bin/env perl

# gperl - add Perl part to groff files, this is the preprocessor for that

# Source file position: <groff-source>/contrib/gperl/gperl.pl
# Installed position: <prefix>/bin/gperl

# Copyright (C) 2014
#   Free Software Foundation, Inc.

# Written by Bernd Warken <groff-bernd.warken-72@web.de>.

my $Latest_Update = '14 Jun 2014';
my $version = '1.1';

# This file is part of `gperl', which is part of `groff'.

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

# for running perl scripts
use IPC::System::Simple qw(system systemx capture capturex);


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
my $file_perl_test_pl;
my $groffer_libdir;

if ($before_make) {
  my $gperl_source_dir = $FindBin::Bin;
  $at_at{'BINDIR'} = $gperl_source_dir;
  $at_at{'G'} = '';
} else {
  $at_at{'BINDIR'} = '@BINDIR@';
  $at_at{'G'} = '@g@';
}


########################################################################
# breaking options
########################################################################

foreach (@ARGV) {
  if ( /^(-h|--h|--he|--hel|--help)$/ ) {
    print q(Usage for the `gperl' program:);
    print 'gperl [-h|--help]     gives usage information';
    print 'gperl [-v|--version]  displays the version number';
    print q(This program is a `groff' preprocessor that handles Perl ) .
      q(parts in `roff' files.);
    exit;
  } elsif ( /^(-v|--v|--ve|--ver|--vers|--versi|--versio|--version)$/ ) {
    print q(`gperl' version ) . $version . ' of ' . $Latest_Update;
    exit;
  }
}


#######################################################################
# temporary file
#######################################################################

my $out_file;
{
  my $template = 'gperl_' . "$$" . '_XXXX';
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

my $perl_mode = 0;
my %set_cmd;

foreach (<>) {
  chomp;
  my $line = $_;
  my $is_dot_Perl = $line =~ /^[.']\s*Perl(|\s+.*)$/;

  unless ( $is_dot_Perl ) {	# not a `.Perl' line
    if ( $perl_mode ) {		# is running in Perl mode
      print OUT $line;
    } else {			# normal line, not Perl-related
      print $line;
    }
    next;
  }


  ##########
  # now the line is a `.Perl' line

  my $args = $line;
  $args =~ s/\s+$//;	# remove final spaces
  $args =~ s/^[.']\s*Perl\s*//;	# omit .Perl part, leave the arguments

  my @args = split /\s+/, $args;

  if ( @args == 0 || $args[0] eq 'start' ) {
    # for `.Perl' no args or first arg `start' means opening `Perl' mode
    if ( $perl_mode ) {
      # `.Perl' was started twice, ignore
      print STDERR q(`.Perl' starter was run several times);
      next;
    } else {	# new Perl start
      $perl_mode = 1;
      open OUT, '>', $out_file;
      next;
    }
  }

  ##########
  # now the line must be a Perl ending line (stop)

  unless ( $perl_mode ) {
    print STDERR 'gperl: there was a Perl ending without being in ' .
      'Perl mode.';
    next;
  }

  $perl_mode = 0;	# `Perl' stop calling is correct
  close OUT;		# close the storing of `Perl' commands

  ##########
  # run this `Perl' part, later on about storage of the result
  my $print_res = capturex('perl',  $out_file);

  shift @args if ( $args[0] eq 'stop' ); # remove `stop' arg if exists

  if ( @args == 0 ) {
    # no args for saving, so $print_res doesn't matter
    next;
  }

  # extract the now leading arg for saving mode
  my $save_mode = shift @args;

  if ( @args == 0 ) {
    # no args for saving variable name, so $print_res doesn't matter
    print STDERR 'gperl: a variable name for the saving mode ' .
      $save_mode . ' must be provided in the line:';
    print STDERR '    ' . $line;
    next;
  }

  my $command;

  # variable name for saving command the $print_res
  my $var_name = shift @args;
  # ignore all other args

  if ( $save_mode =~ /^\.?ds$/ ) {		# string
    $command = '.ds';
  } elsif ( $save_mode =~ /^\.?nr$/ ) {
    # Number registers do not work, just for compatibility.
    # Storage is done into a `groff' string variable
    $command = '.ds';
  } else {	# no storage variables provided
     print STDERR 'gperl: wrong argument ' . $save_mode .
       'in Perl stop line:';
     print STDERR '    ' . $line;
     print STDERR 'allowed are only .ds for storing a string or .nr ' .
       'for a number register';
     next;
  }

  $command .= ' ' . $var_name . ' ' . $print_res;
  print $command;
}


1;
########################################################################
### Emacs settings
# Local Variables:
# mode: CPerl
# End:
