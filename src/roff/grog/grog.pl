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
my $Last_Update = '26 May 2014';
########################################################################

require v5.6;

use warnings;
use strict;
use File::Spec;

$\ = "\n";

my $Prog = $0;
{
  my ($v, $d, $f) = File::Spec->splitpath($Prog);
  $Prog = $f;
}

#my $Sp = "[\\s\\n]";
#my $Sp = qr([\s\n]);
my $Sp = '';

my @Command;			# stores the final output
my @Mparams;			# stores the options -m*
my %Groff = (
	     'chem' => 0,
	     'eqn' => 0,
	     'gperl' => 0,
	     'grap' => 0,
	     'grn' => 0,
	     'lilypond' => 0,
	     'mdoc' => 0,
	     'mdoc_old' => 0,
	     'me' => 0,
	     'mm' => 0,
	     'mom' => 0,
	     'ILP' => 0,
	     'LP' => 0,
	     'NH' => 0,
	     'Oo' => 0,
	     'P' => 0,
	     'PP' => 0,
	     'SH' => 0,
	     'TL' => 0,
	     'TH' => 0,
	     'TL' => 0,
	     'pic' => 0,
	     'refer' => 0,
	     'refer_open' => 0,
	     'refer_close' => 0,
	     'soelim' => 0,
	     'tbl' => 0,
);

{ # command line arguments except file names
  my @filespec = ();
  my $double_minus = 0;
  my $was_minus = 0;
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

    if ($arg eq '--') {
      $double_minus = 1;
      push(@Command, $arg);
      next;
    }
    if ($arg eq '-') {
      unless ($was_minus) {
	push @filespec, $arg;
	$was_minus = 1;
      }
      next;
    }

    &version(0) if $arg eq '-v' || '--version' =~ /^$arg/;
    &help() if $arg eq '-h' || '--help' =~ /^$arg/;
    print STDERR "grog: wrong option $arg." if $arg =~ /^--/;

    if ($arg =~ /^-m/) {
      push @Mparams, $arg;
      next;
    }
    $Sp = '' if $arg eq '-C';

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

foreach my $arg (@ARGV) { # test for each file name in the arguments
  &process($arg, 0);
}

sub process {
  my ($filename, $level) = @_;
  local(*FILE);
  my %macros;
  my $first_line = 1; # we are now in reading the first line

  if (!open(FILE, $filename eq "-" ? $filename : "< $filename")) {
    print STDERR "$Prog: can't open \`$filename': $!";
    exit 1 unless $level;
    return;
  }

  while (<FILE>) {
    chomp;

    s/^[']/./;

    if ( $first_line ) {
      # when first line, test on comment with character set for grog args

      $first_line = 0; # end of first line

      if ( /^\.\\"\s*(.+)$/ ) {
	my $_ = $1;
	if ( /e/ ) {
	  $Groff{'eqn'}++;
	}
	if ( /g/ ) {
	  $Groff{'grn'}++;
	}
	if ( /G/ ) {
	  $Groff{'grap'}++;
	}
	if ( /j/ ) {
	  $Groff{'chem'}++;
	}
	if ( /p/ ) {
	  $Groff{'pic'}++;
	}
	if ( /R/ ) {
	  $Groff{'refer'}++;
	}
	if ( /s/ ) {
	  $Groff{'soelim'}++;
	}
	if ( /t/ ) {
	  $Groff{'tbl'}++;
	}
	next;
      }
    }

    # $first_line no longer needed in the following

    next unless ( /^[.']/ );
    next if ( /^[.']{2}/ );

    s/^['.]\s*/./; # use only a dot as leading character
    s/\s*$//;

    if ( /^\.de1?\W?/ ) {
      # this line is a macro definition, add it to %macros
      my $macro = s/^\.de1?\s+(\w+)\W*/.$1/;
      next if ( exists $macros{$macro} );
      $macros{ $macro } = 1;
      next;
    }

    {
      # if line command is a defined macro, just ignore this line
      my $macro = $_;
      $macro =~ s/^(\.\w+)/$1/;
      next if ( exists $macros{ $macro } );
    }

    if ( /^\.lilypond/ ) {
      $Groff{'lilypond'}++;
      $Groff{'soelim'}++ if $level;
    } elsif ( /^\.Perl/ ) {
      $Groff{'gperl'}++;
      $Groff{'soelim'}++ if $level;
    } elsif (/^(\.cstart)|(begin\s+chem)$/) {
      $Groff{'chem'}++;
      $Groff{'soelim'}++ if $level;
    } elsif (/^\.TS$Sp/) {
      $_ = <FILE>;
      if (!/^\./ || /^\.so/) {
	$Groff{'tbl'}++;
	$Groff{'soelim'}++ if $level;
      }
    } elsif (/^\.EQ$Sp/) {
      $_ = <FILE>;
      if (!/^\./ || /^\.[0-9]/ || /^\.so/) {
	$Groff{'eqn'}++;
	$Groff{'soelim'}++ if $level;
      }
    } elsif (/^\.GS$Sp/) {
      $_ = <FILE>;
      if (!/^\./ || /^\.so/) {
	$Groff{'grn'}++;
	$Groff{'soelim'}++ if $level;
      }
    } elsif (/^\.G1$Sp/) {
      $_ = <FILE>;
      if (!/^\./ || /^\.so/) {
	$Groff{'grap'}++;
	$Groff{'soelim'}++ if $level;
      }
#    } elsif (/^\.PS\Sp([ 0-9.<].*)?$/) {
#      if (/^\.PS\s*<\s*(\S+)/) {
#	$Groff{'pic'}++;
#	$Groff{'soelim'}++ if $level;
#	&process($1, $level);
#      } else {
#	$_ = <FILE>;
#	if (!/^\./ || /^\.ps/ || /^\.so/) {
#	  $Groff{'pic'}++;
#	  $Groff{'soelim'}++ if $level;
#	}
#      }
    } elsif (/^\.PS[\s\n<]/) {
      $Groff{'pic'}++;
      $Groff{'soelim'}++ if $level;
      if (/^\.PS\s*<\s*(\S+)/) {
	&process($1, $level);
      }
    } elsif (/^\.R1$Sp/) {
      $Groff{'refer'}++;
      $Groff{'soelim'}++ if $level;
    } elsif (/^\.\[/) {
      $Groff{'refer_open'}++;
      $Groff{'soelim'}++ if $level;
    } elsif (/^\.\]/) {
      $Groff{'refer_close'}++;
      $Groff{'soelim'}++ if $level;
    } elsif (/^\.NH$Sp/) {
      $Groff{'NH'}++;		# for ms
    } elsif (/^\.TL$Sp/) {
      $Groff{'TL'}++;		# for mm and ms
    } elsif (/^\.PP$Sp/) {
      $Groff{'PP'}++;		# for mom and ms
    } elsif (/^\.[IL]P$Sp/) {
      $Groff{'ILP'}++;		# for man and ms
    } elsif (/^\.P$/) {
      $Groff{'P'}++;
    } elsif (/^\.(PH|SA)$Sp/) {
      $Groff{'mm'}++;
    } elsif (/^\.TH$Sp/) {
      $Groff{'TH'}++;
    } elsif (/^\.SH$Sp/) {
      $Groff{'SH'}++;
    } elsif (/^\.([pnil]p|sh)$Sp/) {
      $Groff{'me'}++;
    } elsif (/^\.Dd$Sp/) {
      $Groff{'mdoc'}++;
    } elsif (/^\.(Tp|Dp|De|Cx|Cl)$Sp/) {
      $Groff{'mdoc_old'} = 1;
    }
    # In the old version of -mdoc `Oo' is a toggle, in the new it's
    # closed by `Oc'.
    elsif (/^\.Oo$Sp/) {
      $Groff{'Oo'}++;
      s/^\.Oo/\. /;
      redo;
    } elsif (/^\..* Oo( |$)/) {
      # The test for `Oo' and `Oc' not starting a line (as allowed by the
      # new implementation of -mdoc) is not complete; it assumes that
      # macro arguments are well behaved, i.e., "" is used within "..." to
      # indicate a doublequote as a string element, and weird features
      # like `.foo a"b' are not used.
      s/\\\".*//;
      s/\"[^\"]*\"//g;
      s/\".*//;
      if (s/ Oo( |$)/ /) {
	$Groff{'Oo'}++;
      }
      redo;
    } elsif (/^\.Oc$Sp/) {
      $Groff{'Oo'}--;
      s/^\.Oc/\. /;
      redo;
    } elsif (/^\..* Oc( |$)/) {
      s/\\\".*//;
      s/\"[^\"]*\"//g;
      s/\".*//;
      if (s/ Oc( |$)/ /) {
	$Groff{'Oo'}--;
      }
      redo;
    } elsif (/^\.(PRINTSTYLE|START)$Sp/) {
      $Groff{'mom'}++;
    }
    if (/^\.so$Sp/) {
      chop;
      s/^.so *//;
      s/\\\".*//;
      s/ .*$//;
      # The next if-clause catches e.g.
      #
      #   .EQ
      #   .so foo
      #   .EN
      #
      # However, the code is not fully correct since it is too generous.
      # Theoretically, we should check for .so only within preprocessor
      # blocks like .EQ/.EN or .TS/.TE; but it doesn't harm if we call
      # soelim even if we don't need to.
      if ( $Groff{'pic'} || $Groff{'tbl'} || $Groff{'eqn'} ||
	   $Groff{'gperl'} ||
	   $Groff{'grn'} || $Groff{'grap'} || $Groff{'refer'} ||
	   $Groff{'refer_open'} || $Groff{'refer_close'} ||
	   $Groff{'chem'} ) {
	$Groff{'soelim'}++;
      }
      &process($_, $level + 1) unless /\\/ || $_ eq "";
    }
  }
  close(FILE);
}

sub help {
  print <<EOF;
usage: grog [option]... [--] [filespec]...

"filespec" is either the name of an existing, readable file or "-" for
standard input.  If no "filespec" is specified, standard input is
assumed automatically.

"option" is either a "groff" option or one of these:

-C            compatibility mode
-h --help     print this uasge message
-v --version  print version information

"groff" options are appended to the output, "-m" options are checked.

EOF
  exit 0;
}

sub version {
  my ($exit_status) = @_;
  print "Perl version of GNU $Prog of $Last_Update " .
    "in groff version " . '@VERSION@';
  exit $exit_status;
}

{
  my @m = ();
  my $is_man = 0;
  my $is_mm = 0;
  my $is_mom = 0;
  my @preprograms = ();

  if ( $Groff{'lilypond'} ) {
    push @preprograms, 'glilypond';
  }

  if ( $Groff{'gperl'} ) {
    push @preprograms, 'gperl';
  }

  $Groff{'refer'} ||= $Groff{'refer_open'} && $Groff{'refer_close'};

  if ( $Groff{'pic'} || $Groff{'tbl'} || $Groff{'eqn'} ||
       $Groff{'grn'} || $Groff{'grap'} || $Groff{'refer'} ||
       $Groff{'chem'} ) {
    my $s = "-";
    $s .= "e" if $Groff{'eqn'};
    $s .= "g" if $Groff{'grn'};
    $s .= "G" if $Groff{'grap'};
    $s .= "j" if $Groff{'chem'};
    $s .= "p" if $Groff{'pic'};
    $s .= "R" if $Groff{'refer'};
    $s .= "s" if $Groff{'soelim'};
    $s .= "t" if $Groff{'tbl'};
    push(@Command, $s);
  }

  if ( $Groff{'me'} ) {
    push(@m, '-me');
    push(@Command, '-me');
  }
  if ( $Groff{'SH'} && $Groff{'TH'} ) {
    push(@m, '-man');
    push(@Command, '-man');
    $is_man = 1;
  }
  if ( $Groff{'mom'} ) {
    push(@m, '-mom');
    push(@Command, '-mom');
    $is_mom = 1;
  }
  if ( $Groff{'mm'} || ($Groff{'P'} && ! $is_man) ) {
    push(@m, '-mm');
    push(@Command, '-mm');
    $is_mm = 1;
  }
  if ( $Groff{'NH'} || ($Groff{'TL'} && ! $is_mm) ||
       ($Groff{'ILP'} && ! $is_man) ||
       ($Groff{'PP'} && ! $is_mom && ! $is_man) ) {
    # .PP occurs in -mom, -man and -ms, .IP and .LP occur in -man and -ms
    push(@m, '-ms');
    push(@Command, '-ms');
  }
  if ( $Groff{'mdoc'} ) {
    my $s = ( $Groff{'mdoc_old'} || $Groff{'Oo'} ) ? '-mdoc-old' : '-mdoc';
    push(@m, $s);
    push(@Command, $s);
  }

  unshift @Command, 'groff';
  if ( @preprograms ) {
    my @progs;
    $progs[0] = shift @preprograms;
    push(@progs, @ARGV);
    for ( @preprograms ) {
      push @progs, '|';
      push @progs, $_;
    }
    push @progs, '|';
    unshift @Command, @progs;
  } else {
    push(@Command, @ARGV);
  }

  foreach (@Command) {
    next unless /\s/;
    $_ = "'" . $_ . "'";
  }

  # We could implement an option to execute the command here.

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
  }

  print "@Command";

  exit $n if $n > 1;
  exit 0;
}

########################################################################
### Emacs settings
# Local Variables:
# mode: CPerl
# End:
