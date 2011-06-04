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

use 5.006;
use strict;
use warnings;
use Smart::Comments;

{
  require Math::PlanePath::MathImagePlusSimilar;
  my $path = Math::PlanePath::MathImagePlusSimilar->new;
  my @cell;
  my $n = 1;
  for (my $level = 2; ; $level+=2) {
    print "level $level\n";
    my $limit = 5**$level - 1;
    while ($n < $limit) {
      my ($x, $y) = $path->n_to_xy($n++) or next;
      if ($x >= 0 && $y >= 0) {
        $cell[$x]->[$y] = $n;
      }
    }
    my $s = 1;
  S: for (;; $s++) {
      foreach my $i (0 .. $s) {
        if (! $cell[$s]->[$i]) {
          print "  missing $s,$i\n";
          $s--;
          last S;
        }
      }
      foreach my $i (0 .. $s) {
        if (! $cell[$i]->[$s]) {
          print "  missing $i,$s\n";
          $s--;
          last S;
        }
      }
    }
    print "  s=$s\n";
  }
  exit 0;
}
