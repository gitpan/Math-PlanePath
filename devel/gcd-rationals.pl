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


use 5.004;
use strict;
use Math::PlanePath::MathImageGcdRationals;

my $path = Math::PlanePath::MathImageGcdRationals->new;

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
