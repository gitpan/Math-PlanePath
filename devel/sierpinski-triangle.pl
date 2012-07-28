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
use Math::PlanePath::SierpinskiTriangle;

# uncomment this to run the ### lines
use Smart::Comments;

{
  # number of children
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  for (my $n = $path->n_start+1; $n < 40; $n++) {
    my @n_children = $path->tree_n_children($n);
    my $num_children = scalar(@n_children);
    print "$num_children,";
  }
  print "\n";
  exit 0;
}

{
  my $path = Math::PlanePath::SierpinskiTriangle->new;
  foreach my $y (0 .. 10) {
    foreach my $x (-$y .. $y) {
      if ($path->xy_to_n($x,$y)) {
        print "1,";
      } else {
        print "0,";
      }
    }
  }
  print "\n";
  exit 0;
}
