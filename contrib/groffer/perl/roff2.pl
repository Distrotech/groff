#! /usr/bin/env perl

# roff2* - transform roff files into other formats

# Source file position: <groff-source>/contrib/groffer/perl/roff2.pl
# Installed position: <prefix>/bin/roff2*

# Copyright (C) 2006 Free Software Foundation, Inc.
# Written by Bernd Warken.

# Last update: 7 Nov 2006

# This file is part of `groffer', which is part of `groff'.

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

require v5.6;

use strict;
use warnings;
use File::Spec;

my $Mode;
my $Name;
{
  my ($v, $d);
  ($v, $d, $Name) = File::Spec->splitpath($0);
  die "wrong program name: $Name;"
    if $Name !~ /^roff2[a-z]/;
}
$Mode = $Name;
$Mode =~ s/^roff2//;
foreach (@ARGV) {
  if ($_ eq '-v' || '--version' =~ m|^$_|) {
    print $Name, ' in ', `groffer --version`;
    exit 0;
  }
  if ($_ eq '-h' || '--help' =~ m|^$_|) {
    print <<EOF;
usage: $Name [option]... [--] [filespec]...

where the optional `filespec's are either the names of existing,
readable files or `-' for standard input or a search pattern for man
pages.  The optional `option's are arbitrary options of `groffer'; the
options override the behavior of this program.
EOF
    exit 0;
  }
}
system('groffer', '--to-stdout', "--$Mode", @ARGV);

