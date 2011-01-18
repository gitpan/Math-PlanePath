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

use strict;
use warnings;
use Smart::Comments;

{
  require Math::PlanePath::SacksSpiral;
  require Math::PlanePath::VogelFloret;
  require Math::PlanePath::PyramidRows;
  require Math::PlanePath::Diagonals;
  require Math::PlanePath::Corner;
  require Math::PlanePath::DiamondSpiral;
  require Math::PlanePath::PyramidSides;
  require Math::PlanePath::HexSpiral;
  require Math::PlanePath::HexSpiralSkewed;
  require Math::PlanePath::KnightSpiral;
  require Math::PlanePath::SquareSpiral;
  require Math::PlanePath::MultipleRings;
  require Math::PlanePath::HilbertCurve;
  require App::MathImage::PlanePath::OctagramSpiral;
  require Math::PlanePath::Staircase;
  require Math::PlanePath::PeanoCurve;
  require App::MathImage::PlanePath::Flowsnake;
  require Math::PlanePath::PyramidRows;

  # App::MathImage::PlanePath::Flowsnake
  my $path = Math::PlanePath::PyramidRows->new (wider => 0,
                                                # step => 0,
                                               );
  my ($prev_x, $prev_y);
  my %seen;
  foreach my $i (0 .. 7*7*7+10) {
    # $i -= 0.5;
    my ($x, $y) = $path->n_to_xy ($i) or next;
    # next unless $x < 0; # abs($x)>abs($y) && $x > 0;

    my $dxdy = '';
    if (defined $prev_x) {
      my $dx = $x - $prev_x;
      my $dy = $y - $prev_y;
      $dxdy = "$dx,$dy";
    }
    $prev_x = $x;
    $prev_y = $y;

    my $rep = '';
    my $xy = "$x,$y";
    if (defined $seen{$xy}) {
      $rep = "rep$seen{$xy}";
    } else {
      $seen{$xy} = $i;
    }

    my $n = $path->xy_to_n ($x+.0, $y+.0) // 'norev';
    my ($n_lo, $n_hi) = $path->rect_to_n_range ($x,$y, $x,$y);

    my $rev = '';
    if ($i ne $n) {
      $rev = 'Rev';
    }

    my $range = '';
    if ($n_hi < $i) {
      $range = 'Range';
    }

    my $flag = '';
    if ($rev || $range) {
      $flag = "  ***$rev$range";
    }

    if (! defined $n_lo) { $n_lo = 'undef'; }
    if (! defined $n_hi) { $n_hi = 'undef'; }


    printf "%3d %8.4f,%8.4f   %3s %s %s %s %s\n",
      $i,  $x,$y,  $n,
        "${n_lo}_${n_hi}",
          " $dxdy",
            " $rep",
              $flag;
  }
  exit 0;
}



