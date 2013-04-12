#! /usr/bin/env perl

# glilypond - transform `lilypond' parts into `groff' language

# Source file position: <groff-source>/contrib/groffer/perl/perl_test.sh
# Installed position: <prefix>/lib/groff/groffer/perl_test.sh

# Copyright (C) 2013
#   Free Software Foundation, Inc.
# Written by Bernd Warken <groff-bernd.warken-72@web.de>.

# Last update: 12 Apr 2013

# This file is part of `glilypond', which is part of `groff'.

# `groff' is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# `groff' is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

########################################################################

# This file tests whether perl has a suitable version.  It is used by
# glilypond.pl and Makefile.sub.

# former: require v5.9.4; # for `state' in `subs.pl'
require v5.6; # analogously to `groffer'

########################################################################
### Emacs settings
# Local Variables:
# mode: CPerl
# End:
