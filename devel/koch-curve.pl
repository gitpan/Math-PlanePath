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
use Math::PlanePath::KochCurve;


{
  my $path = Math::PlanePath::KochCurve->new;
  foreach my $n (0 .. 16) {
    my ($x,$y) = $path->n_to_xy($n);
    my $rot = n_to_total_turn($n);
    print "$n  $x,$y  $rot\n";
  }
  print "\n";
  exit 0;

  sub n_to_total_turn {
    my ($n) = @_;
    my $rot = 0;
    while ($n) {
      if (($n % 4) == 1) {
        $rot++;
      } elsif (($n % 4) == 2) {
        $rot --;
      }
      $n = int($n/4);
    }
    return $rot;
  }
}

