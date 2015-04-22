2 i\
.\\" This is a generated file, created by `tmac/strip.sed' in groff's\
.\\" source code bundle from a file having `-u' appended to its name.
# strip comments, spaces, etc., after a line containing `%beginstrip%'
/%beginstrip%/,$ {
  s/^\.[	 ]*/./
  s/^\.\\".*/./
  s/^\\#.*/./
  s/\\".*/\\"/
  s/\\#.*/\\/
  /\(.[ad]s\)/!s/[	 ]*\\"//
  /\(.[ad]s\)/s/\([^	 ]*\)\\"/\1/
  s/\([^/]\)doc-/\1/g
}
/^\.$/d
