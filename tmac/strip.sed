# strip comments, spaces, etc. after a line containing `%beginstrip%'
/%beginstrip%/,$ {
  s/^\.[	 ]*/./
  s/^\.\\".*/./
  s/\\".*/\\"/
  /\(.ds\)\|\(.as\)/!s/[	 ]*\\"//
  /\(.ds\)\|\(.as\)/s/\([^	 ]\)\\"/\1/
  s/\([^/]\)doc-/\1/g
}
/^\.$/d
