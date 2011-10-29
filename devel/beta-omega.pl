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

use 5.004;
use strict;

{
  require Math::PlanePath::KochCurve;
  foreach my $y (-32 .. 32) {
    my $y1 = $y;
    my $y2 = $y;
    {
      if ($y2 > 0) {
        # eg y=5 gives 3*5 = 15
        $y2 *= 3;
      } else {
        # eg y=-2 gives 1-3*-2 = 7
        $y2 = 3-6*$y1;
      }

      my ($ylen, $ylevel) = Math::PlanePath::KochCurve::_round_down_pow($y2,4);
      print "$y   $y2   $ylevel $ylen\n";
    }
  }
  exit 0;
}
