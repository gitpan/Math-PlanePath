#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

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
use Math::PlanePath::KochSnowflakes;

{
  # area
  print sqrt(48)/10,"\n";
  my $sum = 0;
  foreach my $level (1 .. 10) {
    my $area = (1 + 3/9*$sum) * sqrt(3)/4;
    print "$level $area\n";
    $sum += (4/9)**$level;
  }
  exit 0;
}

{
  # X axis N increasing
  my $path = Math::PlanePath::KochSnowflakes->new;
  my $prev_n = 0;
  foreach my $x (0 .. 10000000) {
    my $n = $path->xy_to_n($x,0) // next;
    if ($n < $prev_n) {
      print "decrease N at X=$x N=$n prev_N=$prev_n\n";
    }
    $prev_n = $n;
  }
}
