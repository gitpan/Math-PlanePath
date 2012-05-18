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

use 5.004;
use strict;

# uncomment this to run the ### lines
use Devel::Comments;

{
  # repeat points
  require Math::PlanePath::CCurve;
  my $path = Math::PlanePath::CCurve->new;
  my %seen;
  foreach my $n (0 .. 2**24 - 1) {
    my ($x, $y) = $path->n_to_xy ($n);
    $seen{"$x,$y"}++;
  }

  my @count;
  while (my ($key,$visits) = each %seen) {
    $count[$visits]++;
    if ($visits > 4) {
      print "$key    $visits\n";
    }
  }
  ### @count
  exit 0;
}
