#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-PlanePath is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.

use 5.010;
use strict;
use warnings;
use Fcntl;
use SDBM_File;

# uncomment this to run the ### lines
#use Smart::Comments;

my $filename = "/z/tmp/pythagorean-area.sdbm";
unlink "$filename.pag";
unlink "$filename.dir";
tie my %db, 'SDBM_File', $filename,  Fcntl::O_RDWR() | Fcntl::O_CREAT(), 0666
  or die $!;

my $area_limit = 13123110 * 2;
# $area_limit = 1_000_000;
my $a_limit = $area_limit * 2 + 1;
my $triples = 0;

for (my $a = 1; $a < $a_limit; $a++) {
  my $a2 = $a*$a;
  my $b_first = $a+1;
  $b_first += ! (($a^$b_first)&1);
  for (my $b = $b_first; ; $b += 2) {
    ### at: "$a,$b"
    my $area = $a*$b;
    if ($area > $area_limit) {
      last;
    }

    my $b2 = $b*$b;
    my $c2 = $a2 + $b*$b;
    my $c = int(sqrt($c2)+.5);
    if ($c*$c != $c2) {
      next;
    }
    $triples++;

    $db{$area} .= " a=$a,b=$b";
    if (++$db{"$area.count"} >= 2) {
      my $count = $db{"$area.count"};
      print "found area=$area count=$count  $db{$area}\n";
    }
  }
}
# print keys %db;
print "total $triples triples\n";
print "end\n";
exit 0;
