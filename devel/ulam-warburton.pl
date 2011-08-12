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
use warnings;

# uncomment this to run the ### lines
use Smart::Comments;

# turn on u(0) = 1
#         u(1) = 1
#         u(n) = 4 * 3^ones(n-1) - 1
# where ones(x) = number of 1 bits   A000120
#
{
  my @yx;
  sub count_around {
    my ($x,$y) = @_;
    return (($yx[$y+1][$x] || 0)
            + ($yx[$y][$x+1] || 0)
            + ($x > 0 && ($yx[$y][$x-1] || 0))
            + ($y > 0 && ($yx[$y-1][$x] || 0)));
  }
  my (@turn_x,@turn_y);
  sub turn_on {
    my ($x,$y) = @_;
    if (! $yx[$y][$x] && count_around($x,$y) == 1) {
      push @turn_x, $x;
      push @turn_y, $y;
    }
  }

  $yx[0][0] = 1;
  for (1 .. 20) {
    foreach my $row (reverse @yx) {
      foreach my $cell (@$row) {
        print ' ', ($cell||' ');
      }
      print "\n";
    }
    print "\n";

    foreach my $y (0 .. $#yx) {
      my $row = $yx[$y];
      foreach my $x (0 .. $#$row) {
        $yx[$y][$x] or next;

        turn_on ($x, $y+1);
        turn_on ($x+1, $y);
        if ($x > 0) {
          turn_on ($x-1, $y);
        }
        if ($y > 0) {
          turn_on ($x, $y-1);
        }
      }
    }
    # print "extra ",scalar(@turn_x),"\n";

    my %seen_turn;
    for (my $i = 0; $i < @turn_x; ) {
      my $key = "$turn_x[$i],$turn_y[$i]";
      if ($seen_turn{$key}) {
        splice @turn_x,$i,1;
        splice @turn_y,$i,1;
      } else {
        $seen_turn{$key} = 1;
        $i++;
      }
    }

    print "extra ",4*(scalar(@turn_x)-2)+4,"\n";
    while (@turn_x) {
      $yx[pop @turn_y][pop @turn_x] = 1;
    }
  }
  exit 0;
}
