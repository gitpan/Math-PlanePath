#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

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

use 5.004;
use strict;

# uncomment this to run the ### lines
#use Smart::Comments;


{
  # max dx

  require Math::PlanePath::MultipleRings;
  my $path = Math::PlanePath::MultipleRings->new (step => 37);
  my $n = $path->n_start;
  my $dx_max = 0;
  my ($prev_x, $prev_y) = $path->n_to_xy($n++);
  foreach (1 .. 1000000) {
    my ($x, $y) = $path->n_to_xy($n++);

    my $dx = $y - $prev_y;
    if ($dx > $dx_max) {
      print "$n  $dx\n";
      $dx_max = $dx;
    }

    $prev_x = $x;
    $prev_y = $y;
  }
  exit 0;
}
