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
# Last_Update = '14 Jun 2014';
########################################################################

require v5.6;

use warnings;
use strict;
use File::Spec;

$\ = "\n";

# my $Sp = "[\\s\\n]";
# my $Sp = qr([\s\n]);
# my $Sp = '' if $arg eq '-C';
my $Sp = '';

my @Command;			# stores the final output
my @Mparams;			# stores the options `-m*'
my $do_run = 0;			# run generated `groff' command
my $pdf_with_ligatures = 0;	# `-P-y -PU' for `pdf' device
my $device = '';

our $Prog;

my %macros;
my %Groff = (
	     # preprocessors
	     'chem' => 0,
	     'eqn' => 0,
	     'gperl' => 0,
	     'grap' => 0,
	     'grn' => 0,
	     'ideal' => 0,
	     'lilypond' => 0,
	     'pic' => 0,
	     'refer' => 0,
	     'refer_open' => 0,
	     'refer_close' => 0,
	     'soelim' => 0,
	     'tbl' => 0,

	     # tmacs
	     'man' => 0,
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
	     'XP' => 0,		# ms

	     'IP' => 0,		# man and ms
	     'LP' => 0,		# man and ms
	     'P' => 0,		# man and ms
	     'PP' => 0,		# man and ms
	     'SH' => 0,		# man and ms
	     'TH' => 0,		# man and ms

	     'OP' => 0,		# man
	     'SS' => 0,		# man
	     'SY' => 0,		# man
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

sub args_with_minus {
  my @filespec = ();
  my $double_minus = 0;
  my $was_minus = 0;
  my $was_T = 0;
  my $had_filespec = 0;

  foreach my $arg (@ARGV) {
    next unless $arg;
    if ($double_minus) {
      $had_filespec = 1;
      if (-f $arg && -r $arg) {
	push @filespec, $arg;
      } else {
	print STDERR "grog: $arg is not a readable file.";
      }
      next;
    }

    if ( $was_T ) {
      $was_T = 0;
      $device = $arg;
      next;
    }

    if ( $arg =~ /^--/ ) {

      if ($arg eq '--') {
	$double_minus = 1;
	push(@Command, $arg);
	next;
      }

      &version() if $arg =~ /^--?v/;	# --version, with exit
      &help() if $arg  =~ /--?h/;	# --help, with exit

      if ( $arg =~ /^--?r/ ) {		#  --run, no exit
	$do_run = 1;
	next;
      }

      if ( $arg =~ /^--?w/ ) {		#  --with_ligatures, no exit
	$pdf_with_ligatures = 1;
	next;
      }
    }

    print STDERR "grog: wrong option $arg." if $arg =~ /^--/;

    if ($arg eq '-') {
      unless ($was_minus) {
	push @filespec, $arg;
	$was_minus = 1;
      }
      next;
    }

    if ($arg =~ /^-m/) {
      push @Mparams, $arg;
      next;
    }

    if ($arg =~ /^-T\s*$/) {
      $was_T = 1;
      next;
    }

    if ($arg =~ s/^-T(.+)$/$1/) {
      $device = $arg;
      next;
    }

    if ($arg =~ /^-/) {
      push(@Command, $arg);
      next;
    } else {
      $had_filespec = 1;
      if (-f $arg && -r $arg) {
	push @filespec, $arg;
      } else {
	print STDERR "grog: $arg is not a readable file.";
      }
      next;
    }
  }
  @filespec = ('-') if ! @filespec && ! $had_filespec;
  exit 1 unless @filespec;
  @ARGV = @filespec;
}


########################################################################
# sub do_first_line
########################################################################

# As documented for the `man' program, the first line can be
# used as an groff option line.  This is done by:
# - start the line with '\" (apostrophe, backslash, double quote)
# - add a space character
# - a word using the following characters can be appended: `egGjpRst'.
#     Each of these characters means an option for the generated
#     `groff' command line, e.g. `-t'.

sub do_first_line {
  my ( $line, $file ) = @_;

  # For a leading groff options line use only [egGjpRst]
  if  ( $line =~ /^[.']\\"[\segGjpRst]+&/ ) {
    # this is a groff options leading line
    if ( $line =~ /^\./ ) {
      # line is a groff options line with . instead of '
      print "First line in $file must start with an apostrophe \ " .
	"instead of a period . for groff options line!";
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
      $Groff{'ideal'}++;
    }
    if ( $line =~ /j/ ) {
      $Groff{'chem'}++;
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
    if ( $line =~ /t/ ) {
      $Groff{'tbl'}++;
    }
    return 1;	# a leading groff options line
  } else {
    return 0;	# not a leading groff options line
  }
}	# sub do_first_line


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
    $Groff{'ideal'}++;		# for ideal
    return;
  }
  if ( $command =~ /^\.lilypond$/ ) {
    $Groff{'lilypond'}++;	# for glilypond
    return;
  }
  if ( $command =~ /^\.PS$/ ) {
    $Groff{'pic'}++;		# for gpic
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
  # devices
  ######################################################################

  ##########
  # modern mdoc

  if ( $command =~ /^\.(Dd)$/ ) {
    $Groff{'Dd'}++;		# for modern mdoc
    return;
  }

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
  if ( $command =~ /^\.TH$/ ) {
    $Groff{'TH'}++;		# for man and ms
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
  if ( $command =~ /^\.YS$/ ) {	# for man
   $Groff{'YS'}++;
    return;
  }
  if ( $command =~ /^\.SY$/ ) {	# for man
    $Groff{'SY'}++;
    return;
  }


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
  our @FILES;

  my @m = ();
  my @preprograms = ();

  # device from -T
  $device = '' unless ( defined $device );

  # default device when without `-T' is `ps' ($device empty)

  if ( $device =~
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
	)$/x ) {	# suitable device

    push(@Command, '-T' . $device);	# for all suitable devices

    if ( $device eq 'pdf' ) {
      if ( $pdf_with_ligatures ) {	# with ligature argument
	push( @Command, '-P-y -PU' );
      } else {	# no ligature argument
	print STDERR <<EOF;
If you have trouble with ligatures like `fi' in the `groff' output, you
can proceed as one of
- add `grog' option `--with_ligatures' or
- use the `grog' option combination `-P-y -PU' or
- try to remove the font named similar to `fonts-texgyre' from your system.
EOF
      }	# end of ligature
    }	# end of pdf device
  } else {	# wrong device
    if ( $device ) {
      print STDERR 'The device ' . $device . ' for -T is wrong.';
      $device = '';
    }
  }


  ##########
  # preprocessors

  if ( $Groff{'lilypond'} ) {
    push @preprograms, 'glilypond';
  }
  if ( $Groff{'gperl'} ) {
    push @preprograms, 'gperl';
  }
  $Groff{'refer'} ||= $Groff{'refer_open'} && $Groff{'refer_close'};
  if ( $Groff{'chem'} || $Groff{'eqn'} || $Groff{'grap'} ||
       $Groff{'grn'} || $Groff{'ideal'} || $Groff{'pic'} ||
       $Groff{'refer'} || $Groff{'tbl'} ) {
    my $s = "-";
    $s .= "e" if $Groff{'eqn'};
    $s .= "g" if $Groff{'grn'};
    $s .= "G" if $Groff{'grap'};
    $s .= "i" if $Groff{'ideal'};
    $s .= "j" if $Groff{'chem'};
    $s .= "p" if $Groff{'pic'};
    $s .= "R" if $Groff{'refer'};
    $s .= "s" if $Groff{'soelim'};
    $s .= "t" if $Groff{'tbl'};
    push(@Command, $s);
  }


  ######################################################################
  # tmacs
  ######################################################################

  ###########
  # man or ms

  {
    my $is_ms = 0;
    if ( $Groff{'TH'} || $Groff{'P'} || $Groff{'IP'}  ||
	 $Groff{'LP'} || $Groff{'PP'} || $Groff{'SH'} ) {
      # man or ms
      if ( $Groff{'SS'} ||  $Groff{'SY'} ||  $Groff{'OP'} ) {
	# it is `man', because these macros are not `ms'
	$Groff{'man'} = 1;
	push(@m, '-man');
	push(@Command, '-man');
      } elsif
	(	# it must now be `ms'
	 $Groff{'1C'} || $Groff{'2C'} ||
	 $Groff{'AB'} || $Groff{'AE'} || $Groff{'AI'} || $Groff{'AU'} ||
	 $Groff{'BX'} || $Groff{'CD'} || $Groff{'DA'} || $Groff{'DE'} ||
	 $Groff{'DS'} || $Groff{'LD'} || $Groff{'ID'} || $Groff{'NH'} ||
	 $Groff{'TL'} || $Groff{'UL'} || $Groff{'XP'}
	) {
	$is_ms = 1;
      } else {	# maybe `ms'
	print STDERR 'grog: device -ms assumed without proof.'
	  unless ( $File_Name_Extensions{'ms'} );
	$is_ms = 1;
      }
    }
    if ( $is_ms ) {
      $Groff{'ms'} = 1;
      push(@m, '-ms');
      push(@Command, '-ms');
    }
  }


  ##########
  # mdoc

  if ( ( $Groff{'Oo'} && $Groff{'Oc'} ) || $Groff{'Dd'} ) {
    $Groff{'Oc'} = 0;
    $Groff{'Oo'} = 0;
    push(@m, '-mdoc');
    push(@Command, '-mdoc');
  }
  if ( $Groff{'mdoc_old'} || $Groff{'Oo'} ) {
    push(@m, '-mdoc_old');
    push(@Command, '-mdoc_old');
  }


  ##########
  # me

  if ( $Groff{'me'} ) {
    push(@m, '-me');
    push(@Command, '-me');
  }


  ##########
  # mm and mmse

  if ( $Groff{'mm'} ) {
    if ( $is_mmse ) {	# swedish mmse
      push(@m, '-mmse');
      push(@Command, '-mmse');
    } else {		# normal mm
      push(@m, '-mm');
      push(@Command, '-mm');
    }
  }


  ##########
  # mom

  if ( $Groff{'mom'} ) {
    push(@m, '-mom');
    push(@Command, '-mom');
  }


  ######################################################################
  # create groff command

  @FILES = ( '-' ) unless ( @FILES );

  for (@FILES) {
    print STDERR 'filearg: ' . $_;
  }

  unshift @Command, 'groff';
  if ( @preprograms ) {
    my @progs;
    $progs[0] = shift @preprograms;
    push(@progs, @FILES);
    for ( @preprograms ) {
      push @progs, '|';
      push @progs, $_;
    }
    push @progs, '|';
    unshift @Command, @progs;
  } else {
    push(@Command, @FILES);
  }

  foreach (@Command) {
    next unless /\s/;
    $_ = "'" . $_ . "'";
  }


  my $n = scalar @m;
  my $np = scalar @Mparams;
  print STDERR "$Prog: more than 1 `-m' argument: @Mparams" if $np > 1;
  if ($n == 0) {
    unshift @Command, $Mparams[0] if $np == 1;
  } elsif ($n == 1) {
    if ($np == 1) {
      print STDERR "$Prog: wrong `-m' argument: $Mparams[0]"
	if $m[0] ne $Mparams[0];
    }
  } else {
    print STDERR "$Prog: error: there are several macro packages: @m";
    exit 1;
  }

  # execute the `groff' command here with option `--run'
  if ( $do_run ) {
    print STDERR "@Command";
    my $cmd = join ' ', @Command;
    print 'command will be: ' . $cmd;
    # system($cmd);
  } else {
    print "@Command";
  }

  exit $n if $n > 1;
  exit 0;
}	# sub make_groff_line


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

-h --help		print this uasge message and exit
-v --version		print version information and exit

-C			compatibility mode
--run			run the checked-out groff command
--with_ligatures	include options `-P-y -PU' for internal font,
			which preserverses the ligatures like `fi'

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
