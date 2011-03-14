#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-PlanePath is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.


use 5.004;
use strict;
use POSIX ();
use Math::PlanePath::Hypot;

{
  my @seen_ways;
  for (my $s = 1; $s < 1000; $s++) {
    my $h = $s * $s;
    my @ways;
    for (my $x = 1; $x < $s; $x++) {
      my $y = sqrt($h - $x*$x);
      # if ($y < $x) {
      #   last;
      # }
      if ($x >= $y && $y == int($y)) {
        push @ways, "   $x*$x + $y*$y\n";
      }
    }
    my $num_ways = scalar(@ways);
    $seen_ways[$num_ways]
      ||= $seen_ways[$num_ways] = "$s*$s = $h   $num_ways ways\n" . join('',@ways);
  }
  print grep {defined} @seen_ways;
  exit 0;
}

{
  for (1 .. 1000) {
    Math::PlanePath::Hypot::_extend();
  }
  # $,="\n";
  # print map {$_//'undef'} @Math::PlanePath::Hypot::hypot_to_n;

  exit 0;
}


