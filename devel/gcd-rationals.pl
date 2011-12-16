#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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
use Math::PlanePath::GcdRationals;

# uncomment this to run the ### lines
use Smart::Comments;


{
  my $path = Math::PlanePath::GcdRationals->new;
  foreach my $y (3 .. 50) {
    foreach my $x (3 .. 50) {
      my $n = $path->xy_to_n($x,$y) // next;

      my $slope = int($x/$y) + 1;
      my $g = $slope+1;
      my $fn = $x*$g + $y*$g*(($y-2)*$g + 1)/2;

      if ($n != $fn) {
        ### $n
        ### $fn
        ### $g
        ### $x
        ### $y

        my $int = int($x/$y);
        my $i = $x % $y;
        if ($i == 0) {
          $i = $y;
          $int--;
        }
        $int++;
        $i *= $int;
        $j *= $int;

      }
    }
  }
  exit 0;
}

{
  my $path = Math::PlanePath::GcdRationals->new;
  foreach my $y (1 .. 500) {
    my $prev_n = 0;
    foreach my $x (1 .. 500) {
      my $n = $path->xy_to_n($x,$y) // next;
      if ($n <= $prev_n) {
        die "not monotonic $n cf $prev_n";
      }
      $prev_n = $n;
    }
  }
  exit 0;
}

{
my $path = Math::PlanePath::GcdRationals->new;
  print "N =";
  foreach my $n (1 .. 11) {
    printf "%5d", $n;
  }
  print "\n";

  print "X/Y =";
  foreach my $n (1 .. 11) {
    my ($x,$y) = $path->n_to_xy($n);
    print " $x/$y,"
  }
  print " etc\n";
  exit 0;
}
