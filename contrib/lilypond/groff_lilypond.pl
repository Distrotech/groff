#! /usr/bin/env perl

use strict;
use 5.10.0;

# use warnings;



########################################################################
# legalese
########################################################################

{
  package main;
  use strict;

  use vars '$VERSION';
  $VERSION = 'v0.5'; # version of groff_lilypond

  $main::last_update = '03 Mar 2013';

  ### This `$License' is the license for this file, `GPL' >= 3
  $main::License = q*
groff_lilypond - integrate `lilypond' into `groff' files

Source file position: `<groff-source>/contrib/lilypond/groff_lilypond.pl'
Installed position: `<prefix>/bin/groff_lilypond'

Copyright (C) 2013 Free Software Foundation, Inc.
  Written by Bernd Warken <groff-bernd.warken-72@web.de>

This file is part of `GNU groff'.

  `GNU groff' is free software: you can redistribute it and/or modify it
under the terms of the `GNU General Public License' as published by the
`Free Software Foundation', either version 3 of the License, or (at your
option) any later version.

  `GNU groff' is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the `GNU
General Public License' for more details.

  You should have received a copy of the 'GNU General Public License`
along with `groff', see the files `COPYING' and `LICENSE' in the top
directory of the `groff' source package.  If not, see
<http://www.gnu.org/licenses/>.
*;

##### end legalese


########################################################################
# global variables
########################################################################

  use File::Spec qw[];
  use File::Path qw[];
  use Time::HiRes qw[];

  use constant FALSE => 0;
  use constant TRUE => 1;
  use constant EMPTYSTRING => '';
  use constant EMPTYARRAY => ();
  use constant EMPTYHASH => ();

  $main::at_version_at = '@VERSION@'; # @...@ is replaced for the installation

  # `$prog_is_installed' is TRUE if groff is installed,
  # FALSE when in source package
  $main::prog_is_installed = ( $main::at_version_at =~ /^[@]VERSION[@]$/ )
    ? FALSE : TRUE;

  {
    ( my $v, my $d, $main::prog) = File::Spec->splitpath($0);
  }
  # is `groff_lilypond' when installed, `groff_lilypond.pl' when not

  $main::groff_version = $main::prog_is_installed
    ? $main::at_version_at : main::EMPTYSTRING;


  $\ = "\n"; # adds newline at each print


  $main::fh_verbose; # file handle only for `--verbose'
  $main::fh_out; # file handle for `--output'
} # end of package `main'

##### end global variables


########################################################################
# command line arguments
########################################################################

{
  package Args;
  use strict;

  # command line arguments
  $Args::keep_files = main::FALSE;

  # default `--ly2eps', another `--pdf2eps'
  $Args::eps_func = 'ly2eps';

  $Args::temp_dir = main::EMPTYSTRING; # temporary directory
  # can be overwritten by `--temp_dir'

  $Args::file_prefix = 'ly';
  # names of temporary files in $main::TempDir start with this string
  # can be overwritten by `--file_prefix'

  $Args::verbose = main::FALSE;
  $Args::output = $1;


  my $double_minus = main::FALSE;
  my @args = main::EMPTYARRAY;

  {
    my %single_opts =
      (
       'h' => main::FALSE,
       'o' => main::TRUE, # has argument
       'v' => main::FALSE,
       'V' => main::FALSE,
      );

    my @splitted_args;


  SINGLE: foreach (@ARGV) {

      if ( $double_minus ) {
	push @splitted_args, $_;
	next SINGLE;
      }

      s/^\s*(.*)\s*$/$1/; # remove leading and final spaces

      if ( /^--$/ ) { # `--'
	push @splitted_args, $_;
	$double_minus = main::TRUE;
	next SINGLE;
      }

      if ( /^--/ ) {
	if ( /=/ ) { # `--opt' with `=' for arg
	  /^([^=]*)=(.*)$/;
	  push @splitted_args, $1;
	  push @splitted_args, $2;
	  next SINGLE;
	}
	push @splitted_args, $_;
	next SINGLE;
      }

      if ( /^-([^-].*)$/ ) { # single minus
	my @chars = split //, $1;
	while ( @chars ) {
	  my $c = shift @chars;
	  if ( exists $single_opts{ $c } ) {
	    push @splitted_args, "-" . $c;
	    next SINGLE unless ( $single_opts{ $c } ); # opt without arg

	    # single opt with arg
	    my $opt_arg = join '', @chars;
	    push @splitted_args, $opt_arg;
	    @chars = main::EMPTYARRAY;
	    next SINGLE
	  } else { # not in %single_opts
	    print STDERR "Unknown option `-$c'";
	 }
	}
      }

      push @splitted_args, $_;
      next SINGLE;
    }

    @ARGV = @splitted_args;

  }
  $double_minus = main::FALSE;


  # arguments are splitted


  my $has_arg;
  my $arg;
  my $former_arg;
  my $exit = main::FALSE;
  my @files;


  my %only_minus =
  (
   '-' => sub { push @files, '-'; },
   '--' => sub { push @args, '--'; $double_minus = main::TRUE; },
  );


  my @opt;

  $opt[2] =
    { # option abbreviations of 2 characters

     '-h' => sub {
       &Subs::usage;
       push @args, '--help';
       $exit = main::TRUE;
     }, # `-h'

     '-o' => sub { # `-o'
       $has_arg = '--output';
       $former_arg = $has_arg;
       next ARGS;
     },

     '-v' => sub { # `-v'
       &Subs::version;
       push @args, '--version';
       $exit = main::TRUE;
       next ARGS;
     },

     '-V' => sub { # `-V'
       $Args::verbose = main::TRUE;
       push @args, '--verbose';
       next ARGS;
     },

    };


  $opt[3] =
    { # option abbreviations of 3 characters

     '--f' => sub { # `--file_prefix'
       $has_arg = '--file_prefix';
       $former_arg = $has_arg;
       next ARGS;
     }, # end `--file_prefix'

     '--h' => sub { # `--help'
       &Subs::usage;
       push @args, '--help';
       $exit = main::TRUE;
     },

     '--k' => sub { # `--keep_files'
       $Args::keep_files = main::TRUE;
       push @args, '--keep_files';
       next ARGS;
     },

     '--o' => sub { # `--output'
       # next command line argument is the option argument
       $has_arg = '--output';
       $former_arg = $has_arg;
       next ARGS;
     }, # end sub of `--o'

     # `--pdf2eps'
     '--p' => sub {
       $Args::eps_func = 'pdf2eps';
       push @args, '--pdf2eps';
       next ARGS;
     },

     '--t' => sub { # `--temp_dir'
       # next command line argument is the option argument
	 $has_arg = '--temp_dir';
	 $former_arg = $has_arg;
	 next ARGS;
       }, # end sub of `--t'

     '--u' => sub {
       &Subs::usage;
       push @args, '--help';
       $exit = main::TRUE;
     }, # `--usage'

     '--V' => sub { # `--Verbose'
       $Args::verbose = main::TRUE;
       push @args, '--verbose';
       next ARGS; },

   }; # end `$opt[3]'


  $opt[4] =
    { # option abbreviations of 4 characters

     '--li' => sub { # `--license'
       &Subs::license;
       push @args, '--license';
       $exit = main::TRUE;
     },

     '--ly' => sub { # `--ly2eps'
       $Args::eps_func = 'ly2eps';
       push @args, '--ly2eps';
       next ARGS;
     },
   };


  $opt[6] =
    { # option abbreviations of 6 characters

     '--verb' => sub { # `--verbose'
       $Args::verbose = main::TRUE;
       push @args, '--verbose';
       next ARGS;
     },

     '--vers' => sub { # `--version'
       &Subs::version;
       push @args, '==version';
       $exit = main::TRUE;
     },

   };


  # for optarg that is a complete argument
  my $arg_is_optarg =
    {

     '--file_prefix' => sub {
       $Args::file_prefix = $arg;
     },

     '--output' => sub {
       die "file name expected for option `--output'"
	 unless ( $arg );
       $Args::output = $arg;
     },

     '--temp_dir' => sub {
       $Args::temp_dir = $arg;
     },

    };


  my $check_arg = sub { # is used in `ARGS:' foreach
    # 2 arguments:
    # - content of $arg
    # - a number of 2, 3, 4, or 6
    my ( $from_arg, $n ) = @_;

    my $re = qr/^(.{$n})/;
    if ( $from_arg =~ $re ) {
      $from_arg = $1;
      if ( exists $opt[ $n ]-> { $from_arg } ) {
	&{ $opt[ $n ] -> { $from_arg } };
	next ARGS;
      } # end exists
    } # end match $n characters
  }; # end sub check_args()


 ARGS: foreach ( @ARGV ) {
    chomp;
    s/^\s*(.*)\s*$/$1/;
    $arg = $_;

    # former option needs this argument as optarg
    if ( exists $arg_is_optarg -> { $has_arg } ) {
      &{ $arg_is_optarg -> { $has_arg } };
      push @args, $former_arg . " " . $arg;
      $has_arg = main::EMPTYSTRING;
      $former_arg = main::EMPTYSTRING;
      next ARGS;
    }


    if ( $double_minus  # `--' was former arg
      or $arg =~ /^[^-].*$/ ) { # arg is a file name without `-'
	push @files, $arg;
	next ARGS;
      } # after integration of file arg


    # now only args with starting '-'

    if ( exists $only_minus{ $arg } ) {
      &{ $only_minus{ $arg } };
      next ARGS;
    }

    # deal with @opt
    &$check_arg( $arg, $_ ) foreach ( qw[ 6 4 3 2 ] );


    # wrong argument
    print STDERR "Wrong argument for groff_lilypond: `$arg'";
    next ARGS;


  } # end ARGS: foreach @ARGV


  if ( $has_arg ) { # after last argument
    die "Option `$has_arg' needs an argument.";
  }


  # install `$main::fh_verbose'
  if ( $Args::verbose ) { # `--verbose' was used
    # make verbose output, i.e. make `$main::fh_verbose' visible
    $main::fh_verbose = *STDERR;

  } else { # `--verbose' was not used
    # do not be verbose, make `$main::fh_verbose' invisible, e.g. either
    # in /dev/null or in a string

    my $opened = main::FALSE;
    my $null = '/dev/null';

    if ( -e $null && -w $null ) {
      open $main::fh_verbose, ">", $null or
	die "Could not open `$null': $!";

      # `/dev/null' will now be used for verbose output
      $opened = main::TRUE;
    }

    unless ( $opened ) { # couldn't use /dev/null, so print into a string
      my $print_to_string;
      open $main::fh_verbose, ">", \ $print_to_string or
	die "Could not open `\$main::fh_verbose': $!";

      # now verbose output will go into a string, which is ignored
    }
  } # if-else about verbose
  # $main::fh_verbose is now active


  {
    my $s = $main::prog_is_installed ? '' : ' not';
    print $main::fh_verbose "$main::prog is$s installed.";
    print $main::fh_verbose 'The command line options are:';
    print $main::fh_verbose "  @args";
    print $main::fh_verbose "files: @files";
  }


  exit if ( $exit );


  if ( $Args::output ) {
    open $main::fh_out, ">", $Args::output or
      die "could not write to `$Args::output': $!";
  } else {
    $main::fh_out = *STDOUT;
  }


  $Args::file_prefix .= '_' . $Args::eps_func;


  @ARGV = @files;


}

# end package `Args'


########################################################################
# temporary directory .../tmp/groff/USER/lilypond/TIME
########################################################################

{
  package Temp;
  use strict;

  use Cwd qw[];
  # `$Cwd' stores the current directory
  ( $Temp::Cwd = Cwd::getcwd ) =~ s</*$></>; # add final slash


  if ( $Args::temp_dir ) { # temporary directory was set by `--temp_dir'
    my $dir = $Args::temp_dir;

    unless ( $dir =~ m<^/> ) { # not starting with a slash
      $dir = $Temp::Cwd . $dir;
    }

    # now $dir starts with a slash

    $dir =~ s{/*$}{/};
    if ( -e $dir ) {
      die "Could not write to temporary directory: $dir"
	unless ( -w $dir );
      unless ( -d $dir ) {
	unlink $dir;
	die "Could not remove $dir" if ( -e $dir );
      }
    }

    if ( -d $dir ) { # is a directory
      my $files = glob $dir . $Args::file_prefix . "_*";
      $Args::file_prefix .= "_" . &Subs::dir_time if ( $files );
    } else { # not a directory
      my $dir = &Subs::make_dir ( $dir ) or
	die "The directory $dir cannot be used.";
    }

    $Args::temp_dir = $dir;


  } else { # $Args::temp_dir not given by `--temp_dir'

    { # search for or create a temporary directory

      my $path_extension = 'groff/';
      {
	( my $user = $ENV{ 'USER' } ) =~ s([\s/])()g;
	$path_extension .= $user. '/' if ($user);
      }
      $path_extension .= 'lilypond/';


      ( my $home = $ENV{'HOME'} ) =~ s(/*$)(/);

    TEMPS: foreach ( '/', $home, $Temp::Cwd ) {
	# temorary dirs by appending `tmp/'

	# beginning of directory name
	my $dir_begin = $_ . 'tmp/' . $path_extension;

	# `TRUE' when dir doesn't exist, free for creating
	my $dir; # final directory name in `until' loop

	my $dir_blocked = main::TRUE;
      BLOCK: while ( $dir_blocked ) {
	  # should become the final dir name
	  $dir = $dir_begin . &Subs::dir_time;
	  if ( -d $dir ) { # dir exists, so wait
	    Time::HiRes::usleep(1); # wait 1 microsecond
	    next BLOCK;
	  }

	  # dir name is now free, create it, and end the blocking
	  my $res = &Subs::make_dir( $dir );
	  die "Could not create directory: $dir" unless ( $res );

	  $dir = $res;
	  $dir_blocked = main::FALSE;
	}

	next TEMPS unless ( -d $dir && -w $dir  );

	$Args::temp_dir = $dir; # tmp/groff/USER/lilypond/TIME
	last TEMPS;
      } # end foreach tmp directories
    } # end to create a temporary directory

    $Args::temp_dir =~ s(/*$)(/);

  } # end temporary directory

  print $main::fh_verbose "Temporary directory: `$Args::temp_dir'";
  print $main::fh_verbose "file_prefix: `$Args::file_prefix'";

}

# end package `Temp'


########################################################################
# read files or stdin
########################################################################

{ # read files or stdin

  package Read;
  use strict;

  my $ly_number = 0; # number of lilypond file

  # `$Args::file_prefix_[0-9]'
  $Read::file_numbered = main::EMPTYSTRING;
  $Read::file_ly = main::EMPTYSTRING; # `$file_numbered.ly'

  my $lilypond_mode = main::FALSE;

  my $arg1; # first argument for `.lilypond'
  my $arg2; # argument for `.lilypond include'


  my $check_file = sub { # for argument of `.lilypond include'
    my $file = shift;
    unless ( $file ) {
	die "Line `.lilypond include' without argument";
      return '';;
    }
    unless ( -f $file && -r $file ) {
      die "Argument `$file' in `.lilypond include' is not a readable file";
      return main::EMPTYSTRING;
    }
    return $file;
  }; # end sub &$check_file()


  my $increase_ly_number = sub {
    ++$ly_number;
    $Read::file_numbered = $Args::file_prefix . '_' . $ly_number;
    $Read::file_ly =  $Read::file_numbered . '.ly';
  };


  my %eps_subs = (
		  'ly2eps' => \&Subs::create_ly2eps,
		  'pdf2eps' => \&Subs::create_pdf2eps,
		 );

  # about lines starting with `.lilypobnd'

  my $fh_write_ly;
  my $fh_include_file;
  my %lilypond_args =
    (

     'start' => sub {
       print $main::fh_verbose "line: `.lilypond start'";
       die "Line `.lilypond stop' expected." if ( $lilypond_mode );

       $lilypond_mode = main::TRUE;
       &$increase_ly_number;

       print $main::fh_verbose
	 "ly-file: `" . $Args::temp_dir . $Read::file_ly . "'";

       open $fh_write_ly, ">", $Args::temp_dir . $Read::file_ly or
	 die "Cannot open file `$Args::temp_dir$Read::file_ly': $!";
       next LILYPOND;
     },


     'end' => sub {
       print $main::fh_verbose "line: `.lilypond end'";
       die "Expected line `.lilypond start'." unless ( $lilypond_mode );

       $lilypond_mode = main::FALSE;
       close $fh_write_ly;

       if ( exists $eps_subs{ $Args::eps_func } ) {
	 $eps_subs{ $Args::eps_func } -> ();
       } else {
	 die "Wrong argument for \%eps_subs: $Args::eps_func";
       }
       next LILYPOND;
     },


     'include' => sub { # `.lilypond include file...'

       # this may not be used within lilypond mode
       next LILYPOND if ( $lilypond_mode );

       my $file_arg = shift;

       my $file = &$check_file( $file_arg );
       next LILYPOND unless ( $file );
       # file can be read now

       # `$fh_write_ly' must be opened
       &$increase_ly_number;

       open $fh_write_ly, ">", $Args::temp_dir . $Read::file_ly or
	   die "Cannot open file `$Read::file_ly': $!";

       open $fh_include_file, "<", $file # for reading
	 or die "File `$file' could not be read: $!";
       foreach (<$fh_include_file>) {
	 chomp;
	 print $fh_write_ly $_;
       }
       close $fh_include_file;

       close $fh_write_ly;
       if ( exists $eps_subs{ $Args::eps_func } ) {
	 $eps_subs{ $Args::eps_func } -> ();
       } else {
	 die "Wrong argument for \$eps_subs: $Args::eps_func";
       }

       next LILYPOND;
     }, # end `.lilypond include'

    ); # end definition %lilypond_args



 LILYPOND: foreach (<>) {
    chomp;
    my $line = $_;


    # now the lines with '.lilypond ...'

    if ( /^[.']\s*lilypond(.*)$/ ) { # .lilypond ...
      my $args = $1;
      $args =~ s/^\s*//;
      $args =~ s/\s*$//;
      $args =~ s/^(\S*)\s*//;
      my $arg1 = $1; # `start', `end' or `include'
      $args =~ s/["'`]//g;
      my $arg2 = $args; # file argument for `.lilypond include'

      if ( exists $lilypond_args{ $arg1 } ) {
	$lilypond_args{ $arg1 } -> ( $arg2 );

      } else {
	# not a suitable argument of `.lilypond'
	print STDERR "Unknown command: `$arg1' `$arg2':  `$_'";
      }

      next LILYPOND;
    } # end if .lilypond


    if ( $lilypond_mode ) { # do lilypond-mode
      print $fh_write_ly $line or # see `.lilypond start'
	die "could not print to \$fh_write_ly in lilypond-mode";
      next LILYPOND;
    } # do lilypond-mode

    # unknown line without lilypond
    unless ( /^[.']\s*lilypond/ ) { # not a `.lilypond' line
      print $main::fh_out $line;
      next LILYPOND;
    }

  } # end foreach <>
} # end package Read


########################################################################
# clean up
########################################################################

{
  package Clean;
  use strict;


  # With --keep_files, no temporary files are removed.
  if ( $Args::keep_files ) {
    print $main::fh_verbose "keep_files: `TRUE'";
    print $main::fh_verbose "No temporary files will be deleted:";

    opendir my $dh_temp, $Args::temp_dir or
      die "Cannot open $Args::temp_dir: $!";

    for ( sort readdir $dh_temp ) {
      next if ( /^\./ );
      my $prefix  = $Args::file_prefix . '_';
      my $re = qr/^$prefix/;
      if ( $_ =~ $re ) {
	print $main::fh_verbose "- " . $Args::temp_dir . $_;
	next;
      }
      next;
    }

    closedir $dh_temp;
  } else {
    # Remove all temporary files except the eps files.
    print $main::fh_verbose "keep_files: `FALSE'";
    print $main::fh_verbose
      "All temporary files except *.eps will be deleted";

    unlink glob $Args::temp_dir . $Args::file_prefix . "*.[a-df-zA-Z0-9]*";
    unlink glob $Args::temp_dir . $Args::file_prefix . "_temp*";
  }


  close $main::fh_out unless ( $main::fh_out =~ /STD/ );
  close $main::fh_verbose unless ( $main::fh_verbose =~ /STD/ );


  exit; # jump over Subs

} # end package Clean


########################################################################
# subs for using several times
########################################################################
{
  package Subs;
  use strict;

  sub create_ly2eps { # `--ly2eps' default
    my $prefix = $Read::file_numbered; # with dir change to temp dir

    # `$ lilypond --ps -dbackend=eps -dgs-load-fonts \
    #      output=file_without_extension file.ly'
    # extensions are added automatically
    my $opts = '--ps -dbackend=eps -dinclude-eps-fonts -dgs-load-fonts ' .
      "--output=$prefix $prefix";
    &Subs::run_lilypond("$opts");

    chdir $Temp::Cwd or
      die "Could not change to former directory `$Temp::Cwd': $!";

    foreach ( glob $Args::temp_dir . $prefix . '-*' . '.eps' ) {
      print $main::fh_out '.PSPIC ' . $_;
    } # end foreach
  }

  sub create_pdf2eps { # `--pdf2eps'
    my $prefix = $Read::file_numbered; # with dir change to temp dir

    &Subs::run_lilypond("--pdf --output=$prefix $prefix");

    my $file_pdf = $prefix . '.pdf';
    my $file_ps = $prefix . '.ps';

    # pdf2ps in temp dir
    my $temp_file = &Subs::next_temp_file;
    print $main::fh_verbose "\n##### run of `pdf2ps'";
    # `$ pdf2ps file.pdf file.ps'
    my $output = `pdf2ps $file_pdf $file_ps 2> $temp_file`;
    die 'Program pdf2ps does not work.' if ( $? );
    &Subs::shell_handling ( $output, $temp_file );
    print $main::fh_verbose "##### end run of `pdf2ps'\n";

    # ps2eps in temp dir
    $temp_file = &Subs::next_temp_file;
    print $main::fh_verbose "\n##### run of `ps2eps'";
    # `$ ps2eps file.ps'
    $output = `ps2eps $file_ps 2> $temp_file`;
    die 'Program ps2eps does not work.' if ( $? );
    &shell_handling ( $output, $temp_file );
    print $main::fh_verbose "##### end run of `ps2eps'\n";

    # change back to former dir
    chdir $Temp::Cwd or
      die "Could not change to former directory `$Temp::Cwd': $!";

    # handling of .eps file
    my $file_eps = $Args::temp_dir . $prefix . '.eps';
    # print into groff output
    print $main::fh_out '.PSPIC ' . $file_eps;
  }

  sub dir_time { # time and microseconds for temporary directory name
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

  sub license {
    &version;
    print STDOUT $main::License;
  }

  sub make_dir { # make directory or check if exists
    my $arg = shift;
    $arg =~ s/^\s*(.*)\s*$/$1/;

    unless ( $arg =~ m<^/> ) { # starts not with `/', so it's not absolute
      my $cwd = $Temp::Cwd;
      chomp $cwd;

      die "Could not create directory $arg because current working " .
	"directory is not writable." unless ( -w $cwd );

      $cwd =~ s(/*$)(/);

      $arg = $cwd . $arg;
    }

    return main::FALSE unless ( $arg );

    if ( -d $arg ) { # $arg is a directory
      return main::FALSE unless ( -w $arg );
    } else { # $arg is not a directory
      if ( -e $arg ) { # $arg exists
	-w $arg && unlink $arg ||
	  die "could not delete `" . $arg . "': $!";
      } # end of if, existing $arg

      File::Path::make_path( $arg, {mask=>oct('0700')}) #  `mkdir -P'
	  or die "Could not create directory `$arg': $!";

    } # end if, else: not a directory
    return $arg;
  } # end sub make_dir()

  sub next_temp_file {
    state $n = 0;
    my $temp_file = $Args::temp_dir . $Args::file_prefix . '_temp_' . ++$n;
    print $main::fh_verbose "next temporary file: `$temp_file'";
    return $temp_file;
  }

  sub run_lilypond {
    # arg is the options collection for lilypond to run
    # either from ly2eps or pdf2eps
    my $opts = shift;
    chomp $opts;

    my $temp_file = &Subs::next_temp_file;
    my $output = main::EMPTYSTRING;

    # change to temp dir
    chdir $Args::temp_dir or
      die "Could not change to temporary directory `$Args::temp_dir': $!";

    print $main::fh_verbose "\n##### run of `lilypond'";
    $output = `lilypond $opts 2>$temp_file`;
    die "Program lilypond does not work: $?" if ( $? );
    chomp $output;
    &Subs::shell_handling( $output, $temp_file );
    print $main::fh_verbose "##### end run of `lilypond'\n";

    # stay in temp dir
  }

  sub shell_handling {
    # Handle ``-shell-command output in a string (arg1).
    # stderr goes to temporarty file $TempFile.
    my $out_string = shift;
    my $temp_file = shift;

    chomp $out_string;

    open my $fh_string, "<", \ $out_string or
      die "could not read the string `$out_string': $!";
    for ( <$fh_string> ) {
      chomp;
      print $main::fh_out $_;
    }
    close $fh_string;

    $temp_file && -f $temp_file && -r $temp_file ||
      die "shell_handling(): $temp_file is not a readable file.";
    open my $fh_temp, "<", $temp_file or
      die "shell_handling(): could not read temporary file $temp_file: $!";
    for ( <$fh_temp> ) {
      chomp;
      print $main::fh_verbose $_;
    }
    close $fh_temp;

    unlink $temp_file unless ( $Args::keep_files );
  }

  sub usage { # for `--help'
    my $p = $main::prog;
    my $usage =
qq*$p:
Read a `roff' file or standard input and transform `lilypond' parts
(everything between `.lilypond start' and `.lilypond end') into
temporary `EPS'-files that can be read by groff using `.PSPIC'.

There is also a command `.lilypond include <file_name>' that can
include a complete `lilypond' file into the `groff' document.


# Breaking options:
$p -h|--help|--usage       # usage
$p -v|--version            # version information
$p --license               # the license is GPL >= 3


# Normal options:
$p [options] [--] [filename ...]

There are 2 options for influencing the way how the `EPS' files for the
`roff' display are generated:
--ly2eps        `lilypond' generates `EPS' files directly (default)
--pdf2eps       `lilypond' generates a `PDF' file that is transformed

--keep_files    do not delete any temporary files

-V|--Verbose|--verbose      print much information to STDERR

Options with an argument:
--file_prefix=...    start for the names of temporary files
-o|--output=... sent output in the groff language into file ...
--temp_dir=...       provide the directory for temporary files.
                     This is created if it does not exist.

Perl >=5.10.0 needed.*;
    print STDOUT $usage;
  } # end sub usage()

  sub version { # for `--version'
    my $end;
    if ( $main::groff_version ) {
      $end = " version $main::groff_version";
    } else  {
      $end = '.';
    }

    my $output =
qq*`$main::prog' version `$main::VERSION' of `$main::last_update' is part
of `GNU groff'$end*;

    print STDOUT $output;
  } # end sub version()

} # end package `Subs'


########################################################################
### Emacs settings
# Local Variables:
# mode: CPerl
# End:
