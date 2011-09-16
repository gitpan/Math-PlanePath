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
use Math::PlanePath::RationalsTree;

foreach my $tree_type ('SB', 'CW', 'AYT', 'Bird') {
  print "$tree_type tree\n";

  my $path = Math::PlanePath::RationalsTree->new
    (tree_type => $tree_type);

  printf "%20s", '';
  foreach my $n (1) {
    my ($x,$y) = $path->n_to_xy($n);
    printf "%-5s", "$x/$y";
  }
  print "\n";

  printf "%10s", '';
  foreach my $n (2 .. 3) {
    my ($x,$y) = $path->n_to_xy($n);
    printf "%-20s", "$x/$y";
  }
  print "\n";

  printf "%5s", '';
  foreach my $n (4 .. 7) {
    my ($x,$y) = $path->n_to_xy($n);
    printf "%-10s", "$x/$y";
  }
  print "\n";

  foreach my $n (8 .. 15) {
    my ($x,$y) = $path->n_to_xy($n);
    printf "%5s", "$x/$y";
  }
  print "\n";

  # foreach my $n (16 .. 31) {
  #   my ($x,$y) = $path->n_to_xy($n);
  #   printf "%4s", "$x/$y";
  # }
  # print "\n";

  print "\n";
}

exit 0;
