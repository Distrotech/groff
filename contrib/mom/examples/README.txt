The files in this directory show mom in action.

I haven't included their PostScript output because I want to
keep the mom archive as lean as possible.  To view the PostScript
output, process the files with groff and either

    a) send the output to a separate file for previewing with a
       PostScript viewer such as gv (ghostview), or

    b) to your printer.

Using the file typeset_doc.mom as an example, you would
accomplish a) like this:

    groff -mom -Tps typeset_doc.mom > typeset_doc.ps
    gv typeset_doc.ps

How you would accomplish b) depends on your printer setup, but a
fairly standard way to do it would be

    groff -mom -Tps typeset_doc.mom | lpr

                  or

    groff -mom -Tps -l typeset_doc.mom

Note: I don't recommend previewing with gxditview because it doesn't
render some of mom's effects properly.

The files themselves
--------------------

All are set up for 8.5x11 inch paper (US letter).

***typesetting.mom**

The file, typesetting.mom, demonstrates the use of typesetting tabs,
string tabs, line padding, multi-columns and various indent styles,
as well as some of the refinements and fine-tuning available via
macros and inline escapes.

Because the file also demonstrates a "cutaround" using a small
picture (of everybody's favourite mascot, Tux), the PostScript file,
penguin.ps has been included in the directory.

***typeset_doc.mom***

The file, typeset_doc.mom, shows examples of three of the document
styles available with the mom's document processing macros, as well
as demonstrating the use of COLLATE.

The PRINTSTYLE of this file is TYPESET, to give you an idea of mom's
default behaviour when typesetting a document.

The last sample, set in 2 columns, shows off mom's flexibility
when it comes to designing documents.

***typewrite_doc.mom***

Using the first two samples from typeset.mom, typewrite_doc.mom
shows what "typewritten, double-spaced" documents (PRINTSTYLE
TYPEWRITE) look like.

***letter.mom***

This is just the tutorial example from the momdocs, ready for
previewing.

***elvis_syntax.new***

For those who use the vi clone, elvis, you can paste this file into
your elvis.syn.  Provided your mom documents have the extension
.mom, they'll come out with colorized syntax highlighting.  The
rules in elvis_syntax aren't exhaustive, but they go a LONG way to
making mom files more readable.

The file elvis_syntax (for pre-2.2h versions of elvis) is no longer
being maintained.  Users are encouraged to update to elvis 2.2h or
higher, and to use elvis_syntax.new for mom highlighting.

I'll be very happy if someone decides to send me syntax highlighting
rules for vim and emacs. :)
