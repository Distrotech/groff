#!/usr/bin/make -f
# ------------------------------------------------------------------------------
#
# Copyright (C) 2004, Free Software Foundation, Inc.
# Written by Keith Marshall (keith.d.marshall@ntlworld.com)
# 
# This file is part of groff.
# 
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2, or (at your option) any later
# version.
# 
# groff is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
# 
# You should have received a copy of the GNU General Public License along
# with groff; see the file COPYING.  If not, write to the Free Software
# Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
# ------------------------------------------------------------------------------
#
PAPERSIZE = a4
#
# We use GhostScript as our PDF writer -- here's how we will run it
#
GS        =  gs
PDFWRITE  =  $(GS) $(GSFLAGS) -dQUIET -dNOPAUSE -dBATCH -sDEVICE=pdfwrite 
#
# When generating Tables of Contents, we may need to split the document
# into separate TOC and BODY components, so that we can rearrange these
# into the correct order, when we assemble the final PDF document.
#
# To achieve this split, we run two groff passes, with different "phase"
# indices in each of the passes.
#
PDF_TOC_ONLY  = 1
PDF_BODY_TEXT = 2
#
# In order to choose a groff macro package, to format the document, we need
# a value for TMACTYPE to be set on the command line.  This should name ONE
# of groff's principal macro packages, e.g. ms, mm, or me.
#
ifdef TMACTYPE
#
# When TMACTYPE has been appropriately set up, then we may establish the
# proper settings for groff, to format the document.  Notice that we do not
# specify the principal macro package name directly, but rather, we use a
# wrapper macro package, which adds the appropriate PDF extensions to the
# base set;  the name of this wrapper package matches its corresponding base
# package name, with "pdf" appended, e.g. for the ms macros, implemented in
# "s.tmac", and selected by setting "TMACTYPE=ms", the corresponding wrapper
# is "spdf.tmac", and the "-ms" option to groff is replaced by "-mspdf",
# ( which is actually constructed as "-$(TMACTYPE)pdf" ).
#
GROFF_SETUP = -Tps $(GROFF_FLAGS) -M. -$(TMACTYPE)pdf $(GROFF_LAYOUT)
#
# We also need to communicate the selected paper size to groff, by setting
# flags to pass it BOTH to troff, and to the postprocessor, grops.
#
GROFF_LAYOUT = -dpaper=$(PAPERSIZE) -P-p$(PAPERSIZE)
#
# The final output file SHOULD be named with a ".pdf" suffix, but
# we allow the user to specify the target name without the ".pdf" suffix,
# and automically append it, silently, when required.
#
%: %.$(TMACTYPE)
	@$(REMAKE) $@.pdf
#
else
#
# When the TMACTYPE definition has not been supplied, we may deduce it,
# assuming the input file is named with the macro package name as a suffix,
# for an input file named to match "%.ms", select the ms macro package ...
#
%:     %.ms ; @$(REMAKE) TMACTYPE=ms $@
%.ref: %.ms ; @$(REMAKE) TMACTYPE=ms $@
%.map: %.ms ; @$(REMAKE) TMACTYPE=ms $@
%.pdf: %.ms ; @$(REMAKE) TMACTYPE=ms $@
#
# Similarly, for the mm, me and mom packages, with input file names matching
# "%.mm", "%.me" and "%.mom" respectively ...
#
%:     %.mm ; @$(REMAKE) TMACTYPE=mm $@
%.ref: %.mm ; @$(REMAKE) TMACTYPE=mm $@
%.map: %.mm ; @$(REMAKE) TMACTYPE=mm $@
%.pdf: %.mm ; @$(REMAKE) TMACTYPE=mm $@
#
%:     %.me ; @$(REMAKE) TMACTYPE=me $@
%.ref: %.me ; @$(REMAKE) TMACTYPE=me $@
%.map: %.me ; @$(REMAKE) TMACTYPE=me $@
%.pdf: %.me ; @$(REMAKE) TMACTYPE=me $@
#
%:     %.mom ; @$(REMAKE) TMACTYPE=mom $@
%.ref: %.mom ; @$(REMAKE) TMACTYPE=mom $@
%.map: %.mom ; @$(REMAKE) TMACTYPE=mom $@
%.pdf: %.mom ; @$(REMAKE) TMACTYPE=mom $@
#
# FIXME: each of the above four rule sets requires an appropriate package of
# binding macros, to add the PDF extensions to the corresponding base package;
# until someone provides "mpdf.tmac", "epdf.tmac" and "ompdf.tmac", only the
# TMACTYPE=ms option will actually work!
#
endif
#
# Define an awk script to extract cross reference data from the groff stderr
# stream, and format as a cross reference definitions file, of type "%.ref",
# to be merged with the groff input stream, in a later formatting pass
# 
XREF_MARKER = /^gropdf-info:href/
XREF_FORMAT = { $$1 = ".ds"; $$2 = "pdf:href(" $$2 ").info"; print }
XREF_SCRIPT = $(XREF_MARKER) $(XREF_FORMAT)
#
# Define the awk command, which uses the above script to create a cross
# reference filter, and specify the groff flags to be applied when piping
# the groff stderr stream through this filter.
#
XREF_FILTER = awk '$(XREF_SCRIPT)'
XREF_FLAGS  = $(GROFF_SETUP) -Z 2>&1 1>/dev/null
#
# To kick start the cross referencing process, we create an intermediate
# file, of type "%.xrf", initialised with the "first pass" cross reference
# definitions file content.
#
%.xrf : %.$(TMACTYPE)
	groff $(XREF_FLAGS) $^ | $(XREF_FILTER) > $@
#
# The final cross reference definitions file is created by recurrently
# processing the original groff input stream, including the definitions
# from the preceding pass, (starting with the "%.xrf" file from above),
# until two consecutive passes create identical output, capturing the
# final cross reference definitions in the "%.ref" file.
#
REMAKE = $(MAKE) --no-print-directory
#
%.ref : %.xrf %.$(TMACTYPE)
	groff $(XREF_FLAGS) $^ | $(XREF_FILTER) > $@
	diff $< $@ 1>/dev/null 2>&1 || mv -f $@ $<
	test -f $@ || $(REMAKE) $@
#
# Define a second awk script, which will be used to reprocess the fully
# cross referenced groff input stream, adding "hot-spot" mapping information
# to the cross reference definitions.
#
XMAP_MARKER = /^grohtml-info/
XMAP_PREFIX = BEGIN { mapref = 0 }
#MAP_FORMAT = ".ds pdf:href.map-%d %d %d %d\n"
#MAP_FORMAT = ".ds pdf:href.map-%d %d %d %d %d %d\n"
#MAP_APPEND = { printf $(XMAP_FORMAT), ++mapref, $$2, $$3, $$6, $$7, $$4 }
#MAP_APPEND = { printf $(XMAP_FORMAT), ++mapref, $$2, $$3, $$4 }
#MAP_SCRIPT = $(XMAP_PREFIX) $(XMAP_MARKER) $(XMAP_APPEND)
XMAP_FORMAT = { print ".ds pdf:href.map-" ++mapref, $$2, $$3, $$4 }
XMAP_SCRIPT = $(XMAP_PREFIX) $(XMAP_MARKER) $(XMAP_FORMAT)
#
# The awk command, which invokes this script as the final cross reference
# mapping filter, must also reproduce the output of the earlier filter,
# used to create the "%.ref" file.
#
XMAP_FILTER = awk '$(XMAP_SCRIPT) $(XREF_SCRIPT)'
#
# The "hot-spot" mapping data is merged with the original "%.ref" cross
# reference definitions, with the final cross reference mapping definitions
# being captured in a "%.map" file.
#
%.map : %.ref %.$(TMACTYPE)
	groff $(XREF_FLAGS) $^ | $(XMAP_FILTER) > $@
#
# Assuming a cover page title block is defined in the groff document source,
# with its content bracketed by ".CS" .. ".CE" macro pairs, we can use sed
# to extract it.
#
SET_TITLE = sed -n '/^\.CS/,/^\.CE/p'
#
# The extracted title block may then be merged into a standard cover page
# layout template, and processed by groff, to generate a cover page.
#
%-fp.ps: %.$(TMACTYPE)
	$(SET_TITLE) $< | groff $(GROFF_SETUP) cover.$(TMACTYPE) - > $@
#
# Define the "phase" codes, passed to groff, for separating tables of
# contents and body text into distinct document parts.
#
TOC_ONLY  = -rPHASE=$(PDF_TOC_ONLY)
BODY_ONLY = -rPHASE=$(PDF_BODY_TEXT)
#
# Identify the document parts to be assembled, by examining the "PARTSLIST"
# file, if any, specified on the command line as "PARTSLIST=filename".
#
ifdef PARTSLIST
include $(PARTSLIST)
endif
#
# When we are assembling a multipart document, each individual part may
# include redundant blank pages, inherited from a groff processing phase
# for an alternative part, reprocessed in its own phase, with "pen up".
# The following sed script will discard such pages.
#
KILL_BLANK_PAGES  =  \
    sed -e ':again'			\
        -e '  /%%EndPageSetup/b finish'	\
        -e '  /%%Page:/{'		\
        -e '    N'			\
        -e '    b again'		\
        -e '  }'			\
        -e 'b'				\
        -e ':finish'			\
        -e '  N'			\
        -e '  /^%%Page:.*0 *Cg *EP/d'
#
# Define the "multipart" rules for each of the Table of Contents, and
# the "Body Text" document parts.
#
%-toc.ps: %.map %.$(TMACTYPE)
	groff $(GROFF_SETUP) $(TOC_ONLY) $^ | $(KILL_BLANK_PAGES) > $@
#
%-body.ps: %.map %.$(TMACTYPE)
	groff $(GROFF_SETUP) $(BODY_ONLY) $^ | $(KILL_BLANK_PAGES) > $@
#
# The "PARTSLIST" file tells us which parts to assemble, by defining a
# prototype list, in the "PARTNAMES" variable.
#
ifdef PARTNAMES
#
# When "PARTNAMES" has been defined, then we may proceed to assemble the
# specified document parts.
#
%.pdf: $(PARTNAMES)
	$(PDFWRITE) -sOutputFile=$@ $^
#
else
#
# ... but when, "PARTNAMES" is not yet specified, then we must examine the
# groff input file, to deduce which parts are required ..
#
INCLUDE_TOC = egrep "^[.']"'[ 	]*TC( .*)*[ ]*$$'
#
%-parts.txt: %.$(TMACTYPE)
	echo "PARTNAMES =" > $@
	test -z "`$(SET_TITLE) $<`" || echo "%-fp.ps" >> $@
	test -z "`$(INCLUDE_TOC) $<`" || echo "%-toc.ps" >> $@
	echo "%-body.ps" >> $@
#
# ... assembling the identified "PARTNAMES" in to a "PARTSLIST" file ...
#
%-parts.mk: %-parts.txt
	echo `tr '\012\014' '\040\040' < $<` > $@
#
# ... which we then reprocess, to generate the output document.
#
%.pdf: %-parts.mk
	$(REMAKE) PARTSLIST=$< $@
#
endif
#
# ------------------------------------------------------------------------------
# pdfmake: end of file
