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

use 5.010;
use strict;
use warnings;

{
  # min/max for level
  require Math::PlanePath::QuadricCurve;
  my $path = Math::PlanePath::QuadricCurve->new;
  my $prev_min = 1;
  my $prev_max = 1;
  for (my $level = 1; $level < 25; $level++) {
    my $n_start = 8**($level-1);
    my $n_end = 8**$level;

    my $max_width = 0;
    my $max_pos = '';

    my $min_width;
    my $min_pos = '';

    print "level $level  n=$n_start .. $n_end\n";

    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);
      $x -= 4**$level / 2;  # for Rings
      $y -= 4**$level / 2;  # for Rings

      my $w = -2*$y-$x;
      #my $w = -$y-$x/2;

      if ($w > $max_width) {
        $max_width = $w;
        $max_pos = "$x,$y n=$n (oct ".sprintf('%o',$n).")";
      }
      if (! defined $min_width || $w < $min_width) {
        $min_width = $w;
        $min_pos = "$x,$y n=$n (oct ".sprintf('%o',$n).")";
      }
    }
    # print "  max $max_width   at $max_x,$max_y\n";

    my $factor = $max_width / $prev_max;
    print "  min width $min_width oct ".sprintf('%o',$min_width)."   at $min_pos  factor $factor\n";
    #    print "  max width $max_width oct ".sprintf('%o',$max_width)."   at $max_pos  factor $factor\n";

    # print "  cf formula ",(10*4**($level-1) - 1)/3,"\n";
    # print "  cf formula ",2* (4**($level-0) - 1)/3,"\n";
    print "  cf formula ",2*4**($level-1),"\n";

    $prev_max = $max_width;
  }
  exit 0;
}
