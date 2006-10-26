#! /usr/bin/env perl

# chem - a groff preprocessor for producing chemical structure diagrams

# Source file position: <groff-source>/contrib/chem/chem.pl
# Installed position: <prefix>/bin/chem

# Copyright (C) 2006 Free Software Foundation, Inc.
# Written by Bernd Warken.

# This file is part of `chem', which is part of `groff'.

# `groff' is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# `groff' is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with `groff'; see the files COPYING and LICENSE in the top
# directory of the `groff' source.  If not, write to the Free Software
# Foundation, 51 Franklin St - Fifth Floor, Boston, MA 02110-1301,
# USA.

########################################################################
# settings
########################################################################

my $Program_Version = '0.1.0';
my $Last_Update = '26 Oct 2006';

# this setting of the groff version is only used before make is run,
# otherwise @VERSION@ will set it.
my $Groff_Version_Preset='1.19.3preset';

# test on Perl version
require v5.6;


########################################################################
# begin
########################################################################

use warnings;
use strict;
use Math::Trig;

# for catfile()
use File::Spec;

# $Bin is the directory where this script is located
use FindBin;

my $Chem_Name;
my $Groff_Version;
my $File_macros_pic;
my $File_pic_tmac;

BEGIN {
  {
    my $before_make;		# script before run of `make'
    {
      my $at = '@';
      $before_make = 1 if '@VERSION@' eq "${at}VERSION${at}";
    }

    my %at_at;
    my $chem_libdir;

    if ($before_make) {
      my $chem_dir = $FindBin::Bin;
      $at_at{'BINDIR'} = $chem_dir;
      $at_at{'G'} = '';
      $at_at{'LIBDIR'} = '';
      $chem_libdir = $chem_dir;
      $File_macros_pic = File::Spec->catfile($chem_dir, 'macros.pic');
      $File_pic_tmac = File::Spec->catfile($chem_dir, 'pic.tmac');
      $Groff_Version = '';
      $Chem_Name = 'chem';
    } else {
      $Groff_Version = '@VERSION@';
      $at_at{'BINDIR'} = '@BINDIR@';
      $at_at{'G'} = '@g@';
      $at_at{'LIBDIR'} = '@libdir@';
      $chem_libdir =
	File::Spec->catdir($at_at{'LIBDIR'}, 'groff', 'chem');
      $File_macros_pic = File::Spec->catfile($chem_libdir, 'macros.pic');
      $File_pic_tmac = File::Spec->catfile($chem_libdir, 'pic.tmac');
      $Chem_Name = $at_at{'G'} . 'chem';
    }
  }
}


########################################################################
# check the parameters
########################################################################

if (@ARGV) {
  # process any FOO=bar switches
  # eval '$'.$1.'$2;' while $ARGV[0] =~ /^([A-Za-z_0-9]+=)(.*)/ && shift;
  my @filespec = ();
  my $dbl_minus;
  my $wrong;
  foreach (@ARGV) {
    next unless $_;
    if (/=/) {
      # ignore FOO=bar switches
      push @filespec, $_ if -f;
      next;
    }
    if ($dbl_minus) {
      if (-f $_) {
	push @filespec, $_;
      } else {
	warn "chem: argument $_ is not an existing file.\n";
	$wrong = 1;
      }
      next;
    }
    if (/^--$/) {
      $dbl_minus = 1;
      next;
    }
    if (/^-$/) {
      push @filespec, $_;
      next;
    }
    if (/^-h$/ or '--help' =~ /^$_/) {
      &usage();
      exit 0;
    }
    if (/^-v$/ or '--version' =~ /^$_/) {
      &version();
      exit 0;
    }
    if (-f $_) {
      push @filespec, $_;
    } else {
      $wrong = 1;
      if (/^-/) {
	warn "chem: wrong option ${_}.\n";
      } else {
	warn "chem: argument $_ is not an existing file.\n";
      }
    }
  }
  if (@filespec) {
    @ARGV = @filespec;
  } else {
    exit 0 if $wrong;
    @ARGV = ('-');
  }
} else {			# @ARGV is empty
  @ARGV = ('-') unless @ARGV;
}


########################################################################
# main process
########################################################################

my %dc = ( 'up' => 0, 'right' => 90, 'down' => 180, 'left' => 270,
	   'ne' => 45, 'se' => 135, 'sw' => 225, 'nw' => 315,
	   0 => 'n', 90 => 'e', 180 => 's', 270 => 'w',
	   30 => 'ne', 45 => 'ne', 60 => 'ne',
	   120 => 'se', 135 => 'se', 150 => 'se',
	   210 => 'sw', 225 => 'sw', 240 => 'sw',
	   300 => 'nw', 315 => 'nw', 330 => 'nw',
	 );
my $RSTART;

my $Word_Count;
my @Words;

my $Line_No;
my $Last_Name = '';

# from init()
my $First_Time = 1;
my $RING;
my $MOL;
my $BOND;
my $OTHER;
my $Last;
my $Dir;			# direction

# from setparams()
my $lineht;
my $linewid;
my $textht;
my $db;
my $cwid;
my $cr;
my $crh;
my $crw;
my $dav;
my $dew;
my $ringside;
my $dbrack;

# from ring()
my $nput;
my $aromatic;
my %put;
my %dbl;

my %labtype;

my $File_Name = '';

&main();

{
  my $is_pic = '';
  my $is_chem = '';
  my $former_line = '';

  ##########
  # main()
  #
  sub main {
    my $count_minus = 0;
    my @stdin = ();
    my $stdin = 0;
    foreach (@ARGV) {
      $count_minus++ if /^-$/;
    }
    foreach my $arg (@ARGV) {
      &setparams(1.0);
      next unless $arg;
      $Line_No = 0;
      $is_pic = '';
      $is_chem = '';
      # for centralizing the pic code
      open TMAC, "<$File_pic_tmac";
      print <TMAC>;
      close TMAC;
      if ($arg eq '-') {
	$File_Name = 'standard input';
	if ($stdin) {
	  &main_line($_) foreach @stdin;
	} else {
	  $stdin = 1;
	  if ($count_minus <= 1) {
	    while (<STDIN>) {
	      &main_line($_);
	    }
	  } else {
	    @stdin = ();
	    while (<STDIN>) {
	      push @stdin, $_;
	      &main_line($_);
	    }
	  }
	}
### main()
      } else {			# $arg is not -
	$File_Name = $arg;
	open FILE, "<$arg";
	&main_line($_) while <FILE>;
	close FILE;
      }				# if $arg
      if ($is_pic) {
	printf ".PE\n";
      }
    }
  } # main()


  ##########
  # main_line()
  #
  sub main_line {
    my $line = $_[0];
    my $stack;
    $Line_No++;
    chomp $line;

    $line = $former_line . $line if $former_line;
    if ($line =~ /^(.*)\\$/) {
      $former_line = $1;
      return 1;
    } else {
      $former_line = '';
    }

    {
      my $s = $line;
      $s =~ s/^\s+//;
      $s =~ s/\s+$//;
      return 1 unless $s;
      @Words = split(/\s+/, $s);
      return 1 unless @Words;
      foreach my $i (0..$#Words) {
	if ($Words[$i] =~ /^\s*#/) {
	  $#Words = $i - 1;
	  last;
	}
      }
      return 1 unless @Words;
    }

    if ($line =~ /^([\.']\s*PS\s*)|([\.']\s*PS\s.+)$/) {
      # .PS
      unless ($is_pic) {
	$is_pic = 'running';
	print "$line\n";
      }
      return 1;
    }
### main_line()
    if ( $line =~ /^([\.']\s*PE\s*)|([\.']\s*PE\s.+)$/ ) {
      # .PE
      $is_chem = '';
      if ($is_pic) {
	$is_pic = '';
	print "$line\n";
      }
      return 1;
    }
    if ($line =~ /^[\.']\s*cstart\s*$/) {
      # line: `.cstart'
      if ($is_chem) {
	&error("additional `.cstart'; chem is already active.");
	return 1;
      }
      unless ($is_pic) {
	&print_ps();
	$is_pic = 'by chem';
      }
      $is_chem = '.cstart';
      &init();
      return 1;
    }
### main_line()
    if ($line =~ /^\s*begin\s+chem\s*$/) {
      # line: `begin chem'
      if ($is_pic) {
	if ($is_chem) {
	  &error("additional `begin chem'; chem is already active.");
	  return 1;
	}
	$is_chem = 'begin chem';
	&init();
      } else {
	print "$line\n";
      }
      return 1;
    }
    if ($line =~ /^[\.']\s*cend\s*/) {
      # line `.cend'
      if ($is_chem) {
	&error("you end chem with `.cend', but started it with `begin chem'.")
	  if $is_chem eq 'begin chem';
	if ($is_pic eq 'by chem') {
	  &print_pe();
	  $is_pic = '';
	}
	$is_chem = '';
      } else {
	print "$line\n";
      }
      return 1;
    }
    if ($line =~ /^\s*end\s*$/) {
      # line: `end'
      if ($is_chem) {
	&error("you end chem with `end', but started it with `.cstart'.")
	  if $is_chem eq '.cstart';
	if ($is_pic eq 'by chem') {
	  &print_pe();
	  $is_pic = '';
	}
	$is_chem = '';
      } else {
	print "$line\n";
      }
      return 1;
    }

### main_line()
    if (! $is_chem) {
      print "$line\n";
      return 1;
    }
    if ($line =~ /^[.']/) {
      # groff request line
      print "$line\n";
      return 1;
    }
    if ($Words[0] eq 'pic') {
      # pic pass-thru
      return 1 if $#Words == 0;
      my $s = $line;
      $s =~ /^\s*pic\s*(.*)$/;
      $s = $1;
      print "$s\n" if $s;
      return 1;
    }
    if ($Words[0] eq 'textht') {
      if ($#Words == 0) {
	&error("`textht' needs a single argument.");
	return 0;
      }
      &error("only the last argument is taken for `textht', " .
	     "all others are ignored.")
	unless $#Words <= 1 or ($#Words == 2 && $Words[1] =~ /^=/);
      $textht = $Words[$#Words];
      return 1;
    }
### main_line()
    if ($Words[0] eq 'cwid') {
      if ($#Words == 0) {
	&error("`cwid' needs a single argument.");
	return 0;
      }
      &error("only the last argument is taken for `cwid', " .
	     "all others are ignored.")
	unless $#Words <= 1 or ($#Words == 2 && $Words[1] =~ /^=/);
      $cwid = $Words[$#Words];
      return 1;
    }
    if ($Words[0] eq 'db') {
      if ($#Words == 0) {
	&error("`db' needs a single argument.");
	return 0;
      }
      &error("only the last argument is taken for `db', " .
	     "all others are ignored.")
	unless $#Words <= 1 or ($#Words == 2 && $Words[1] =~ /^=/);
      $db = $Words[$#Words];
      return 1;
    }
    if ($Words[0] eq 'size') {
      my $size;
      if ($#Words == 0) {
	&error("`size' needs a single argument.");
	return 0;
      }
      &error("only the last argument is taken for `size', " .
	     "all others are ignored.")
	unless $#Words <= 1 or ($#Words == 2 && $Words[1] =~ /^=/);
      if ($Words[$#Words] <= 4) {
	$size = $Words[$#Words];
      } else {
	$size = $Words[$#Words] / 10;
      }
      &setparams($size);
      return 1;
    }

### main_line()
    print "\n#", $line, "\n";  		      # debugging, etc.
    $Last_Name = '';

    if ($Words[0] =~ /^[A-Z].*:$/) {
      # label;  falls thru after shifting left
      $Last_Name = $Words[0];
      $Last_Name =~ s/:$//;
      print "$Words[0]\n";
      shift @Words;
    }

    if ($Words[0] =~ /^"/) {
      print 'Last: ', $line, "\n";
      $Last = $OTHER;
      return 1;
    }

    if ($Words[0] =~ /bond/) {
      &bond($Words[0]);
      return 1;
    }

    if ($#Words >= 1) {
      if ($Words[0] =~ /^(double|triple|front|back)$/ &&
	  $Words[1] eq 'bond') {
	@Words = ($Words[0] . $Words[1], @Words[2..$#Words]);
	&bond($Words[0]);
	return 1;
      }

      if ($Words[0] eq 'aromatic') {
	my $temp = $Words[0];
	$Words[0] = $Words[1] ? $Words[1] : '';
	$Words[1] = $temp;
      }
    }

    if ($Words[0] =~ /ring|benz/) {
      &ring($Words[0]);
      return 1;
    }
    if ($Words[0] eq 'methyl') {
      # left here as an example
      $Words[0] = 'CH3';
    }
### main_line()
    if ($Words[0] =~ /^[A-Z]/) {
      &molecule();
      return 1;
    }
    if ($Words[0] eq 'left') {
      my %left;			# not used
      $left{++$stack} = &fields(1, $#Words);
      printf (("Last: [\n"));
      return 1;
    }
    if ($Words[0] eq 'right') {
      &bracket();
      $stack--;
      return 1;
    }
    if ($Words[0] eq 'label') {
      &label();
      return 1;
    }
    if (/./) {
      print 'Last: ', $line, "\n";
      $Last = $OTHER;
    }
    1;
  } # main_line()

}

########################################################################
# functions
########################################################################

##########
# atom(<string>)
#
sub atom {
  # convert CH3 to atom(...)
  my ($s) = @_;
  my ($i, $n, $nsub, $cloc, $nsubc, @s);
  if ($s eq "\"\"") {
    return $s;
  }
  $n = length($s);
  $nsub = $nsubc = 0;
  $cloc = index($s, 'C');
  if (! defined($cloc) || $cloc < 0) {
    $cloc = 0;
  }
  @s = split('', $s);
  $i = 0;
  foreach (@s) {
    unless (/[A-Z]/) {
      $nsub++;
      $nsubc++ if $i < $cloc;
      $i++;
    }
  }
  $s =~ s/([0-9]+\.[0-9]+)|([0-9]+)/\\s-3\\d$&\\u\\s+3/g;
  if ($s =~ /([^0-9]\.)|(\.[^0-9])/) { # centered dot
    $s =~ s/\./\\v#-.3m#.\\v#.3m#/g;
  }
  sprintf( "atom(\"%s\", %g, %g, %g, %g, %g, %g)",
	   $s, ($n - $nsub / 2) * $cwid, $textht,
	   ($cloc - $nsubc / 2 + 0.5) * $cwid, $crh, $crw, $dav
	 );
} # atom()


##########
# bond(<type>)
#
sub bond {
  my ($type) = @_;
  my ($i, $goes, $from, $leng);
  $goes = '';
  for ($i = 1; $i <= $#Words; $i++) {
    if ($Words[$i] eq ';') {
      &error("a colon `;' must be followed by a space and a single word.")
       if $i != $#Words - 1;
      $goes = $Words[$i + 1] if $#Words > $i;
      $#Words = $i - 1;
      last;
    }
  }
  $leng = $db;
  $from = '';
  for ($Word_Count = 1; $Word_Count <= $#Words; ) {
    if ($Words[$Word_Count] =~
	/(\+|-)?[0-9]+|up|down|right|left|ne|se|nw|sw/) {
      $Dir = &cvtdir($Dir);
    } elsif ($Words[$Word_Count] =~ /^leng/) {
      $leng = $Words[$Word_Count + 1] if $#Words > $Word_Count;
      $Word_Count += 2;
    } elsif ($Words[$Word_Count] eq 'to') {
      $leng = 0;
      $from = &fields($Word_Count, $#Words);
      last;
    } elsif ($Words[$Word_Count] eq 'from') {
      $from = &dofrom();
      last;
    } elsif ($Words[$Word_Count] =~ /^#/) {
      $Word_Count = $#Words + 1;
      last;
    } else {
      $from = &fields($Word_Count, $#Words);
      last;
    }
  }
### bond()
  if ($from =~ /( to )|^to/) {	# said "from ... to ...", so zap length
    $leng = 0;
  } elsif (! $from) {		# no from given at all
    $from = 'from Last.' . &leave($Last, $Dir) . ' ' .
      &fields($Word_Count, $#Words);
  }
  printf "Last: %s(%g, %g, %s)\n", $type, $leng, $Dir, $from;
  $Last = $BOND;
  if ($Last_Name) {
    &labsave($Last_Name, $Last, $Dir);
  }
  if ($goes) {
    @Words = ($goes);
    &molecule();
  }
} # bond()


##########
# bracket()
#
sub bracket {
  my $t;
  printf (("]\n"));
  if ($Words[1] && $Words[1] eq ')') {
    $t = 'spline';
  } else {
    $t = 'line';
  }
  printf "%s from last [].sw+(%g,0) to last [].sw to last [].nw to last " .
    "[].nw+(%g,0)\n", $t, $dbrack, $dbrack;
  printf "%s from last [].se-(%g,0) to last [].se to last [].ne to last " .
    "[].ne-(%g,0)\n", $t, $dbrack, $dbrack;
  if ($Words[2] && $Words[2] eq 'sub') {
    printf "\" %s\" ljust at last [].se\n", &fields(3, $#Words);
  }
} # bracket()


##########
# corner(<dir>)
#
sub corner {
  my ($d) = @_;
  $dc{&reduce(45 * int(($d + 22.5) / 45))};
} # corner()


##########
# cvtdir(<dir>)
#
sub cvtdir {
  my ($d) = @_;
  # maps "[pointing] somewhere" to degrees
  if ($Words[$Word_Count] eq 'pointing') {
    $Word_Count++;
  }
  if ($Words[$Word_Count] =~ /^[+\\-]?[0-9]+/) {
    return &reduce($Words[$Word_Count++]);
  } elsif ($Words[$Word_Count] =~ /left|right|up|down|ne|nw|se|sw/) {
    return &reduce($dc{$Words[$Word_Count++]});
  } else {
    $Word_Count++;
    return $d;
  }
} # cvtdir()


##########
# dblring(<v>)
#
sub dblring {
  my ($v) = @_;
  my ($d, $v1, $v2);
  # should canonicalize to i,i+1 mod v
  $d = $Words[$Word_Count];
  for ($Word_Count++; $Word_Count <= $#Words &&
       $Words[$Word_Count] =~ /^[1-9]/; $Word_Count++) {
    $v1 = substr($Words[$Word_Count], 0, 1);
    $v2 = substr($Words[$Word_Count], 2, 1);
    if ($v2 == $v1 + 1 || $v1 == $v && $v2 == 1) { # e.g., 2,3 or 5,1
      $dbl{$v1} = $d;
    } elsif ($v1 == $v2 + 1 || $v2 == $v && $v1 == 1) {	# e.g., 3,2 or 1,5
      $dbl{$v2} = $d;
    } else {
      &error(sprintf("weird %s bond in\n\t%s", $d, $_));
    }
  }
} # dblring()


##########
# dofrom()
#
sub dofrom {
  my $n;
  $Word_Count++;			# skip "from"
  $n = $Words[$Word_Count];
  if (defined $labtype{$n}) {	# "from Thing" => "from Thing.V.s"
    return 'from ' . $n . '.' . &leave($labtype{$n}, $Dir);
  }
  if ($n =~ /^\.[A-Z]/) {	# "from .V" => "from Last.V.s"
    return 'from Last' . $n . '.' . &corner($Dir);
  }
  if ($n =~ /^[A-Z][^.]*\.[A-Z][^.]*$/) { # "from X.V" => "from X.V.s"
    return 'from ' . $n . '.' . &corner($Dir);
  }
  &fields($Word_Count - 1, $#Words);
} # dofrom()


##########
# error(<string>)
#
sub error {
  my ($s) = @_;
  printf STDERR "chem: error in %s on line %d: %s\n",
    $File_Name, $Line_No, $s;
} # error()


##########
# fields(<n1>, <n2>)
#
sub fields {
  my ($n1, $n2) = @_;
  my ($i, $s);
  if ($n1 > $n2) {
    return '';
  }
  $s = '';
  for ($i = $n1; $i <= $n2; $i++) {
    if ($Words[$i] =~ /^#/) {
      last;
    }
    $s = $s . $Words[$i] . ' ';
  }
  $s;
} # fields()


##########
# init()
#
sub init {
  if ($First_Time) {
    printf "copy \"%s\"\n", $File_macros_pic;
    printf "\ttextht = %g; textwid = .1; cwid = %g\n", $textht, $cwid;
    printf "\tlineht = %g; linewid = %g\n", $lineht, $linewid;
    $First_Time = 0;
  }
  printf "Last: 0,0\n";
  $RING = 'R';
  $MOL = 'M';
  $BOND = 'B';
  $OTHER = 'O';			# manifests
  $Last = $OTHER;
  $Dir = 90;
} # init()


##########
# joinring(<type>, <dir>, <last>)
#
sub joinring {
  my ($type, $d, $last) = @_;
  # join a ring to something
  if (substr($last, 0, 1) eq $RING) {
    # ring to ring
    if (substr($type, 2) eq substr($last, 2)) {	# fails if not 6-sided
      return 'with .V6 at Last.V2';
    }
  }
  # if all else fails
  sprintf('with .%s at Last.%s',
	  &leave($type, $d + 180), &leave($last, $d));
} # joinring()


##########
# label()
#
sub label {
  my ($i, $v);
  if (! exists $labtype{$Words[1]} or ! $RING or
      substr($labtype{$Words[1]}, 0, 1) ne $RING) {
    &error(sprintf('%s is not a ring', $Words[1]));
  } else {
    $v = substr($labtype{$Words[1]}, 1, 1);
    $Words[1] = '' unless $Words[1];
    for ($i = 1; $i <= $v; $i++) {
      printf "\"\\s-3%d\\s0\" at 0.%d<%s.C,%s.V%d>\n", $i, $v + 2,
	$Words[1], $Words[1], $i;
    }
  }
} # label()


##########
# labsave(<name>, <type>, <dir>)
#
sub labsave {
  my ($name, $type, $d) = @_;
  $labtype{$name} = $type;
#  $labdir{$name} = $d;
} # labsave()


##########
# leave(<last>, <d>)
#
sub leave {
  my ($last, $d) = @_;
  my ($c, $c1);
  # return vertex of last in dir d
  if ($last eq $BOND) {
    return 'end';
  }
  $d = &reduce($d);
  if (substr($last, 0, 1) eq $RING) {
    return &ringleave($last, $d);
  }
  if ($last eq $MOL) {
    if ($d == 0 || $d == 180) {
      $c = 'C';
    } elsif ($d > 0 && $d < 180) {
      $c = 'R';
    } else {
      $c = 'L';
    }
    if (defined $dc{$d}) {
      $c1 = $dc{$d};
    } else {
      $c1 = &corner($d);
    }
    return sprintf('%s.%s', $c, $c1);
  }
  if ($last eq $OTHER) {
    return &corner($d);
  }
  'c';
} # leave()


##########
# makering(<type>, <pt>, <v>)
#
sub makering {
  my ($type, $pt, $v) = @_;
  my ($i, $j, $a, $r, $rat, $fix, $c1, $c2);
  if ($type =~ /flat/) {
    $v = 6;
    # vertices
    ;
  }
  $r = $ringside / (2 * sin(pi / $v));
  printf "\tC: 0,0\n";
  for ($i = 0; $i <= $v + 1; $i++) {
    $a = (($i - 1) / $v * 360 + $pt) / 57.29578; # 57. is $deg
    printf "\tV%d: (%g,%g)\n", $i, $r * sin($a), $r * cos($a);
  }
  if ($type =~ /flat/) {
    printf "\tV4: V5; V5: V6\n";
    $v = 5;
  }
  # sides
  if ($nput > 0) {
    # hetero ...
    for ($i = 1; $i <= $v; $i++) {
      $c1 = $c2 = 0;
      if ($put{$i} ne '') {
	printf "\tV%d: ellipse invis ht %g wid %g at V%d\n",
	  $i, $crh, $crw, $i;
	printf "\t%s at V%d\n", $put{$i}, $i;
	$c1 = $cr;
      }
      $j = $i + 1;
      if ($j > $v) {
	$j = 1;
      }
### makering()
      if ($put{$j} ne '') {
	$c2 = $cr;
      }
      printf "\tline from V%d to V%d chop %g chop %g\n", $i, $j, $c1, $c2;
      if ($dbl{$i} ne '') {
	# should check i<j
	if ($type =~ /flat/ && $i == 3) {
	  $rat = 0.75;
	  $fix = 5;
	} else {
	  $rat = 0.85;
	  $fix = 1.5;
	}
	if ($put{$i} eq '') {
	  $c1 = 0;
	} else {
	  $c1 = $cr / $fix;
	}
	if ($put{$j} eq '') {
	  $c2 = 0;
	} else {
	  $c2 = $cr / $fix;
	}
	printf "\tline from %g<C,V%d> to %g<C,V%d> chop %g chop %g\n",
	  $rat, $i, $rat, $j, $c1, $c2;
	if ($dbl{$i} eq 'triple') {
	  printf "\tline from %g<C,V%d> to %g<C,V%d> chop %g chop %g\n",
	    2 - $rat, $i, 2 - $rat, $j, $c1, $c2;
	}
      }
    }
### makering()
  } else {
    # regular
    for ($i = 1; $i <= $v; $i++) {
      $j = $i + 1;
      if ($j > $v) {
	$j = 1;
      }
      printf "\tline from V%d to V%d\n", $i, $j;
      if ($dbl{$i} ne '') {
	# should check i<j
	if ($type =~ /flat/ && $i == 3) {
	  $rat = 0.75;
	} else {
	  $rat = 0.85;
	}
	printf "\tline from %g<C,V%d> to %g<C,V%d>\n",
	  $rat, $i, $rat, $j;
	if ($dbl{$i} eq 'triple') {
	  printf "\tline from %g<C,V%d> to %g<C,V%d>\n",
	    2 - $rat, $i, 2 - $rat, $j;
	}
      }
    }
  }
### makering()
  # punt on triple temporarily
  # circle
  if ($type =~ /benz/ || $aromatic > 0) {
    if ($type =~ /flat/) {
      $r *= .4;
    } else {
      $r *= .5;
    }
    printf "\tcircle rad %g at 0,0\n", $r;
  }
} # makering()


##########
# molecule()
#
sub molecule {
  my ($n, $type);
  if ($#Words >= 0) {
    $n = $Words[0];
    if ($n eq 'BP') {
      $Words[0] = "\"\" ht 0 wid 0";
      $type = $OTHER;
    } else {
      $Words[0] = &atom($n);
      $type = $MOL;
    }
  }
  $n =~ s/[^A-Za-z0-9]//g;	# for stuff like C(OH3): zap non-alnum
  if ($#Words < 1) {
    printf "Last: %s: %s with .%s at Last.%s\n",
      $n, join(' ', @Words), &leave($type, $Dir + 180), &leave($Last, $Dir);
### molecule()
  } else {
    if (! $Words[1]) {
      printf "Last: %s: %s with .%s at Last.%s\n",
	$n, join(' ', @Words), &leave($type, $Dir + 180), &leave($Last, $Dir);
    } elsif ($#Words >= 1 and $Words[1] eq 'below') {
      $Words[2] = '' if ! $Words[2];
      printf "Last: %s: %s with .n at %s.s\n", $n, $Words[0], $Words[2];
    } elsif ($#Words >= 1 and $Words[1] eq 'above') {
      $Words[2] = '' if ! $Words[2];
      printf "Last: %s: %s with .s at %s.n\n", $n, $Words[0], $Words[2];
    } elsif ($#Words >= 2 and $Words[1] eq 'left' && $Words[2] eq 'of') {
      $Words[3] = '' if ! $Words[3];
      printf "Last: %s: %s with .e at %s.w+(%g,0)\n",
	$n, $Words[0], $Words[3], $dew;
    } elsif ($#Words >= 2 and $Words[1] eq 'right' && $Words[2] eq 'of') {
      $Words[3] = '' if ! $Words[3];
      printf "Last: %s: %s with .w at %s.e-(%g,0)\n",
	$n, $Words[0], $Words[3], $dew;
    } else {
      printf "Last: %s: %s\n", $n, join(' ', @Words);
    }
  }

  $Last = $type;
  if ($Last_Name) {
    &labsave($Last_Name, $Last, $Dir);
  }
  &labsave($n, $Last, $Dir);
} # molecule()


##########
# print_hash(<hash_or_ref>)
#
# print the elements of a hash or hash reference
#
sub print_hash {
  my $hr;
  my $n = scalar @_;
  if ($n == 0) {
    print STDERR "empty hash\n;";
    return 1;
  } elsif ($n == 1) {
    if (ref($_[0]) eq 'HASH') {
      $hr = $_[0];
    } else {
      warn 'print_hash(): the argument is not a hash or hash reference;';
      return 0;
    }
  } else {
    if ($n % 2) {
      warn 'print_hash(): the arguments are not a hash;';
      return 0;
    } else {
      my %h = @_;
      $hr = \%h;
    }
  }

### print_hash()
  unless (%$hr) {
    print STDERR "empty hash\n";
    return 1;
  }
  print STDERR "hash (ignore the ^ characters):\n";
  for my $k (sort keys %$hr) {
    my $hk = $hr->{$k};
    print STDERR "  $k => ";
    if (defined $hk) {
      print STDERR "^$hk^";
    } else {
      print STDERR "undef";
    }
    print STDERR "\n";
  }

  1;
}				# print_hash()


##########
# print_pe()
#
sub print_pe {
  print ".PE\n";
} # print_pe()


##########
# print_ps()
#
sub print_ps {
  print ".PS\n";
} # print_ps()

##########
# putring(<v>)
#
sub putring {
  # collect "put Mol at n"
  my ($v) = @_;
  my ($m, $mol, $n);
  $Word_Count++;
  $mol = $Words[$Word_Count++];
  if ($Words[$Word_Count] eq 'at') {
    $Word_Count++;
  }
  $n = $Words[$Word_Count];
  if ($n !~ /^\d+$/) {
    $n =~ s/(\d)+$/$1/;
    $n = 0 if $n !~ /^\d+$/;
    error('use single digit as argument for "put at"');
  }
  if ($n >= 1 && $n <= $v) {
    $m = $mol;
    $m =~ s/[^A-Za-z0-9]//g;
    $put{$n} = $m . ':' . &atom($mol);
  } elsif ($n == 0) {
    error('argument of "put at" must be a single digit');
  } else {
    error('argument of "put at" is too large');
  }
  $Word_Count++;
} # putring()


##########
# reduce(<d>)
#
sub reduce {
  my ($d) = @_;
  # reduces d to 0 <= d < 360
  while ($d >= 360) {
    $d -= 360;
  }
  while ($d < 0) {
    $d += 360;
  }
  $d;
} # reduce()


##########
# ring(<type>)
#
sub ring {
  my ($type) = @_;
  my ($typeint, $pt, $verts, $i, $other, $fused, $withat);
  $pt = 0;			# points up by default
  if ($type =~ /([1-8])$/) {
    $verts = $1;
  } elsif ($type =~ /flat/) {
    $verts = 5;
  } else {
    $verts = 6;
  }
  $fused = $other = '';
  for ($i = 1; $i <= $verts; $i++) {
    $put{$i} = $dbl{$i} = '';
  }
  $nput = $aromatic = $withat = 0;
  for ($Word_Count = 1; $Word_Count <= $#Words; ) {
    if ($Words[$Word_Count] eq 'pointing') {
      $pt = &cvtdir(0);
    } elsif ($Words[$Word_Count] eq 'double' ||
	     $Words[$Word_Count] eq 'triple') {
      &dblring($verts);
    } elsif ($Words[$Word_Count] =~ /arom/) {
      $aromatic++;
      $Word_Count++;		# handled later
### ring()
    } elsif ($Words[$Word_Count] eq 'put') {
      &putring($verts);
      $nput++;
    } elsif ($Words[$Word_Count] =~ /^#/) {
      $Word_Count = $#Words + 1;
      last;
    } else {
      if ($Words[$Word_Count] eq 'with' || $Words[$Word_Count] eq 'at') {
	$withat = 1;
      }
      $other = $other . ' ' . $Words[$Word_Count];
      $Word_Count++;
    }
  }
  $typeint = $RING . $verts . $pt; # RING | verts | dir
  if ($withat == 0) {
    $fused = &joinring($typeint, $Dir, $Last);
  }
  printf "Last: [\n";
  &makering($type, $pt, $verts);
  printf "] %s %s\n", $fused, $other;
  $Last = $typeint;
  if ($Last_Name) {
    &labsave($Last_Name, $Last, $Dir);
  }
} # ring()


##########
# ringleave(<last>, <d>)
#
sub ringleave {
  my ($last, $d) = @_;
  my ($rd, $verts);
  # return vertex of ring in dir d
  $verts = substr($last, 1, 1);
  $rd = substr($last, 2);
  sprintf('V%d.%s', int(&reduce($d - $rd) / (360 / $verts)) + 1, &corner($d));
} # ringleave()


##########
# setparams(<scale>)
#
sub setparams {
  my ($scale) = @_;
  $lineht = $scale * 0.2;
  $linewid = $scale * 0.2;
  $textht = $scale * 0.16;
  $db = $scale * 0.2;		# bond length
  $cwid = $scale * 0.12;	# character width
  $cr = $scale * 0.08;		# rad of invis circles at ring vertices
  $crh = $scale * 0.16;		# ht of invis ellipse at ring vertices
  $crw = $scale * 0.12;		# wid	
  $dav = $scale * 0.015;	# vertical shift up for atoms in atom macro
  $dew = $scale * 0.02;		# east-west shift for left of/right of
  $ringside = $scale * 0.3;	# side of all rings
  $dbrack = $scale * 0.1;	# length of bottom of bracket
} # setparams()


##########
# usage()
#
# Print usage information for --help.
#
sub usage {
  print "\n";
  &version();
  print <<EOF;

Usage: $Chem_Name [option]... [filespec]...

$Chem_Name is a groff preprocessor for producing chemical structure
diagrams.  The output suits to the pic preprocessor.

"filespec" is one of
  "filename"       name of a readable file
  "-"              for standard input

All available options are

-h --help         print this usage message.
-v --version      print version information.

EOF
} # usage()


##########
# version()
#
# Get version information from version.sh and print a text with this.
#
sub version {
  $Groff_Version = $Groff_Version_Preset unless $Groff_Version;
  my $year = $Last_Update;
  $year =~ s/^.* //;
  print <<EOF;
$Chem_Name $Program_Version of $Last_Update (Perl version)
is part of groff version $Groff_Version.
Copyright (C) $year Free Software Foundation, Inc.
GNU groff and chem come with ABSOLUTELY NO WARRANTY.
You may redistribute copies of groff and its subprograms
under the terms of the GNU General Public License.
EOF
} # version()


### Emacs settings
# Local Variables:
# mode: CPerl
# End:
