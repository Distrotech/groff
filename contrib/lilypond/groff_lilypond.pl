#! /usr/bin/env perl

use strict;
# use warnings;


########################################################################
# legalese
########################################################################

my $Version = 'v0.4'; # version of groff_lilypond
my $LastUpdate = '23 Feb 2013';


my $License =    ### `$License' is the license for this file, `GPL' >= 3
'
groff_lilypond - integrate lilypond into groff files

Source file position: <groff-source>/contrib/lilypond/groff_lilypond.pl
Installed position: <prefix>/bin/groff_lilypond

Copyright (C) 2013 Free Software Foundation, Inc.
  Written by Bernd Warken <groff-bernd.warken-72@web.de>

This file is part of GNU groff.

  GNU groff is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

  GNU groff is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

  You should have received a copy of the GNU General Public License
along with groff, see the files COPYING and LICENSE in the top
directory of the groff source package.  If not, see
 http://www.gnu.org/licenses/>.

';

##### end legalese


########################################################################
# global variables
########################################################################

use File::Spec;
use File::Path qw[];
use Cwd qw[];


# `$IsInstalled' is 1 if groff is installed, 0 when in source package
my $IsInstalled = ( '@VERSION@' =~ /^[@]VERSION[@]$/ ) ? 0 : 1;


my $Prog = &get_prog_name;

my $GroffVersion = ''; # when not installed
$GroffVersion = '@VERSION@' if ( $IsInstalled ); # @...@ was replaced


# command line arguments
my $EpsMode = 'ly2eps'; # default
my $KeepFiles = 0;


my $TempDir = ''; # temporary directory
my $FilePrefix = 'ly'; # names of temporary files start with this

# read files or stdin
my $FilePrefix; # `$TempDir/ly_'
my $FileNumbered; # `$FilePrefix_[0-9]'
my $FileLy; # `$FileNumbered.ly'


# `§Cwd' stores the current directory
my $Cwd = Cwd::getcwd; # get current working directory

##### end global variables


########################################################################
# command line arguments
########################################################################

{
  my $double_minus = 0;
  my @FILES = ();

  my $has_arg = '';
  my $former_arg = ''; # for options with argument

 my $arg = ''; # needed here for subs

  my %only_minus = (
		    '-' => sub { push @FILES, '-'; },
		    '--' => sub { $double_minus = 1; },
		   );

  my @opt;

  $opt[2] = { # option abbreviations of 2 characters
	      '-h' => sub { &usage; exit; },               # `-h'
	      '-v' => sub { &version; exit; },             # `-v'
	     };


  $opt[3] = { # option abbreviations of 3 characters
	      '--f' => sub {                               # `--file_prefix'
		if ( $arg =~ /^.*=(.*)$/ ) { # opt arg is within $arg
		  $FilePrefix = $1;
		} else { # opt arg is the next command line argument
		  $has_arg = '--file_prefix';
		} # end if for `='
		next ARGS;
	      }, # end `--file_prefix'

	      '--h' => sub { &usage; exit; },               # `--help'
	      '--v' => sub { &version; exit; },             # `--version'
	      '--k' => sub { $KeepFiles = 1; next ARGS; },  # `--keep_files'
	      '--p' => sub { $EpsMode = 'pdf2eps'; next ARGS; }, # `--pdf2eps'

	      '--t' => sub {                                # `--temp_dir'
		if ( $arg =~ /^.*=(.*)$/ ) {
		  my $dir = $1;
		  $dir =~ s/^\s*(.*)\s*$/$1/;
		  my $res = &make_dir ( $dir ) or
		    die "The directory $dir cannot be used.\n";
		  $TempDir = $res;
		} else { # next command line argument is the option argument
		  $has_arg = '--temp_dir';
		} # end if for `='
		next ARGS;
	      }, # end sub of `--t'

	    }; # end `$opt[3]'


  $opt[4] = { # option abbreviations of 4 characters
	      '--li' => sub { &license; exit; },
	      '--ly' => sub { $EpsMode = 'ly2eps'; next ARGS; },
	     };

  sub check_arg { # is used in `ARGS forever
    # 2 arguments:
    # - content of $arg
    # - a number between 2 and 4
    my ( $arg, $n ) = @_;

    my $re = qr/^(.{$n})/;
    if ( $arg =~ $re ) {
      my $arg = $1;
      if ( exists $opt[ $n ]-> { $arg } ) {
	&{ $opt[ $n ] -> { $arg } };
	next ARGS; # for running `next'
      }
    }
  }


 ARGS: foreach (@ARGV) {
    chomp;
    s/^\s*(.*)\s*$/$1/;
    $arg = $_;

    if ( $has_arg ) {
      # only `--temp_dir' and `--file_prefix' expect an argument

      if ( $has_arg eq '--temp_dir' ) {
	my $dir = &make_dir ( $arg ) or
	  die "The directory $arg cannot be used.\n";

	$TempDir = $dir;
	$has_arg = '';
	next ARGS;
      }

      if ( $has_arg eq '--file_prefix' ) {
	$FilePrefix = $arg;
	$has_arg = '';
	next ARGS;
      }

      die "Wrong value for \$has_arg";
    }


    if ( $double_minus ) { # `--' was former arg
      push @FILES, $arg;
      next;
    } # file arg after --


    if ( $arg =~ /^[^-].*$/ ) { # arg is a file name without `-'
      push @FILES, $arg;
      next;
    }


    # now only args with starting '-'

    if ( exists $only_minus { $arg } ) {
      &{ $only_minus { $arg } };
      next;
    }

    # deal with @opt
    &check_arg ( $arg, $_ ) foreach ( qw[ 4 3 2 ] );


    # wrong argument
    print STDERR "Wrong argument for groff_lilypond: $_\n";
    next;


  } # end ARGS: foreach @ARGV


  if ( $has_arg ) {
    print STDERR "Option --temp_dir needs an argument.\n";
  }


  @ARGV = @FILES;


}

# end command line arguments


########################################################################
# temporary directory .../tmp/groff/USER/lilypond/TIME
########################################################################

unless ( "$TempDir" ) { # not given by `--temp_dir'

  my $home;
  {
    $home = $ENV{'HOME'};
    $home =~ s(/*$)(/tmp);
  }


  my $cwd;
  {
    $cwd = $Cwd; # current working directory
    $cwd =~ s(/*$)(/tmp);
  }


  my $user = $ENV{'USER'};
  {
    $user =~ s([\s/])()g;
  }


  use Time::HiRes qw[];


  { # search for or create a temporary directory

    my $path_extension = '/groff/';
    $path_extension .= $user. '/' if ($user);
    $path_extension .= 'lilypond/';


    my @temp_dirs = ('/tmp',  $home, $cwd);
    foreach (@temp_dirs) {

      my $dir_begin = $_ . $path_extension; # beginning of directory name
      my $dir_free = 0; # `1' when directory not exists, free for creating 
      my $dir; #final directory name in `until' loop

      until ( $dir_free ) {
	 $dir = $dir_begin . &dir_time;
	 if ( -d $dir ) {
	   Time::HiRes::usleep(1); # wait 1 microsecond
	 } else {
	   my $res = &make_dir( $dir );
	   $dir = $res;
	   $dir_free = 1;
	 }
      }

      next unless ( -d $dir && -w $dir  );

      $TempDir = $dir; # tmp/groff/USER/lilypond/TIME
      last;
    } # end foreach tmp directories
  } # end to create a temporary directory
} # end temporary directory
$TempDir =~ s(/*$)(/);

print STDERR "Temporary directory: $TempDir\n";


# end temporary directory


########################################################################
# read files or stdin
########################################################################

{ # read files or stdin
  my $ly_number = 0;
  my $lilypond_mode = 0;

  my $arg1 = ''; # first argument for `.lilypond'
  my $arg2 = ''; # argument for `.lilypond include'

  $FilePrefix = $TempDir . $FilePrefix . '_';

  my %lilypond_args = (

		       'start' => sub {
			 die "Line `.lilypond stop' expected."
			   if ($lilypond_mode);
			 $lilypond_mode = 1;
			 $ly_number++;
			 $FileNumbered = $FilePrefix . $ly_number;
			 $FileLy =  $FileNumbered . '.ly';
			 open FILELY, ">", $FileLy or
			   die "cannot open *.ly file: $!";
			 next LILYPOND;
		       },


		       'end' => sub {

			 die "Line `.lilypond start' expected."
			   unless ( $lilypond_mode );
			 $lilypond_mode = 0;
			 close FILELY;
			 &create_eps;
			 next LILYPOND;
		       },


		       'include' => sub { # `.lilypond include file...'

			 # this may not be used within lilypond mode
			 next LILYPOND if ( $lilypond_mode );

			 my $file = &check_file( $arg2 );
			 next LILYPOND unless ( $file );
			 # file can be read now

			 # FILELY must be opened
			 $ly_number++;
			 $FileNumbered = $FilePrefix . $ly_number;
			 $FileLy =  $FileNumbered . '.ly';

			 open FILELY, ">", $FileLy or
			   die "cannot open `$FileLy' file: $!";

			 open FILE, "<", $file                # for reading
			   or die "File `$file' could not be read: $!";
			 foreach (<FILE>) {
			   chomp;
			   print FILELY $_ . "\n";
			 }
			 close FILE;

			 close FILELY;
			 &create_eps;

			 next LILYPOND;
		       }, # end `.lilypond include'

		      ); # end definition %lilypond_args


  sub check_file { # for argument of `.lilypond include'
    my $file = shift;

    unless ( $file ) {
      print STDERR
	'Line ".lilypond include" without argument';
      return '';;
    }

    unless ( -f $file && -r $file ) {
      print STDERR 'Argument "' . $file .
	'" in ".lilypond include" ' .
	  'is not a readable file' . "\n";
      return '';
    }

    return $file;
  } # end sub check_file()


 LILYPOND: foreach (<>) {
    chomp;

    my $line = $_;


    # now the lines with '.lilypond ...'

    if ( /^[.']\s*lilypond\s*(.*)\s*(.*)\s*$/ ) { # .lilypond ...
      my $arg1 = $1;
      my $arg2 = $2;

      if ( exists $lilypond_args{ $arg1 } ) {
	& { $lilypond_args{ $arg1 } }

      } else {
	# not a suitable argument of `.lilypond'
	print $_ . "\n";
      }

      next LILYPOND;

    }

    if ( $lilypond_mode ) { # do lilypond-mode
      print FILELY $line . "\n" or # see `.lilypond start'
	die "could not print to FILELY in lilypond-mode\n";
      next LILYPOND;
    } # do lilypond-mode

    # unknown line without lilypond
    unless ( /^[.']\s*lilypond/ ) { # not a `.lilypond' line
      print $line . "\n"; # to STDOUT
      next LILYPOND;
    }


  } # end foreach <>
} # end read files or stdin


# Remove all temporary files except the eps files.
# With --keep_files, no files are removed.
unlink glob $FilePrefix . "*.[a-df-z]*" unless $KeepFiles;

# end read files and stdin


########################################################################
# subs
########################################################################

sub create_eps() {
  if ($EpsMode eq 'ly2eps') { # `--ly2eps'
    # `$ lilypond --ps -dbackend=eps -dgs-load-fonts
    #      output=file_without_extension file.ly'
    # extensions are added automatically
    system 'lilypond', '--ps', '-dbackend=eps', '-dinclude-eps-fonts',
      '-dgs-load-fonts', "--output=$FileNumbered", $FileLy
	and die 'Program lilypond does not work.';

    foreach (glob $FileNumbered . '-*' . '.eps') {
      print '.PSPIC ' . $_ . "\n";
    } # end foreach *.eps

  } elsif ($EpsMode eq 'pdf2eps') { # `--pdf2eps'
    # `$ lilypond --pdf --output=file_with_no_extension file.ly'
    # Extension .pdf is added automatically
    system "lilypond", "--pdf", "--output=$FileNumbered", $FileLy
      and die 'Program lilypond does not work.';
    # `$ pdf2ps file.pdf file.ps'
    system 'pdf2ps', $FileNumbered . '.pdf', $FileNumbered . '.ps'
      and die 'Program pdf2ps does not work.';
    # `$ ps2eps file.ps'
    system 'ps2eps', $FileNumbered . '.ps'
      and die 'Program ps2eps does not work.';

    # print into groff output
    print '.PSPIC ' . $FileNumbered  . '.eps' . "\n";

  } else {
    die "Wrong eps mode: $EpsMode";
  }
} # end sub create_eps()


sub dir_time() { # time and microseconds for temporary directory name
  my $res;
  my ( $sec, $min, $hour, $day_of_month, $month, $year,
       $weak_day, $day_of_year, $is_summer_time ) =
	 localtime( time() );

  $year += 1900;
  $month += 1;
  $month = '0' . $month if ( $month < 10 );
  $day_of_month = '0' . $day_of_month if ( $day_of_month < 10 );
  $hour = '0' . $hour if ( $hour < 10 );
  $min = '0' . $min if ( $min < 10 );
  $sec = '0' . $sec if ( $sec < 10 );

  $res = $year . '-' . $month . '-' . $day_of_month . '_';
  $res .= $hour . '-' . $min . '-' . $sec;

  (my $second, my $micro_second) = Time::HiRes::gettimeofday();
  $res .= '_' . $micro_second;
} # end sub dir_time(). time for temporary directory


sub get_prog_name {
  my ($v, $d, $f) = File::Spec->splitpath($0);
  return $f;
}


sub license {
  &version;
  print $License;
}


sub make_dir() { # make directory or check if exists
  my $arg = $_[0];
  $arg =~ s/^\s*(.*)\s*$/$1/;

  unless ( m<^/> ) { # starts not with `/', so it's not absolute
    my $cwd = $Cwd;
    chomp $cwd;

    die "Could not create directory $arg because current working " .
      "directory is not writable." unless ( -w $cwd );

    $cwd =~ s(/*$)(/);

    $arg = $cwd . $arg;
  }


  return 0 unless ( $arg );

  if ( -d $arg ) { # $arg is a directory
    return 0 unless ( -w $arg );
  } else { # $arg is not a directory
    if ( -e $arg ) { # $arg exists
      -w $arg && unlink $arg || die "could not delete " . $arg . ": $!";
    } # end of if, existing $arg

    File::Path::make_path( $arg, {mask=>oct('0700')}) #  `mkdir -P'
	or die "Could not create directory '$arg': $!";

  } # end if, else: not a directory
  return $arg;
} # end sub mike_dir()


sub usage { # for `--help'

  my $usage =
'
groff_lilypond [options] [--] [filename ...]

# breaking options:
groff_lilypond -h|--help               # usage
groff_lilypond -v|--version            # version information
groff_lilypond --license               # the license is GPL >= 3

Read a roff file or standard input and transform `lilypond' . "'" .
' parts
(everything between `.lilypond start' . "'" . 
' and `.lilypond end' . "'" . ') into
temporary EPS-files that can be read by groff using `.PSPIC' . "'" .
'.  There
is also a command (`.lilypond include file_name' . "'" .
') that can include a
complete lilypond file into the groff document.

There are 2 options for influencing the way how the EPS files for the
roff display are generated:
--pdf2eps       `lilypond' . "'" . ' generates a pdf file which is transformed
--ly2eps        `lilypond' . "'" . ' generates EPS files directly

--keep_files    do not delete any temporary files

Options with an argument:
--file_prefix=...   start for the names of temporary files
--temp_dir=...      provide the directory for temporary files (is created).
                    Directories must start with `/' . "'" .
', this is done by the option.

'; print $usage;

} # end sub usage()


sub version { # for `--version'
    print $Prog . " version " . $Version . " of " . $LastUpdate .
	" is part of GNU groff";
    if ( $GroffVersion ) {
      print "\n version " . $GroffVersion . "\n";
    } else  {
      print ".\n";
    }
} # end sub version()


# end subs


########################################################################
# leaving file
########################################################################

QUIT:


########################################################################
### Emacs settings
# Local Variables:
# mode: CPerl
# End:
