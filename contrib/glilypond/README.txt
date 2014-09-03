    Copyright (C) 2013-2014  Free Software Foundation, Inc.

    Written by Bernd Warken <groff-bernd.warken-72@web.de>

    Copying and distribution of this file, with or without modification,
    are permitted in any medium without royalty provided the copyright
    notice and this notice are preserved.

    This file is part of `glilypond', which is part of `groff'.


########################################################################

In order to run `glilypond', your system must have installed Perl of at
least version `v5.6'.


########################################################################

In order to have this program installed by `make', the creation of a
libdir (library directory) must be programmed in some system files.
The following actions must be taken:

1) <groff_src_dir>/m4/groff.m4:
Add `AC_DEFUN([GROFF_GROFFERDIR_DEFAULT])'.

2) <groff_src_dir>/configure.ac:
Add `GROFF_GROFFERDIR_DEFAULT'.

3) <groff_src_dir>/Makefile.in:
Add several informations of `glilypond_dir'

With that, the program `autoconf' can be run in order to update the
configure files and Makefile's.

Now `$glilypond_dir' can be used as libdir.


########################################################################
### Emacs settings
# Local Variables:
# mode: text
# End:
