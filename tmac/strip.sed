# strip all troff comments after a line containing `%beginstrip%
/%beginstrip%/,$s/[	 ]*\\".*//
/^\.$/d
