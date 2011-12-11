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
  my $pi = 4 * atan2(1,1);
  my %seen;
  foreach my $x (0 .. 100) {
    foreach my $y (0 .. 100) {
      my $factor;

      $factor = 1;

      $factor = sqrt(3);
      # next unless ($x&1) == ($y&1);

      $factor = sqrt(8);

      my $radians = atan2($y*$factor, $x);
      my $degrees = $radians / $pi * 180;
      my $frac = $degrees - int($degrees);
      if ($frac > 0.5) {
        $frac -= 1;
      }
      if ($frac < -0.5) {
        $frac += 1;
      }
      my $int = $degrees - $frac;
      next if $seen{$int}++;

      if ($frac > -0.001 && $frac < 0.001) {
        print "$x,$y   $int  ($degrees)\n";
      }
    }
  }
  exit 0;
}
