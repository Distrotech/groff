#! /usr/bin/env perl
# grog - guess options for groff command
# Inspired by doctype script in Kernighan & Pike, Unix Programming
# Environment, pp 306-8.

# Source file position: <groff-source>/src/roff/grog/subs.pl
# Installed position: <prefix>/lib/grog/subs.pl

# Copyright (C) 1993, 2006, 2009, 2011-2012, 2014
#               Free Software Foundation, Inc.
# This file was split from grog.pl and put under GPL2 by
#               Bernd Warken <groff-bernd.warken-72@web.de>.
# The macros for identifying the devices were taken from Ralph
# Corderoy's `grog.sh' from 2006.

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
# Last_Update = '6 Jul 2014';
########################################################################

require v5.6;

use warnings;
use strict;

use File::Spec;

# for running programs
use IPC::System::Simple qw(capture capturex run runx system systemx);

$\ = "\n";

# my $Sp = "[\\s\\n]";
# my $Sp = qr([\s\n]);
# my $Sp = '' if $arg eq '-C';
my $Sp = '';

# from `src/roff/groff/groff.cpp' near `getopt_long'
my $groff_opts =
  'abcCd:D:eEf:F:gGhiI:jJkK:lL:m:M:n:No:pP:r:RsStT:UvVw:W:XzZ';

my @Command = ();		# stores the final output
my @Mparams = ();		# stores the options `-m*'
my @devices = ();
my %File_Name_Extensions = ();
my $do_run = 0;			# run generated `groff' command
my $pdf_with_ligatures = 0;	# `-P-y -PU' for `pdf' device
my $with_warnings = 0;
my $is_mmse;

our $Prog;

my %macros;
my %Groff = (
	     # preprocessors
	     'chem' => 0,
	     'eqn' => 0,
	     'gperl' => 0,
	     'grap' => 0,
	     'grn' => 0,
	     'gideal' => 0,
	     'lilypond' => 0,

	     'pic' => 0,
	     'PS' => 0,		# opening for pic
	     'PF' => 0,		# alternative opening for pic
	     'PE' => 0,		# closing for pic

	     'refer' => 0,
	     'refer_open' => 0,
	     'refer_close' => 0,
	     'soelim' => 0,
	     'tbl' => 0,

	     # tmacs
	     'man' => 0,
	     'mandoc' => 0,
	     'mdoc' => 0,
	     'mdoc_old' => 0,
	     'me' => 0,
	     'mm' => 0,
	     'mom' => 0,
	     'ms' => 0,

	     # requests
	     'AB' => 0,		# ms
	     'AE' => 0,		# ms
	     'AI' => 0,		# ms
	     'AU' => 0,		# ms
	     'NH' => 0,		# ms
	     'TL' => 0,		# ms
	     'UL' => 0,		# ms
	     'XP' => 0,		# ms

	     'IP' => 0,		# man and ms
	     'LP' => 0,		# man and ms
	     'P' => 0,		# man and ms
	     'PP' => 0,		# man and ms
	     'SH' => 0,		# man and ms

	     'OP' => 0,		# man
	     'SS' => 0,		# man
	     'SY' => 0,		# man
	     'TH' => 0,		# man
	     'TP' => 0,		# man
	     'UR' => 0,		# man
	     'YS' => 0,		# man

	     # for mdoc and mdoc-old
	     # .Oo and .Oc for modern mdoc, only .Oo for mdoc-old
	     'Oo' => 0,		# mdoc and mdoc-old
	     'Oc' => 0,		# mdoc
	     'Dd' => 0,		# mdoc
);


########################################################################
# sub args_with_minus: command line arguments that are not file names
########################################################################

sub handle_args {
  our @filespec;			# stores inout file names
  my $double_minus = 0;
  my $was_minus = 0;
  my $was_T = 0;
  my $optarg = 0;

  foreach my $arg (@ARGV) {

    if ( $optarg ) {
      push @Command, $arg;
      $optarg = 0;
      next;
    }

    if ( $double_minus ) {
      if (-f $arg && -r $arg) {
	push @filespec, $arg;
      } else {
	print STDERR "grog: $arg is not a readable file.";
      }
      next;
    }

    if ( $was_T ) {
      push @devices, $arg;
      $was_T = 0;
      next;
    }
####### sub handle_args

    unless ( $arg =~ /^-/ ) { # file name, no opt, no optarg
      unless (-f $arg && -r $arg) {
	print 'unknown file name: ' . $arg;
      }
      push @filespec, $arg;
      next;
    }

    # now $arg starts with `-'

    if ($arg eq '-') {
      unless ($was_minus) {
	push @filespec, $arg;
	$was_minus = 1;
      }
      next;
    }

    if ($arg eq '--') {
      $double_minus = 1;
      push(@filespec, $arg);
      next;
    }

    &version() if $arg =~ /^--?v/;	# --version, with exit
    &help() if $arg  =~ /--?h/;		# --help, with exit

    if ( $arg =~ /^--r/ ) {		#  --run, no exit
      $do_run = 1;
      next;
    }

    if ( $arg =~ /^--wa/ ) {		#  --warnings, no exit
      $with_warnings = 1;
      next;
    }
####### sub handle_args

    if ( $arg =~ /^--(wi|l)/ ) { # --ligatures, no exit
      # the old --with_ligatures is only kept for compatibility
      $pdf_with_ligatures = 1;
      next;
    }

    if ($arg =~ /^-m/) {
      push @Mparams, $arg;
      next;
    }

    if ($arg =~ /^-T$/) {
      $was_T = 1;
      next;
    }

    if ($arg =~ s/^-T(\w+)$/$1/) {
      push @devices, $1;
      next;
    }

    if ($arg =~ /^-(\w)(\w*)$/) {	# maybe a groff option
      my $opt_char = $1;
      my $opt_char_with_arg = $opt_char . ':';
      my $others = $2;
      if ( $groff_opts =~ /$opt_char_with_arg/ ) {	# groff optarg
	if ( $others ) {	# optarg is here
	  push @Command, '-' . $opt_char;
	  push @Command, '-' . $others;
	  next;
	}
	# next arg is optarg
	$optarg = 1;
	next;
####### sub handle_args
      } elsif ( $groff_opts =~ /$opt_char/ ) {	# groff no optarg
	push @Command, '-' . $opt_char;
	if ( $others ) {	# $others is now an opt collection
	  $arg = '-' . $others;
	  redo;
	}
	# arg finished
	next;
      } else {		# not a groff opt
	print STDERR 'unknown argument ' . $arg;
	push(@Command, $arg);
	next;
      }
    }
  }
  @filespec = ('-') unless (@filespec);
} # sub handle_args


########################################################################
# sub do_first_line
########################################################################

# As documented for the `man' program, the first line can be
# used as an groff option line.  This is done by:
# - start the line with '\" (apostrophe, backslash, double quote)
# - add a space character
# - a word using the following characters can be appended: `egGjJpRst'.
#     Each of these characters means an option for the generated
#     `groff' command line, e.g. `-t'.

sub do_first_line {
  my ( $line, $file ) = @_;
  our %preprocs_tmacs;
  # For a leading groff options line use only [egGjJpRst]
  if  ( $line =~ /^[.']\\"[\segGjJpRst]+&/ ) {
    # this is a groff options leading line
    if ( $line =~ /^\./ ) {
      # line is a groff options line with . instead of '
      print "First line in $file must start with an apostrophe \ " .
	"instead of a period . for groff options line!";
    }

    if ( $line =~ /j/ ) {
      $Groff{'chem'}++;
    }
    if ( $line =~ /e/ ) {
      $Groff{'eqn'}++;
    }
    if ( $line =~ /g/ ) {
      $Groff{'grn'}++;
    }
    if ( $line =~ /G/ ) {
      $Groff{'grap'}++;
    }
    if ( $line =~ /i/ ) {
      $Groff{'gideal'}++;
    }
    if ( $line =~ /p/ ) {
      $Groff{'pic'}++;
    }
    if ( $line =~ /R/ ) {
      $Groff{'refer'}++;
    }
    if ( $line =~ /s/ ) {
      $Groff{'soelim'}++;
    }
####### sub do_first_line
    if ( $line =~ /t/ ) {
      $Groff{'tbl'}++;
    }
    return 1;	# a leading groff options line, 1 means yes, 0 means no
  }

  # not a leading short groff options line

  return 0 if ( $line !~ /^[.']\\"\s*(.*)$/ );	# ignore non-comments

  return 0 unless ( $1 );	# for empty comment

  # all following array members are either preprocs or 1 tmac, in 
  my @words = split '\s+', $1;

  my @in = ();
  my $word;
  for $word ( @words ) {
    if ( $word eq 'ideal' ) {
      $word = 'gideal';
    } elsif ( $word eq 'gpic' ) {
      $word = 'pic';
    } elsif ( $word =~ /^(gn|)eqn$/ ) {
      $word = 'eqn';
    }
    if ( exists $preprocs_tmacs{$word} ) {
      push @in, $word;
    } else {
      # not word for preproc or tmac
      return 0;
    }
  }

  for $word ( @in ) {
    $Groff{$word}++;
  }
} # sub do_first_line


########################################################################
# sub do_line
########################################################################

sub do_line {
  my ( $line, $file ) = @_;

  our $is_mmse = 0;

  return if ( $line =~ /^[.']\s*\\"/ );	# comment

  return unless ( $line =~ /^[.']/ );	# ignore text lines

  $line =~ s/^['.]\s*/./;	# let only a dot as leading character,
				# remove spaces after the leading dot
  $line =~ s/\s+$//;		# remove final spaces

  return if ( $line =~ /^\.$/ );	# ignore .
  return if ( $line =~ /^\.\.$/ );	# ignore ..

  # split command
  $line =~ /^(\.\w+)\s*(.*)$/;
  my $command = $1;
  $command = '' unless ( defined $command );
  my $args = $2;
  $args = '' unless ( defined $args );


  ######################################################################
  # soelim
  if ( $line =~ /^\.(do)?\s*(so|mso|PS\s*<|SO_START).*$/ ) {
    # `.so', `.mso', `.PS<...', `.SO_START'
    $Groff{'soelim'}++;
    return;
  }
  if ( $line =~ /^\.(do)?\s*(so|mso|PS\s*<|SO_START).*$/ ) {
    # `.do so', `.do mso', `.do PS<...', `.do SO_START'
    $Groff{'soelim'}++;
    return;
  }
####### sub do_line

  ######################################################################
  # macros

  if ( $line =~ /^\.de1?\W?/ ) {
    # this line is a macro definition, add it to %macros
    my $macro = $line;
    $macro =~ s/^\.de1?\s+(\w+)\W*/.$1/;
    return if ( exists $macros{$macro} );
    $macros{$macro} = 1;
    return;
  }


  # if line command is a defined macro, just ignore this line
  return if ( exists $macros{$command} );


  ######################################################################
  # preprocessors

  if ( $command =~ /^(\.cstart)|(begin\s+chem)$/ ) {
    $Groff{'chem'}++;		# for chem
    return;
  }
  if ( $command =~ /^\.EQ$/ ) {
    $Groff{'eqn'}++;		# for eqn
    return;
  }
  if ( $command =~ /^\.G1$/ ) {
    $Groff{'grap'}++;		# for grap
    return;
  }
  if ( $command =~ /^\.Perl$/ ) {
    $Groff{'gperl'}++;		# for gperl
    return;
  }
  if ( $command =~ /^\.GS$/ ) {
    $Groff{'grn'}++;		# for grn
    return;
  }
  if ( $command =~ /^\.IS$/ ) {
    $Groff{'gideal'}++;		# preproc gideal for ideal
    return;
  }
  if ( $command =~ /^\.lilypond$/ ) {
    $Groff{'lilypond'}++;	# for glilypond
    return;
  }

####### sub do_line

  # pic can be opened by .PS or .PF and closed by .PE
  if ( $command =~ /^\.PS$/ ) {
    $Groff{'pic'}++;		# normal opening for pic
    return;
  }
  if ( $command =~ /^\.PF$/ ) {
    $Groff{'PF'}++;		# alternate opening for pic
    return;
  }
  if ( $command =~ /^\.PE$/ ) {
    $Groff{'PE'}++;		# closing for pic
    return;
  }

  if ( $command =~ /^\.R1$/ ) {
    $Groff{'refer'}++;		# for refer
    return;
  }
  if ( $command =~ /^\.\[$/ ) {
    $Groff{'refer_open'}++;	# for refer open
    return;
  }
  if ( $command =~ /^\.\]$/ ) {
    $Groff{'refer_close'}++;	# for refer close
    return;
  }
  if ( $command =~ /^\.TS$/ ) {
    $Groff{'tbl'}++;		# for tbl
    return;
  }


  ######################################################################
  # macro packages
  ######################################################################

  ##########
  # modern mdoc

  if ( $command =~ /^\.(Dd)$/ ) {
    $Groff{'Dd'}++;		# for modern mdoc
    return;
  }

####### sub do_line
  # In the old version of -mdoc `Oo' is a toggle, in the new it's
  # closed by `Oc'.
  if ( $command =~ /^\.Oc$/ ) {
    $Groff{'Oc'}++;		# only for modern mdoc
    return;
  }


  ##########
  # old and modern mdoc

  if ( $command =~ /^\.Oo$/ ) {
    $Groff{'Oo'}++;		# for mdoc and mdoc-old
    return;
  }


  ##########
  # old mdoc
  if ( $command =~ /^\.(Tp|Dp|De|Cx|Cl)$/ ) {
    $Groff{'mdoc_old'}++;	# true for old mdoc
    return;
  }


  ##########
  # for ms

####### sub do_line
  if ( $command =~ /^\.AB$/ ) {
    $Groff{'AB'}++;		# for ms
    return;
  }
  if ( $command =~ /^\.AE$/ ) {
    $Groff{'AE'}++;		# for ms
    return;
  }
  if ( $command =~ /^\.AI$/ ) {
    $Groff{'AI'}++;		# for ms
    return;
  }
  if ( $command =~ /^\.AU$/ ) {
    $Groff{'AU'}++;		# for ms
    return;
  }
  if ( $command =~ /^\.NH$/ ) {
    $Groff{'NH'}++;		# for ms
    return;
  }
  if ( $command =~ /^\.TL$/ ) {
    $Groff{'TL'}++;		# for ms
    return;
  }
  if ( $command =~ /^\.XP$/ ) {
    $Groff{'XP'}++;		# for ms
    return;
  }


  ##########
  # for man and ms

  if ( $command =~ /^\.IP$/ ) {
    $Groff{'IP'}++;		# for man and ms
    return;
  }
  if ( $command =~ /^\.LP$/ ) {
    $Groff{'LP'}++;		# for man and ms
    return;
  }
####### sub do_line
  if ( $command =~ /^\.P$/ ) {
    $Groff{'P'}++;		# for man and ms
    return;
  }
  if ( $command =~ /^\.PP$/ ) {
    $Groff{'PP'}++;		# for man and ms
    return;
  }
  if ( $command =~ /^\.SH$/ ) {
    $Groff{'SH'}++;		# for man and ms
    return;
  }
  if ( $command =~ /^\.UL$/ ) {
    $Groff{'UL'}++;		# for man and ms
    return;
  }


  ##########
  # for man only

  if ( $command =~ /^\.OP$/ ) {	# for man
    $Groff{'OP'}++;
    return;
  }
  if ( $command =~ /^\.SS$/ ) {	# for man
    $Groff{'SS'}++;
    return;
  }
  if ( $command =~ /^\.SY$/ ) {	# for man
    $Groff{'SY'}++;
    return;
  }
  if ( $command =~ /^\.TH$/ ) {
    $Groff{'TH'}++;		# for man
    return;
  }
  if ( $command =~ /^\.TP$/ ) {	# for man
    $Groff{'TP'}++;
    return;
  }
  if ( $command =~ /^\.UR$/ ) {
    $Groff{'UR'}++;		# for man
    return;
  }
  if ( $command =~ /^\.YS$/ ) {	# for man
   $Groff{'YS'}++;
    return;
  }
####### sub do_line


  ##########
  # me

  if ( $command =~ /^\.(
		      [ilnp]p|
		      sh
		    )$/x ) {
    $Groff{'me'}++;		# for me
    return;
  }


  #############
  # mm and mmse

  if ( $command =~ /^\.(
		      H|
		      MULB|
		      LO|
		      LT|
		      NCOL|
		      P\$|
		      PH|
		      SA
		    )$/x ) {
    $Groff{'mm'}++;		# for mm and mmse
    if ( $command =~ /^\.LO$/ ) {
      if ( $args =~ /^(DNAMN|MDAT|BIL|KOMP|DBET|BET|SIDOR)/ ) {
	$Groff{'mmse'}++;	# for mmse
      }
    } elsif ( $command =~ /^\.LT$/ ) {
      if ( $args =~ /^(SVV|SVH)/ ) {
	$Groff{'mmse'}++;	# for mmse
      }
    }
    return;
  }
####### sub do_line

  ##########
  # mom

  if ( $line =~ /^\.(
		   ALD|
		   DOCTYPE|
		   FAMILY|
		   FT|
		   FAM|
		   LL|
		   LS|
		   NEWPAGE|
		   PAGE|
		   PAPER|
		   PRINTSTYLE|
		   PT_SIZE|
		   T_MARGIN
		 )$/x ) {
    $Groff{'mom'}++;		# for mom
    return;
  }

} # sub do_line


########################################################################
# sub make_groff_line
########################################################################

sub make_groff_line {
  our %File_Name_Extensions;
  our $is_mmse;
  our @filespec;			# stores inout file names

  my @m = ();
  my @preprograms = ();

  # default device when without `-T' is `ps' ($device empty)

  my $device = '';
  for my $d ( @devices ) {
    if ( $d =~			# suitable devices
	 /^(
	    dvi
	  |
	    html
	  |
	    xhtml
	  |
	    lbp
	  |
	    lj4
	  |
	    ps
	  |
	    pdf
	  |
	    ascii
	  |
	    cp1047
	  |
	    latin1
	  |
	    utf8
	  )$/x ) {
###### sub make_groff_line
      if ( $device ) {
	next if ( $device eq $d );
	print STDERR 'several different devices given: ' .
	  $device . ' and ' .$d;
	$device = $d;	# the last provided device is taken
	next;
      } else { # empty $device
	$device = $d;
	next;
      }
    } else {		# not suitable device
      print STDERR 'not a suitable device for groff: ' . $d;
      next;
    }
  }

  if ( $device ) {
    push @Command, '-T';
    push @Command, $device;
  }

  if ( $device eq 'pdf' ) {
    if ( $pdf_with_ligatures ) {	# with --ligature argument
      push( @Command, '-P-y' );
      push( @Command, '-PU' );
    } else {	# no --ligature argument
      if ( $with_warnings ) {
	print STDERR <<EOF;
If you have trouble with ligatures like `fi' in the `groff' output, you
can proceed as one of
- add `grog' option `--with_ligatures' or
- use the `grog' option combination `-P-y -PU' or
- try to remove the font named similar to `fonts-texgyre' from your system.
EOF
      }	# end of warning
    }	# end of ligature
  }	# end of pdf device


###### sub make_groff_line

  ##########
  # preprocessors

  # preprocessors without `groff' option
  if ( $Groff{'lilypond'} ) {
    push @preprograms, 'glilypond';
  }
  if ( $Groff{'gperl'} ) {
    push @preprograms, 'gperl';
  }

  # preprocessors with `groff' option
  if ( ( $Groff{'PS'} ||  $Groff{'PF'} ) &&  $Groff{'PE'} ) {
    $Groff{'pic'} = 1;
  }
  if ( $Groff{'gideal'} ) {
    $Groff{'pic'} = 1;
  }

###### sub make_groff_line
  $Groff{'refer'} ||= $Groff{'refer_open'} && $Groff{'refer_close'};

  if ( $Groff{'chem'} || $Groff{'eqn'} ||  $Groff{'gideal'} ||
       $Groff{'grap'} || $Groff{'grn'} || $Groff{'pic'} ||
       $Groff{'refer'} || $Groff{'tbl'} ) {
    push(@Command, '-e') if $Groff{'eqn'};
    push(@Command, '-G') if $Groff{'grap'};
    push(@Command, '-g') if $Groff{'grn'};
    push(@Command, '-J') if $Groff{'gideal'};
    push(@Command, '-j') if $Groff{'chem'};
    push(@Command, '-p') if $Groff{'pic'};
    push(@Command, '-R') if $Groff{'refer'};
    push(@Command, '-s') if $Groff{'soelim'};
    push(@Command, '-t') if $Groff{'tbl'};
  }


  ######################################################################
  # tmacs
  ######################################################################

  ###########
  # man or ms

  {
    my $is_ms = 0;
    if ( $Groff{'P'} || $Groff{'IP'}  ||
	 $Groff{'LP'} || $Groff{'PP'} || $Groff{'SH'} ) {
      # man or ms
      if ( $Groff{'SS'} ||  $Groff{'SY'} ||  $Groff{'OP'} ||
	   $Groff{'TH'} || $Groff{'TP'} || $Groff{'UR'} ) {
	# it is `man', because these macros are not `ms'
	$Groff{'man'} = 1;
	push(@m, '-man');
      } elsif
	(	# it must now be `ms'
	 $Groff{'1C'} || $Groff{'2C'} ||
	 $Groff{'AB'} || $Groff{'AE'} || $Groff{'AI'} || $Groff{'AU'} ||
	 $Groff{'BX'} || $Groff{'CD'} || $Groff{'DA'} || $Groff{'DE'} ||
	 $Groff{'DS'} || $Groff{'LD'} || $Groff{'ID'} || $Groff{'NH'} ||
	 $Groff{'TL'} || $Groff{'UL'} || $Groff{'XP'}
	) {
	$is_ms = 1;
###### sub make_groff_line
      } else {	# maybe `ms'
	print STDERR 'grog: device -ms assumed without proof.'
	  unless ( $File_Name_Extensions{'ms'} );
	$is_ms = 1;
      }
    }
    if ( $is_ms ) {
      $Groff{'ms'} = 1;
      push(@m, '-ms');
    }
  }


  ##########
  # mdoc

  if ( ( $Groff{'Oo'} && $Groff{'Oc'} ) || $Groff{'Dd'} ) {
    $Groff{'Oc'} = 0;
    $Groff{'Oo'} = 0;
    push(@m, '-mdoc');
  }
  if ( $Groff{'mdoc_old'} || $Groff{'Oo'} ) {
    push(@m, '-mdoc_old');
  }


  ##########
  # me

  if ( $Groff{'me'} ) {
    push(@m, '-me');
  }


  ##########
  # mm and mmse

  if ( $Groff{'mm'} ) {
    if ( $is_mmse ) {	# swedish mmse
      push(@m, '-mmse');
    } else {		# normal mm
      push(@m, '-mm');
    }
  }


  ##########
  # mom

  if ( $Groff{'mom'} ) {
    push(@m, '-mom');
  }

###### sub make_groff_line

  ######################################################################
  # create groff command

  my $file_args_included;	# file args now only at 1st preprog
  unshift @Command, 'groff';
  if ( @preprograms ) {
    my @progs;
    $progs[0] = shift @preprograms;
    push(@progs, @filespec);
    for ( @preprograms ) {
      push @progs, '|';
      push @progs, $_;
    }
    push @progs, '|';
    unshift @Command, @progs;
    $file_args_included = 1;
  } else {
    $file_args_included = 0;
  }

  foreach (@Command) {
    next unless /\s/;
    # when one argument has several words, use accents
    $_ = "'" . $_ . "'";
  }


  ##########
  # -m arguments
  my $nr_m_guessed = scalar @m;
  if ( $nr_m_guessed > 1 ) {
    print STDERR 'More than 1 argument for -m found: ' . "@m";
  }

###### sub make_groff_line

  my $nr_m_args = scalar @Mparams;	# m-arguments for grog
  my $last_m_arg = '';	# last provided -m option
  if ( $nr_m_args > 1 ) {
    # take the last given -m argument of grog call,
    # ignore other -m arguments and the found ones
    $last_m_arg = $Mparams[-1];	# take the last -m argument
    print STDERR $Prog . ": more than 1 `-m' argument: @Mparams";
    print STDERR 'We take the last one: ' . $last_m_arg;
  } elsif ( $nr_m_args == 1 ) {
    $last_m_arg = $Mparams[0];
  }

  my $final_m = '';
  if ( $last_m_arg ) {
    my $is_equal = 0;
    for ( @m ) {
      if ( $_ eq $last_m_arg ) {
	$is_equal = 1;
	last;
      }
      next;
    }	# end for @m
    if ( $is_equal ) {
      $final_m = $last_m_arg;
    } else {
      print STDERR 'Provided -m argument ' . $last_m_arg .
	' differs from guessed -m args: ' . "@m";
      print STDERR 'The argument is taken.';
      $final_m = $last_m_arg;
    }
###### sub make_groff_line
  } else {	# no -m arg provided
    if ( $nr_m_guessed > 1 ) {
      print STDERR 'More than 1 -m arguments were guessed: ' . "@m";
      print STDERR 'Guessing stopped.';
      exit 1;
    } elsif ( $nr_m_guessed == 1 ) {
      $final_m = $m[0];
    } else {
      # no -m provided or guessed
    }
  }
  push @Command, $final_m if ( $final_m );

  push(@Command, @filespec) unless ( $file_args_included );

  #########
  # execute the `groff' command here with option `--run'
  if ( $do_run ) { # with --run
    print STDERR "@Command";
    my $cmd = join ' ', @Command;
    system($cmd);
  } else {
    print "@Command";
  }

  exit 0;
}	# sub &make_groff_line()


########################################################################
# sub help
########################################################################

sub help {
  print <<EOF;
usage: grog [option]... [--] [filespec]...

"filespec" is either the name of an existing, readable file or "-" for
standard input.  If no `filespec' is specified, standard input is
assumed automatically.  All arguments after a `--' are regarded as file
names, even if they start with a `-' character.

`option' is either a `groff' option or one of these:

-h|--help	print this uasge message and exit
-v|--version	print version information and exit

-C		compatibility mode
--ligatures	include options `-P-y -PU' for internal font, which
		preserverses the ligatures like `fi'
--run		run the checked-out groff command
--warnings	display more warnings to standard error

All other options should be `groff' 1-character options.  These are then
appended to the generated `groff' command line.  The `-m' options will
be checked by `grog'.

EOF
  exit 0;
} # sub help


########################################################################
# sub version
########################################################################

sub version {
  our %at_at;
  our $Last_Update;
  print "Perl version of GNU $Prog of $Last_Update " .
    "in groff version " . $at_at{'GROFF_VERSION'};
  exit 0;
} # sub version


1;
########################################################################
### Emacs settings
# Local Variables:
# mode: CPerl
# End:
