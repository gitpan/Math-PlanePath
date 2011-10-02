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

use 5.006;
use strict;
use warnings;
use Math::Libm 'M_PI', 'hypot';


{
  my $x = 1;
  my $y = 0;
  for (my $level = 1; $level < 20; $level++) {
    # (x+iy)*(2+i)
    ($x,$y) = (2*$x - $y, $x + 2*$y);
    if (abs($x) >= abs($y)) {
      $x -= ($x<=>0);
    } else {
      $y -= ($y<=>0);
    }
    print "$level $x,$y\n";
  }
  exit 0;
}

{
  # min/max for level
  require Math::BaseCnv;
  require Math::PlanePath::QuintetReplicate;
  my $path = Math::PlanePath::QuintetReplicate->new;
  my $prev_min = 1;
  my $prev_max = 1;
  my @mins;
  for (my $level = 0; $level < 20; $level++) {
    my $n_start = 5**$level;
    my $n_end = 5**($level+1) - 1;

    my $min_hypot = 128*$n_end*$n_end;
    my $min_x = 0;
    my $min_y = 0;
    my $min_pos = '';

    my $max_hypot = 0;
    my $max_x = 0;
    my $max_y = 0;
    my $max_pos = '';

    print "level $level  n=$n_start .. $n_end\n";

    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = $x*$x + $y*$y;
      # my $h = abs($x) + abs($y);

      if ($h < $min_hypot) {
        my $n5 = Math::BaseCnv::cnv($n,10,5) . '[5]';
        $min_hypot = $h;
        $min_pos = "$x,$y  $n $n5";
      }
      if ($h > $max_hypot) {
        my $n5 = Math::BaseCnv::cnv($n,10,5) . '[5]';
        $max_hypot = $h;
        $max_pos = "$x,$y  $n $n5";
      }
    }
    # print "  min $min_hypot   at $min_x,$min_y\n";
    # print "  max $max_hypot   at $max_x,$max_y\n";
    {
      my $factor = $min_hypot / $prev_min;
      my $base5 = Math::BaseCnv::cnv($min_hypot,10,5) . '[5]';
      print "  min $min_hypot $base5   at $min_pos  factor $factor\n";
    }
    # {
    #   my $factor = $max_hypot / $prev_max;
    #   my $base5 = Math::BaseCnv::cnv($max_hypot,10,5) . '[5]';
    #   print "  max $max_hypot $base5   at $max_pos  factor $factor\n";
    # }
    $prev_min = $min_hypot;
    $prev_max = $max_hypot;

    push @mins, $min_hypot;
  }

  print join(',',@mins),"\n";
  exit 0;
}
