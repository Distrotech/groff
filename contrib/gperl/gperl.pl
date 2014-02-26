#! /usr/bin/env perl

# gperl - add Perl part to groff files, this is the preprocessor for that

# Source file position: <groff-source>/contrib/gperl/gperl.pl
# Installed position: <prefix>/bin/gperl

# Copyright (C) 2014
#   Free Software Foundation, Inc.

# Written by Bernd Warken <groff-bernd.warken-72@web.de>.

# Last update: 27 Feb 2014
my $version = '1.0';

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
use IPC::System::Simple qw(system capture);


########################################################################
# system variables and exported variables
########################################################################

$\ = "\n";

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
# options
#######################################################################

foreach (@ARGV) {
  if ( /^(-h|--h|--he|--hel|--help)$/ ) {
    print 'usage:';
    print 'gperl [-h|--help]';
    print 'gperl [-v|--version]';
    exit;
  } elsif ( /^(-v|--v|--ve|--ver|--vers|--versi|--versio|--version)$/ ) {
    print 'gperl version ' . $version;
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
#######################################################################

my $perl_mode = 0;
my %set_cmd;

foreach (<>) {
  chomp;
  if ( /^[.']\s*Perl\s?/ ) { # .Perl ...
    my $res = &perl_request( $_ );

    if ( $res eq '' ) {
      print $_;
      next;
    }

    if ( $res eq 'start' ) {
      if ( $perl_mode ) {
	# `.Perl start' is called twice, ignore
      } else { # new Perl start
	$perl_mode = 1;
	open OUT, '>', $out_file;
      }
      next;
    } elsif ( $res eq 'stop' ) {
      close OUT;
      $perl_mode = 0;
      my $res = capture('perl',  $out_file);
      print $set_cmd{'command'} . ' ' . $set_cmd{'var'} . ' ' . $res
	if ( exists $set_cmd{'command'} );
      %set_cmd = ();
      next;
    }
  }

  if ( $perl_mode ) {
    print OUT $_;
    next;
  }

  print $_;
}


########################################################################

sub perl_request {
  my $line = shift;
  my @args = split /\s+/, $line;
  my $is_ds = 0;
  my $is_rn = 0;

  # 3 results:
  # '' : error
  # 'start'
  # 'stop'

  # arg must be a command line starting with .Perl
  return '' if ( $line !~ /^[.']\s*Perl/ );

  # different numbers of arguments

  shift @args; # ignore first argument `.Perl'

  return 'start' if ( @args == 0 ); # `.Perl' without args
  return 'start' if ( $args[0] eq 'start' );

  # now everything means `stop', but only within Perl mode
  return '' unless ( $perl_mode );

  if ( $args[0] eq 'stop' ) {
    shift @args; # remove `stop' arg
  }

  if ( @args <= 1 ) {
    # ignore single arg, variable name for possible ds or rn is lacking
    return 'stop';
  }

  # now >= 2 args for STDOUT result saving
  if ( $args[0] =~ /^[.']?ds$/ ) {
    $is_ds = 1;
    %set_cmd = (
	   'command' => $args[0],
	   'var' => $args[1],
	  );
  } elsif ( $args[0] =~ /^[.']?rn$/ ) {
    $is_rn = 1;
    %set_cmd = (
	   'command' => $args[0],
	   'var' => $args[1],
	  );
  } else {
    # ignore other args
    return 'stop';
  }

  $set_cmd{'command'} = '.' . $set_cmd{'command'}
    if ( $set_cmd{'command'} !~ /^[.']/ );

  return 'stop';
}


1;
########################################################################
### Emacs settings
# Local Variables:
# mode: CPerl
# End:
