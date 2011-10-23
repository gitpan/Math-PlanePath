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

# uncomment this to run the ### lines
use Devel::Comments;

{
  # turn
  require Math::PlanePath::MathImageCCurve;
  my $path = Math::PlanePath::MathImageCCurve->new;
  my %seen;
  foreach my $n (0 .. 2**8 - 1) {
    my ($x, $y) = $path->n_to_xy ($n);
    $seen{"$x,$y"}++;
  }
  my @count;
  while (my ($key,$visits) = each %seen) {
    $count[$visits]++;
    if ($visits > 2) {
      print "$key    $visits\n";
    }
  }
  ### @count
  exit 0;
}
