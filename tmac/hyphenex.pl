#! /usr/bin/perl
#
#
# hyphenex.pl
#
# This small filter converts a hyphenation exception log article for
# TUGBoat to a real \hyphenation block.
#
# Written by Werner Lemberg <wl@gnu.org>.
#
# Version 1.0 (2003/04/16)
#
# Public domain.
#
#
# Usage:
#
#   [perl] hyphenex.pl < tugboat-article > hyphenation-exceptions

print "% Hyphenation exceptions for US English,\n";
print "% based on the hyphenation exception log article in TUGBoat.\n";
print "%\n";
print "% This is an automatically generated file.  Do not edit!\n";
print "%\n";
print "% Please contact Barbara Beeton <bnb\@ams.org>\n";
print "% for corrections and omissions.\n";
print "\n";
print "\\hyphenation{\n";

while (<>) {
  next if not (m/^\\[123456]/ || m/^\\tabalign/);
  chop;
  s/\\[^123456\s{]+//g;
  s/{(.*?)}/\1/g;
  next if m/^\s*&/;
  s/%.*//;
  s/\s*$//;
  s/\*$//;
  @field = split(' ');
  if ($field[0] eq "\\1" || $field[0] eq "\\4") {
    print "  $field[2]\n";
  }
  elsif ($field[0] eq "\\2" || $field[0] eq "\\5") {
    print "  $field[2]\n";
    @suffix_list = split(/,/, "$field[3]");
    foreach $suffix (@suffix_list) {
      print "  $field[2]$suffix\n";
    }
  }
  elsif ($field[0] eq "\\3" || $field[0] eq "\\6") {
    @suffix_list = split(/,/, "$field[3],$field[4]");
    foreach $suffix (@suffix_list) {
      print "  $field[2]$suffix\n";
    }
  }
  else {
    @field = split(/&\s*/);
    print "  $field[1]\n";
  }
}

print "}\n";
print "\n";
print "% EOF\n";
