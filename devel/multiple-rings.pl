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
use Math::Trig 'pi','tan';

# uncomment this to run the ### lines
#use Smart::Comments;


{
  # polygon pack

  my $poly = 4;
  my $a = 2*pi/$poly;
  my $slope = tan($a/2) * 2;
  print "slope $slope\n";
  my $w = 1;

  # tan a/2 = 0.5/c
  # c = 0.5 / tan(a/2)
  my $c = 0.5 / tan($a/2);

  for (1 .. 10) {
    printf "c=%.3f w=%d\n", $c, $w;

    # inward
    # w=3, full c*s, each c*s/w, half to centre
    my $full = $c*$slope;
    my $seg = $full / $w;
    my $b = $seg / 2;
    my $extra_c = sqrt(1 - $b*$b);
    printf "in  full=%.2f seg=%.2f b=%.2f  add %.6f\n",
      $full, $seg, $b, $extra_c;
    $c += $extra_c;
    $w++;
  }
  exit 0;
}

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
