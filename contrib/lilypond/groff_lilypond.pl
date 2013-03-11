#! /usr/bin/env perl

use strict;
use 5.10.0;

# use warnings;


########################################################################
# main: global stuff
########################################################################

{
  package main;
  use strict;

########################################################################
# legalese
########################################################################

  use vars '$VERSION';
  $VERSION = 'v0.6'; # version of groff_lilypond

  $main::last_update = '11 Mar 2013';

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

  use Cwd qw[];
  use File::Basename qw[];
  use File::Copy qw[];
  use File::HomeDir qw[];
  use File::Spec qw[];
  use File::Path qw[];

  use Time::HiRes qw[];

  use constant FALSE => 0;
  use constant TRUE => 1;
  use constant EMPTYSTRING => '';
  use constant EMPTYARRAY => ();
  use constant EMPTYHASH => ();

  $main::at_version_at = '@VERSION@'; # @...@ is replaced for the installation

  # `$prog_is_installed' is TRUE if the groff package is installed,
  # FALSE when in source package
  $main::prog_is_installed = ( $main::at_version_at =~ /^[@]VERSION[@]$/ )
    ? FALSE : TRUE;

  $main::groff_version = $main::prog_is_installed
    ? $main::at_version_at : main::EMPTYSTRING;

  {
    ( my $volume, my $directory, $main::prog ) = File::Spec->splitpath($0);
  }
  # $main::prog is `groff_lilypond' when installed,
  # `groff_lilypond.pl' when not


  $\ = "\n"; # adds newline at each print


  $main::fh_verbose; # file handle only for `--verbose'
  $main::fh_out; # file handle for `--output'

} # end of package `main'

##### end global variables


########################################################################
# Args: command line arguments
########################################################################

# command line arguments are handled in 2 runs:
# 1) split short option collections, `=' optargs, and transfer abbrevs
# 2) handle the transferred options with subs

{ # package `Args'

  package Args;
  use strict;


  # ----------
  # variables for package `Args'
  # ----------

  $Args::eps_dir = main::EMPTYSTRING; # directory for the used EPS-files
  # can be overwritten by `--eps_dir'

  # 2 possible values:
  # 1) `ly' from `--ly2eps' (default)
  # 2) `pdf' `--pdf2eps'
  $Args::eps_func = 'ly';

  $Args::file_prefix = 'ly';
  # names of temporary files in $main::TempDir start with this string
  # can be overwritten by `--file_prefix'

  # do not delete temporary files
  $Args::keep_files = main::FALSE;

  # the roff output goes normally to STDOUT, can be a file with `--output'
  $Args::output = main::EMPTYSTRING;

  $Args::temp_dir = main::EMPTYSTRING; # temporary directory
  # can be overwritten by `--temp_dir'

  # regulates verbose output (on STDERR), overwritten by `--verbose'
  $Args::verbose = main::FALSE;


  # ----------
  # subs for second run, for remaining long options after splitting and
  # transfer
  # ----------

  my %opts_with_arg =
    (

     '--eps_dir' => sub {
       $Args::eps_dir = shift;
     },

     '--output' => sub {
       $Args::output = shift;
     },

     '--prefix' => sub {
       $Args::file_prefix = shift;
     },

     '--temp_dir' => sub {
       $Args::temp_dir = shift;
     },

    ); # end of %opts_with_arg


  my %opts_noarg =
    (

     '--help' => sub {
       &Subs::usage;
       exit;
     },

     '--keep_files' => sub {
       $Args::keep_files = main::TRUE;
     },

     '--license' => sub {
       &Subs::license;
       exit;
     },

     '--ly2eps' => sub {
       $Args::eps_func = 'ly';
     },

     '--pdf2eps' => sub {
       $Args::eps_func = 'pdf';
     },

     '--verbose' => sub {
       $Args::verbose = main::TRUE;
     },

     '--version' => sub {
       $Subs::version;
     },

    ); # end of %opts_noarg


  # used variables in both runs

  my @files = main::EMPTYARRAY;

  {
    #----------
    # first run for command line arguments
    #----------

    # global variables for first run

    my @splitted_args;
    my $double_minus = main::FALSE;
    my $arg = main::EMPTYSTRING;
    my $has_arg = main::FALSE;


    # split short option collections and transfer these to suitable
    # long options from above

    my %short_opts =
      (
       'e' => '--eps_dir',
       'h' => '--help',
       'l' => '--license',
       'k' => '--keep_files',
       'o' => '--output',
       'p' => '--prefix',
       't' => '--temp_dir',
       'v' => '--version',
       'V' => '--verbose',
      );


    # transfer long option abbreviations to the long options from above

    my @long_opts;

    $long_opts[3] =
      { # option abbreviations of 3 characters
       '--e' => '--eps_dir',
       '--f' => '--prefix',
       '--h' => '--help',
       '--k' => '--keep_files',
       '--o' => '--output',
       '--t' => '--temp_dir',
       '--u' => '--help', # '--usage' is mapped to `--help'
       '--V' => '--verbose', # `--Verbose' is mapped to `--verbose'
      };

    $long_opts[4] =
      { # option abbreviations of 4 characters
       '--li' => '--license',
       '--ly' => '--ly2eps',
       '--pd' => '--pdf2eps',
       '--pr' => '--prefix',
      };

    $long_opts[6] =
      { # option abbreviations of 6 characters
       '--verb' => '--verbose',
       '--vers' => '--version',
      };


    # subs for short splitting and replacing long abbreviations

    my %split_subs =
      (

       'short_opt_collection' => sub { # %split_subs

	 my @chars = split //, $1; # omit leading dash
       CHARS: while ( @chars ) {
	   my $c = shift @chars;

	   unless ( exists $short_opts{ $c } ) {
	     print STDERR "Unknown short option `-$c'.";
	     next CHARS;
	   }

	   # short option exists

	   # map or transfer to special long option from above
	   my $transopt = $short_opts{ $c };

	   if ( exists $opts_noarg{ $transopt } ) {
	     push @splitted_args, $transopt;
	     $Args::verbose = main::TRUE if ( $transopt eq '--verbose' );
	     next CHARS;
	   }

	   if ( exists $opts_with_arg{ $transopt } ) {
	     push @splitted_args, $transopt;

	     if ( @chars ) {
	       # if @chars is not empty, option $transopt has argument
	       # in this arg, the rest of characters in @chars
	       shift @chars if ( $chars[0] eq '=' );
	       push @splitted_args, join "", @chars;
	       @chars = main::EMPTYARRAY;
	       next SPLIT;
	     }

	     # optarg is the next argument
	     $has_arg = $transopt;
	     next SPLIT;
	   } # end of if %opts_with_arg
	 } # end of while CHARS
       }, # end of sub for short_opt_collection


       'long_option' => sub { # %split_subs

	 my $from_arg = shift;
       N: for my $n ( qw/6 4 3/ ) {
	   $from_arg =~ / # match $n characters
			  ^
			  (
			    .{$n}
			  )
			/x;
	   my $argn = $1; # get the first $n characters

	   # no match, so luck for fewer number of chars
	   next N unless ( $argn );

	   next N unless ( exists $long_opts[ $n ] -> { $argn } );
	   # not in $n hash, so go on to next loop for $n

	   # now $n-hash has arg

	   # map or transfer to special long opt from above
	   my $transopt = $long_opts[ $n ] -> { $argn };

	   # test on option without arg
	   if ( exists $opts_noarg{ $transopt } ) { # opt has no arg
	     push @splitted_args, $transopt;
	     $Args::verbose = main::TRUE if ( $transopt eq '--verbose' );
	     next SPLIT;
	   } # end of if %opts_noarg

	   # test on option with arg
	   if ( exists $opts_with_arg{ $transopt } ) { # opt has arg
	     push @splitted_args, $transopt;

	     # test on optarg in arg
	     if ( $from_arg =~ / # optarg is in arg, has `='
				 ^
				 [^=]+
				 =
				 (
				   .*
				 )
				 $
			       /x ) {
	       push @splitted_args, $1;
	       next SPLIT;
	     } # end of if optarg in arg

	     # has optarg in next arg
	     $has_arg = $transopt;
	     next SPLIT;
	   } # end of if %opts_with_arg

	   # not with and without option, so is not permitted
	   print main::fh_verbose
	     "`$transopt' is unknown long option from `$from_arg'";
	   next SPLIT;
	 } # end of for N
       }, # end of sub for long option
    ); # end of %split_subs


    #----------
    # do split and transfer arguments
    #----------

  SPLIT: foreach (@ARGV) {
      # Transform long and short options into some given long options.
      # Split long opts with arg into 2 args (no `=').
      # Transform short option collections into given long options.
      chomp;

      if ( $has_arg ) {
	push @splitted_args, $_;
	$has_arg = main::EMPTYSTRING;
	next SPLIT;
      }

      if ( $double_minus ) {
	push @files, $_;
	next SPLIT;
      }

      if ( $_ eq '-' ) { # file arg `-'
	push @files, $_;
	next SPLIT;
      }

      if ( $_ eq '--' ) { # POSIX arg `--'
	push @splitted_args, $_;
	$double_minus = main::TRUE;
	next SPLIT;
      }

      if ( / # short option or collection of short options
	     ^
	     -
	     (
	       [^-]
	       .*
	     )
	     $
	   /x ) {
	$split_subs{ 'short_opt_collection' } -> ( $1 );
	next SPLIT;
      } # end of short option

      if ( /^--/ ) { # starts with 2 dashes, a long option
	$split_subs{ 'long_option' } -> ( $_ );
	next SPLIT;
      } # end of long option

      # unknown option without leading dash is a file name
      push @files, $_;
      next SPLIT;
    } # end of foreach SPLIT

    # all args are considered
    print STDERR "Option `$has_arg' needs an argument." if ( $has_arg );


    push @files, '-' unless ( @files );
    @ARGV = @splitted_args;

  } # end of splitting with map or transfer


  #----------
  # open $main::fh_verbose
  #----------

  {
    # install `$main::fh_verbose'
    if ( $Args::verbose ) { # `--verbose' was used
      # make verbose output, i.e. make `$main::fh_verbose' visible
      $main::fh_verbose = *STDERR;

    } else { # `--verbose' was not used
      # do not be verbose, make `$main::fh_verbose' invisible, e.g. either
      # in /dev/null or in a string

      my $opened = main::FALSE;

      my $devnull = File::Spec->devnull();
      if ( -e $devnull && -w $devnull ) {
	open $main::fh_verbose, ">", $devnull or
	  die "Could not open `$devnull': $!";

	# `/dev/null' will now be used for verbose output
	$opened = main::TRUE;
      }

      unless ( $opened ) { # couldn't use `$devnull', so print into a string
	my $print_to_string;
	open $main::fh_verbose, ">", \ $print_to_string or
	  die "Could not open `\$main::fh_verbose': $!";

	# now verbose output will go into a string, which is ignored
      }
    } # end if-else about verbose

    # $main::fh_verbose is now active

    {
      print $main::fh_verbose "Verbose output was chosen.";

      my $s = $main::prog_is_installed ? '' : ' not';
      print $main::fh_verbose "$main::prog is$s installed.";

      print $main::fh_verbose 'The command line options are:';

      $s = "  options:";
      $s .= " `$_'" for ( @ARGV );
      print $main::fh_verbose $s;

      $s = "  file names:";
      $s .= " `$_'\n" for ( @files );
      print $main::fh_verbose $s;

    }

  } # end fh_verbose


  #----------
  # second run of command line arguments
  #----------

  {
    # second run of args with new @ARGV from the formere splitting
    # arguments are now splitted and transformed into special long options
    my $double_minus = main::FALSE;
    my $has_arg = main::FALSE;

    my $has_arg = main::FALSE;

  ARGS: for my $arg ( @ARGV ) {

      # ignore `--', file names are handled later on
      last ARGS if ( $arg eq '--' );

      if ( $has_arg ) {
	unless ( exists $opts_with_arg{ $has_arg } ) {
	  print STDERR "`\%opts_with_args' does not have key `$has_arg'.";
	  next ARGS;
	}

	$opts_with_arg{ $has_arg } -> ( $arg );
	$has_arg = main::FALSE;
	next ARGS;
      } # end of $has_arg

      if ( exists $opts_with_arg{ $arg } ) {
	$has_arg = $arg;
	next ARGS;
      }

      if ( exists $opts_noarg{ $arg } ) {
	$opts_noarg { $arg } -> ();
	next ARGS;
      }

      # not a suitable option
      print STDERR "Wrong option `$arg'.";
      next ARGS;

    } # end of for ARGS:


    if ( $has_arg ) { # after last argument
      die "Option `$has_arg' needs an argument.";
    }

  } # end ot second run


  if ( $Args::output ) {
    my $out_path = &Subs::path2abs( $Args::output );
    die "Output file name `$Args::output' cannot be used."
      unless ( $out_path );

    my ( $file, $dir );
    ( $file, $dir )= File::Basename::fileparse( $out_path )
      or die "Could not handle output file path `$out_path': " .
	"directory name `$dir' and file name `$file'.";

    die "Could not find output directory for `$Args::output'" unless ( $dir );
    die "Could not find output file: `$Args::output'" unless ( $file );

    if ( -d $dir ) {
      die "Could not write to output directory `$dir'." unless ( -w $dir );
    } else {
      $dir = &Subs::make_dir( $dir );
      die "Could not create output directory in: `$out_path'." unless ( $dir );
    }

    # now $dir is a writable directory

    if ( -e $out_path ) {
      die "Could not write to output file" unless ( -w $out_path );
    }

    open $main::fh_out, ">", $out_path or
      die "could not write to output file `$out_path': $!";
    print main::fh_verbose "Output goes to file `$out_path'";
  } else {
    $main::fh_out = *STDOUT;
  }


  $Args::file_prefix .= '_' . $Args::eps_func . '2eps';


  @ARGV = @files;

}

# end package `Args'


########################################################################
# temporary directory .../tmp/groff/USER/lilypond/TIME
########################################################################

{
  package Temp;
  use strict;

  # `$Cwd' stores the current directory
  $Temp::cwd = Cwd::getcwd;

  $Temp::temp_dir = main::EMPTYSTRING;


  if ( $Args::temp_dir ) {

    #----------
    # temporary directory was set by `--temp_dir'
    #----------

    my $dir = $Args::temp_dir;

    $dir = &Subs::path2abs( $dir );
    $dir = &Subs::make_dir ( $dir ) or
      die "The directory `$dir' cannot be used temporarily: $!";


    # now `$dir' is a writable directory

    opendir( my $dh, $dir ) or
      die "Could not open temporary directory `$dir': $!";
    my $file_name;
    my $found = main::FALSE;
    my $re = qr<
		 ^
		 $Args::file_prefix
		 _
	       >x;

  READDIR: while ( defined( $file_name = readdir ( $dh ) ) ) {
      chomp $file_name;
      if ( $file_name =~ /$re/ ) { # file name starts with $prefix_
	$found = main::TRUE;
	last READDIR;
      }
      next;
    }

    $Temp::temp_dir = $dir;
    my $n = 0;
    while ( $found ) {
      $dir = File::Spec -> catdir( $Temp::temp_dir, ++$n );
      next if ( -e $dir );

      $dir = &Subs::make_dir ( $dir ) or next;

      $found = main::FALSE;
      last;
    }

    $Temp::temp_dir = $dir;


  } else { # $Args::temp_dir not given by `--temp_dir'

    #----------
    # temporary directory was not set
    #----------

    { # search for or create a temporary directory

      my @tempdirs = main::EMPTYARRAY;
      {
	my $tmpdir = File::Spec -> tmpdir();
	push @tempdirs, $tmpdir if ( $tmpdir && -d $tmpdir && -w $tmpdir );

	my $root_dir = File::Spec -> rootdir(); # `/' in Unix
	my $root_tmp = File::Spec -> catdir( $root_dir, 'tmp' );
	push @tempdirs, $root_tmp
	  if ( $root_tmp ne $tmpdir && -d $root_tmp && -w $root_tmp );

	# home directory of the actual user
	my $home = File::HomeDir -> my_home;
	my $home_tmp = File::Spec -> catdir ( $home, 'tmp' );
	push @tempdirs, $home_tmp if ( -d $home_tmp && -w $home_tmp );

	# `/var/tmp' in Unix
	my $var_tmp = File::Spec -> catdir( '', 'var', 'tmp' );
	push @tempdirs, $var_tmp if ( -d $var_tmp && -w $var_tmp );
      }


      my @path_extension = qw( groff ); # TEMPDIR/groff/USER/lilypond/<NUMBER>
      {
	# `$<' is UID of actual user,
	# `getpwuid' gets user name in scalar context
	my $user = getpwuid( $< );
	push @path_extension, $user if ( $user );

	push @path_extension, qw( lilypond );
      }


    TEMPS: foreach ( @tempdirs ) {

	my $dir; # final directory name in `while' loop
	$dir = &Subs::path2abs ( $_ );
	next TEMPS unless ( $dir );

	# beginning of directory name
	my @dir_begin =
	  ( File::Spec -> splitdir( $dir ), @path_extension );


	my $n = 0;
	my $dir_blocked = main::TRUE;
      BLOCK: while ( $dir_blocked ) {
	  # should become the final dir name
	  $dir = File::Spec -> catdir ( @dir_begin, ++$n );
	  next BLOCK if ( -d $dir );

	  # dir name is now free, create it, and end the blocking
	  my $res = &Subs::make_dir( $dir );
	  die "Could not create directory: $dir" unless ( $res );

	  $dir = $res;
	  $dir_blocked = main::FALSE;
	}

	next TEMPS unless ( -d $dir && -w $dir  );

	# $dir is now a writable directory
	$Temp::temp_dir = $dir; # tmp/groff/USER/lilypond/TIME
	last TEMPS;
      } # end foreach tmp directories
    } # end to create a temporary directory

    die "Could not find a temporary directory" unless
      ( $Temp::temp_dir && -d $Temp::temp_dir && -w $Temp::temp_dir );

  } # end temporary directory

  print $main::fh_verbose "Temporary directory: `$Temp::temp_dir'\n";
  print $main::fh_verbose "file_prefix: `$Args::file_prefix'";


  #----------
  # EPS directory
  #----------

  $Temp::eps_dir = main::EMPTYSTRING;
  if ( $Args::eps_dir ) { # set by `--eps_dir'
    my $dir = $Args::eps_dir;
    my $make_dir = main::FALSE;

    $dir = &Subs::path2abs( $dir );

    if ( -e $dir ) {
      goto EMPTY unless ( -w $dir );

      # `$dir' is writable
      if ( -d $dir ) {
	my $upper_dir = $dir;

	my $found = main::FALSE;
	opendir( my $dh, $upper_dir ) or $found = main::TRUE;
	my $re = qr<
		     ^
		     $Args::file_prefix
		     _
		   >x;
	while ( not $found ) {
	  my $file_name = readdir ( $dh );
	  if ( $file_name =~ /$re/ ) { # file name starts with $prefix_
	    $found = main::TRUE;
	    last;
	  }
	  next;
	}

	my $n = 0;
	while ( $found ) {
	  $dir = File::Spec -> catdir( $upper_dir, ++$n );
	  next if ( -d $dir );
	  $found = main::FALSE;
	}
	$make_dir = main::TRUE;
	$Temp::eps_dir = $dir;
      } else { # `$dir' is not a dir, so unlink it to create it as dir
	if ( unlink $dir ) { # could remove `$dir'
	  $Temp::eps_dir = $dir;
	  $make_dir = main::TRUE;
	} else { # could not remove
	  print STDERR "Could not use EPS dir `$dir', use temp dir.";
	} # end of unlink
      } # end test of -d $dir
    } else {
      $make_dir = main::TRUE;
    } # end of if -e $dir


    if ( $make_dir ) { # make directory `$dir'
      my $made = main::FALSE;
      $dir = &Subs::make_dir ( $dir ) and $made = main::TRUE;

      if ( $made ) {
	$Temp::eps_dir = $dir;
	print $main::fh_verbose "Directory for useful EPS files is `$dir'.";
      } else {
	print main::fh_verbose "The EPS directory $dir cannot be used: $!";
      }
    } else { # `--eps_dir' was not set, so take the temporary directory
      $Temp::eps_dir = $Args::temp_dir;
    } # end of make dir
  }

 EMPTY: unless ( $Temp::eps_dir ) {
    # EPS-dir not set or available, use temp dir,
    # but leave $Temp::eps_dir empty
    print $main::fh_verbose "Directory for useful EPS files is the " .
      "temporary directory `$Temp::temp_dir'.";
  }

} # end package `Temp'


########################################################################
# Read: read files or stdin
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

  my $path_ly; # path of ly-file


  my $check_file = sub { # for argument of `.lilypond include'
    my $file = shift; # argument is a file name
    $file = &Subs::path2abs( $file );
    unless ( $file ) {
      die "Line `.lilypond include' without argument";
      return '';
    }
    unless ( -f $file && -r $file ) {
      die "Argument `$file' in `.lilypond include' is not a readable file";
    }

    return $file;
  }; # end sub &$check_file()


  my $increase_ly_number = sub {
    ++$ly_number;
    $Read::file_numbered = $Args::file_prefix . '_' . $ly_number;
    $Read::file_ly =  $Read::file_numbered . '.ly';
    $path_ly = File::Spec -> catdir ( $Temp::temp_dir, $Read::file_ly );
  };


  my %eps_subs =
    (
     'ly' => \&Subs::create_ly2eps,   # lilypond creates eps files
     'pdf' => \&Subs::create_pdf2eps, # lilypond creates pdf file
    );

  # about lines starting with `.lilypond'

  my $fh_write_ly;
  my $fh_include_file;
  my %lilypond_args =
    (

     'start' => sub {
       print $main::fh_verbose "\nline: `.lilypond start'";
       die "Line `.lilypond stop' expected." if ( $lilypond_mode );

       $lilypond_mode = main::TRUE;
       &$increase_ly_number;

       print $main::fh_verbose
	 "ly-file: `" . $path_ly . "'";

       open $fh_write_ly, ">", $path_ly or
	 die "Cannot open file `$path_ly': $!";
       next LILYPOND;
     },


     'end' => sub {
       print $main::fh_verbose "line: `.lilypond end'\n";
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

       open $fh_write_ly, ">", $path_ly or
	   die "Cannot open file `$path_ly': $!";

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

    if ( /
	   ^
	   [.']
	   \s*
	   lilypond
	   (
	     .*
	   )
	   $
	 /x ) { # .lilypond ...
      my $args = $1;
      $args =~ s/
		  ^
		  \s*
		//x;
      $args =~ s/
		  \s*
		  $
		//x;
      $args =~ s/
		  ^
		  (
		    \S*
		  )
		  \s*
		//x;
      my $arg1 = $1; # `start', `end' or `include'
      $args =~ s/["'`]//g;
      my $arg2 = $args; # file argument for `.lilypond include'

      if ( exists $lilypond_args{ $arg1 } ) {
	$lilypond_args{ $arg1 } -> ( $arg2 );

      } else {
	# not a suitable argument of `.lilypond'
	print STDERR "Unknown command: `$arg1' `$arg2':  `$line'";
      }

      next LILYPOND;
    } # end if .lilypond


    if ( $lilypond_mode ) { # do lilypond-mode
      print $fh_write_ly $line or # see `.lilypond start'
	die "could not print to \$fh_write_ly in lilypond-mode";
      next LILYPOND;
    } # do lilypond-mode

    # unknown line without lilypond
    unless ( /
	       ^
	       [.']
	       \s*
	       lilypond
	     /x ) { # not a `.lilypond' line
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


  if ( $Args::keep_files ) {
    # With --keep_files, no temporary files are removed.
    print $main::fh_verbose "keep_files: `TRUE'";
    print $main::fh_verbose "No temporary files will be deleted:";

    opendir my $dh_temp, $Temp::temp_dir or
      die "Cannot open $Temp::temp_dir: $!";
    for ( sort readdir $dh_temp ) {
      next if ( /         # omit files starting with a dot
		  ^
		  \.
		/x );
      if ( /
	     ^
	     $Args::file_prefix
	     _
	   /x ) {
	my $file = File::Spec -> catfile( $Temp::temp_dir, $_ );
	print $main::fh_verbose "- " . $file ;
	next;
      }
      next;
    } # end for sort readdir
    closedir $dh_temp;

  } else { # keep_files is not set
    # Remove all temporary files except the eps files.

    print $main::fh_verbose "keep_files: `FALSE'";
    print $main::fh_verbose
      "All temporary files except *.eps will be deleted";


    if ( $Temp::eps_dir ) {
      # EPS files are in another dir, remove temp dir

      if ( &Subs::is_subdir( $Temp::eps_dir, $Temp::temp_dir ) ) {
	print $main::fh_verbose "EPS dir is subdir of temp dir, so keep both.";
      } else { # remove temp dir
	print $main::fh_verbose
	  "Try to remove temporary directory `$Temp::temp_dir':";
	if ( File::Path::remove_tree( $Temp::temp_dir ) ) { # remove succeeds
	  print $main::fh_verbose "...done.";
	} else { # did not remove
	  print $main::fh_verbose "Failure to remove temporary directory.";
	} # end test on remove
      } # end is subdir

    } else { # no EPS dir, so keep EPS files

      opendir my $dh_temp, $Temp::temp_dir or
	die "Cannot open $Temp::temp_dir: $!";
      for ( sort readdir $dh_temp ) {
	next if ( /          # omit files starting with a dot
		    ^
		    \.
		  /x );
	next if ( /          # omit EPS-files
		    \.eps
		    $
		  /x );
	if ( /
	       ^
	       $Args::file_prefix
	       _
	     /x ) { # this includes `PREFIX_temp*'
	  my $file = File::Spec -> catfile( $Temp::temp_dir,  $_ );
	  print $main::fh_verbose "Remove " . $file;
	  unlink $file or print STDERR "Could not remove $file: $!";
	  next;
	} # end if prefix
	next;
      } # end for readdir temp dir
      closedir $dh_temp;
    } # end if-else EPS files
  } # end if-else keep files




  if ( $Temp::eps_dir ) {
    # EPS files in $Temp::eps_dir are always kept
    print $main::fh_verbose "As EPS directrory is set as `$Temp::eps_dir'" .
      ", noEPS  files there will be deleted:";

    opendir my $dh_temp, $Temp::eps_dir or
      die "Cannot open $Temp::eps_dir: $!";
    for ( sort readdir $dh_temp ) {
      next if ( /         # omit files starting with a dot
		  ^
		  \.
		/x );
      if ( /
	     ^
	     $Args::file_prefix
	     _
	     .*
	     \.eps
	     $
	   /x ) {
	my $file = File::Spec -> catfile( $Temp::eps_dir, $_ );
	print $main::fh_verbose "- " . $file ;
	next;
      } # end if *.eps
      next;
    } # end for sort readdir
    closedir $dh_temp;

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

    Cwd::chdir $Temp::cwd or
      die "Could not change to former directory `$Temp::cwd': $!";

    my $eps_dir = $Temp::eps_dir;
    my $dir = $Temp::temp_dir;
    opendir( my $dh, $dir ) or
      die "could not open temporary directory `$dir': $!";

    my $re = qr<
		 ^
		 $prefix
		 -
		 .*
		 \.eps
		 $
	       >x;
    my $file;
    while ( readdir( $dh ) ) {
      chomp;
      $file = $_;
      if ( /$re/ ) {
	my $file_path = File::Spec -> catfile( $dir, $file );
	if ( $eps_dir ) {
	  my $could_copy = main::FALSE;
	  File::Copy::copy ( $file_path, $eps_dir )
	      and $could_copy = main::TRUE;
	  if ( $could_copy ) {
	    unlink $file_path;
	    $file_path = File::Spec -> catfile( $eps_dir, $_ );
	  }
	}
	print $main::fh_out '.PSPIC ' . $file_path;
      }
    } # end while readdir
    closedir( $dh );
  } # end sub create_ly2eps()


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
    Cwd::chdir $Temp::cwd or
      die "Could not change to former directory `$Temp::cwd': $!";

    # handling of .eps file
    my $file_eps = $prefix . '.eps';
    my $eps_path = File::Spec -> catfile( $Temp::temp_dir, $file_eps );
    if ( $Temp::eps_dir ) {
      my $has_copied = main::FALSE;
      File::Copy::copy( $eps_path, $Temp::eps_dir )
	  and $has_copied = main::TRUE;
      if ( $has_copied ) {
	unlink $eps_path;
	$eps_path = File::Spec -> catfile( $Temp::eps_dir, $file_eps );
      } else {
	print STDERR "Could not use EPS-directory.";
      } # end Temp::eps_dir
    }
    # print into groff output
    print $main::fh_out '.PSPIC ' . $eps_path;
  } # end sub create_pdf2eps()


  sub is_subdir { # arg1 is subdir of arg2 (is longer)
    my ( $dir1, $dir2 ) = @_;
    $dir1 = &Subs::path2abs( $dir1 );;
    $dir2 = &Subs::path2abs( $dir2 );;
    my @split1 = File::Spec -> splitdir( $dir1 );
    my @split2 = File::Spec -> splitdir( $dir2 );
    for ( @split2 ) {
      next if ( $_ eq shift @split1 );
      return main::FALSE;
    }
    return main::TRUE;
  }


  sub license {
    &version;
    print STDOUT $main::License;
  } # end sub license()


  sub make_dir { # make directory or check if it exists
    my $dir_arg = shift;
    chomp $dir_arg;
    $dir_arg =~ s/^\s*(.*)\s*$/$1/;

    unless ( $dir_arg ) {
      print $main::fh_verbose "make_dir(): empty argument";
      return $main::FALSE;
    }

    unless ( File::Spec->file_name_is_absolute( $dir_arg ) ) {
      my $res = Cwd::realpath( $dir_arg );
      $res = File::Spec -> canonpath ( $dir_arg ) unless ( $res );
      $dir_arg = $res if ( $res );
    }

    return $dir_arg if ( -d $dir_arg && -w $dir_arg );


    # search thru the dir parts
    my @dir_parts = File::Spec -> splitdir( $dir_arg );
    my @dir_grow;
    my $dir_grow;
    my $can_create = main::FALSE; # dir could be created if TRUE

  DIRPARTS: for ( @dir_parts ) {
      push @dir_grow, $_;
      next DIRPARTS unless ( $_ ); # empty string for root directory

      # from array to path dir string
      $dir_grow = File::Spec -> catdir ( @dir_grow );

      next DIRPARTS if ( -d $dir_grow );

      if ( -e $dir_grow ) { # exists, but not a dir, so must be removed
	die "Couldn't create dir `$dir_arg', it is blocked by `$dir_grow'."
	  unless ( -w $dir_grow );

	# now it's writable, but not a dir, so it can be removed
	unlink ( $dir_grow ) or
	  die "Couldn't remove `$dir_grow', " .
	    "so I cannot create dir `$dir_arg': $!";
      }

      # $dir_grow does no longer exist, so the former dir must be writable
      # in order to create the directory
      pop @dir_grow;
      $dir_grow = File::Spec -> catdir ( @dir_grow );

      die "`$dir_grow' is not writable, " . 
	"so directory `$dir_arg' can't be createdd."
	  unless ( -w $dir_grow );

      # former directory is writable, so `$dir_arg' can be created

      File::Path::make_path( $dir_arg,
			     {
			      mask => oct( '0700' ),
			      verbose => $Args::verbose,
			     }
			   ) #  `mkdir -P'
	  or die "Could not create directory `$dir_arg': $!";

      last DIRPARTS;
    }

    die "`$dir_arg' is not a writable directory"
      unless ( -d $dir_arg && -w $dir_arg );

    return $dir_arg;

  } # end sub make_dir()


  sub next_temp_file {
    state $n = 0;
    ++$n;
    my $temp_basename = $Args::file_prefix . '_temp_' . $n;
    my $temp_file = File::Spec -> catfile( $Temp::temp_dir, $temp_basename );
    print $main::fh_verbose "next temporary file: `$temp_file'";
    return $temp_file;
  } # end sub next_temp_file()


  sub path2abs {
    my $path = shift;
    $path =~ s/
		^
		\s*
		(
		  .*
		)
		\s*
		$
	      /$1/x;

    die "path2abs(): argument is empty." unless ( $path );

    # Perl does not support shell `~' for home dir
    if ( $path =~ /
		    ^
		    ~
		  /x ) {
      if ( $path eq '~' ) { # only own home
	$path = File::HomeDir -> my_home;
      } elsif ( $path =~ m<
			    ^
			    ~ /
			    (
			      .*
			    )
			    $
			  >x ) { # subdir of own home
	$path = File::Spec -> catdir( $Temp::cwd, $1 );
      } elsif ( $path =~ m<
			    ^
			    ~
			    (
			      [^/]+
			    )
			    $
			  >x ) { # home of other user
	$path = File::HomeDir -> users_home( $1 );
      } elsif ( $path =~ m<
			    ^
			    ~
			    (
			      [^/]+
			    )
			    /+
			    (
			      .*
			    )
			    $
			  >x ) { # subdir of other home
	$path = File::Spec ->
	  catdir( File::HomeDir -> users_home( $1 ), $2 );
      }
    }

    $path = File::Spec -> rel2abs ( $path );

    # now $path is absolute
    return $path;
  }


  sub run_lilypond {
    # arg is the options collection for `lilypond' to run
    # either from ly or pdf
    my $opts = shift;
    chomp $opts;

    my $temp_file = &Subs::next_temp_file;
    my $output = main::EMPTYSTRING;

    # change to temp dir
    Cwd::chdir $Temp::temp_dir or
      die "Could not change to temporary directory `$Temp::temp_dir': $!";

    print $main::fh_verbose "\n##### run of `lilypond $opts'";
    $output = `lilypond $opts 2>$temp_file`;
    die "Program lilypond does not work: $?" if ( $? );
    chomp $output;
    &Subs::shell_handling( $output, $temp_file );
    print $main::fh_verbose "##### end run of `lilypond'\n";

    # stay in temp dir
  } # end sub run_lilypond()


  sub shell_handling {
    # Handle ``-shell-command output in a string (arg1).
    # stderr goes to temporary file $TempFile.
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
  } # end sub shell_handling()


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

-k|--keep_files    do not delete any temporary files

-V|--Verbose|--verbose      print much information to STDERR

Options with an argument:
-e|--eps_dir=...     use a directory for the EPS files
-o|--output=...      sent output in the groff language into file ...
-p|--prefix=...      start for the names of temporary files
-t|--temp_dir=...    provide the directory for temporary files.

The set directories are created when they do not exist.

In a former version of $p, there was an additional option `--file_+prefix',
this is now replaced by `--prefix'.

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
