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

use 5.010;
use strict;
use warnings;
use Math::PlanePath::KochSquareflakes;


{
  # Xstart power
  # Xstart = b^level
  # b = Xstart^(1/level)
  #
  # D = P^2-4Q = 4^2-4*-2 = 24
  # sqrt(24) = 4.898979485566356196394568149
  #
  my $path = Math::PlanePath::KochSquareflakes->new;
  my $prev = 1;
  foreach my $level (1 .. 12) {
    my $nstart = (4**($level+1) - 1) / 3;
    my ($xstart,$ystart) = $path->n_to_xy($nstart);
    $xstart = -$xstart;
    my $f = $xstart / $prev;
    # my $b = $xstart ** (1/($level+1));
    print "level=$level xstart=$xstart f=$f\n";
    $prev = $xstart;
  }
  print "\n";
  exit 0;
}

{
  # Xstart list
  my $path = Math::PlanePath::KochSquareflakes->new;
  foreach my $level (1 .. 12) {
    my $nstart = (4**($level+1) - 1) / 3;
    my ($xstart,$ystart) = $path->n_to_xy($nstart);
    $xstart = -$xstart;
    print "$xstart,";
  }
  print "\n";
  exit 0;
}

{
  my $path = Math::PlanePath::KochSquareflakes->new;
  foreach my $level (1 .. 8) {
    my $nstart = (4**($level+1) - 1) / 3;
    my $nend = $nstart + 4**$level;
    my ($xstart,$ystart) = $path->n_to_xy($nstart);

    my $max_width = 0;
    my $max_width_n = $nstart;
    my $max_width_y = $ystart;
    foreach my $n ($nstart .. $nend) {
      my ($x,$y) = $path->n_to_xy($n);
      my $width = abs ($y - $ystart);
      if ($width > $max_width) {
        $max_width = $width;
        $max_width_n = $n;
        $max_width_y = $y;
      }
    }

    print "level $level ystart=$ystart max width $max_width at N=$max_width_n (of $nstart to $nend) Y=$max_width_y\n";
  }
}

{
  my @horiz = (1);
  my @diag  = (1);
  foreach my $i (0 .. 10) {
    $horiz[$i+1] = 2*$horiz[$i] + 2*$diag[$i];
    $diag[$i+1]  = $horiz[$i] + 2*$diag[$i];
    $i++;
  }

  print "horiz: ",join(', ',@horiz),"\n";
  print "diag:  ",join(', ',@diag),"\n";
  exit 0;
}
