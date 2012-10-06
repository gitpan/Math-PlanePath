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
  # tree_n_to_depth()
  require Math::PlanePath::ToothpickTree;
  my $path = Math::PlanePath::ToothpickTree->new;
  my $prev = 0;
  my $count = 0;
  my $total = 0;
  for (my $n = 1; $n <= 256; $n++) {
    my $depth = $path->tree_n_to_depth($n);
    if ($depth > $prev) {
      print "$prev  $count  $total\n";
      $count = 0;
      $prev = $depth;
    }
    $count++;
    $total++;
  }
  exit 0;
}

{
  my @added = (0, 1, 2, 4);
  print "0,1,\n2,4,\n";
  for (my $len = 4; $len <= 16; $len *= 2) {
    my $add = $len;
    push @added, $add;
    print "$add,";
    for my $i (1 .. $len-1) {
      my $add = $added[$i+1] + 2*$added[$i];
      print "$add,";
      push @added, $add;
    }
    my $asize = scalar(@added);
    print "  [asize=$asize]\n";
  }
  exit 0;
}
{
  #  0;
  #  1;
  #  2,4;
  #  4,4,8,12;
  #  8,4,8,12,12,16,28,32;
  # 16,4,8,12,12,16,28,32,20,16,28,36,40,60,88,80;
  # 32,4,8,12,12,16,28,32,20,16,28,36,40,60,88,80,36,16,28,36,40,60,88,84,56,..

  # 1, 1,
  # 1, 2, 3, 2,
  # 1, 2, 3, 3, 4, 7, 8, 4,
  # 1, 2, 3, 3, 4, 7, 8, 5, 4, 7, 9, 10, 15, 22, 20, 8,
  # 1, 2, 3, 3, 4, 7, 8, 5, 4, 7, 9, 10, 15, 22, 20, 9, 4, 7, 9, 10, 15, 22, 21, 14, 15, 23, 28, 35, 52, 64, 48, 16,
  # 1, 2, 3, 3, 4, 7, 8, 5, 4, 7, 9, 10, 15, 22, 20, 9, 4, 7, 9, 10, 15, 22, 21, 14, 15, 23

  #   0,
  #   1, 2,
  #   4, 4,
  #   4, 8, 12, 8,
  #   4, 8, 12, 12, 16, 28, 32, 16,
  #   4, 8, 12, 12, 16, 28, 32, 20, 16, 28, 36, 40, 60, 88, 80, 32,
  #   4, 8, 12, 12, 16, 28, 32, 20, 16, 28, 36, 40, 60, 88, 80, 36, 16, 28, 36, 40, 60, 88, 84, 56, 60, 92, 112, 140, 208, 256, 192, 64,
  #   4, 8, 12, 12, 16, 28, 32, 20, 16, 28

  my @add = (0,1);
  my $dpower = 2;
  my $d = 0;
  my $n = 1000;
  for (;;) {
    my $add;
    ### $d
    ### $dpower
    if ($d == 0) {
      $add = $dpower;
    } else {
      $add = 2*$add[$d] + $add[$d+1];
    }
    if (++$d >= $dpower) {
      $dpower *= 2;
      $d = 0;
    }
    ### $add
    if ($n <= $add) {
      last;
    }
    $n -= $add;
    push @add, $add;
  }
  print join(',',@add);
  exit 0;
}


