#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

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
  require Math::PlanePath::PyramidRows;
  require Math::PlanePath::HexSpiral;
  require Math::PlanePath::HexSpiralSkewed;
  require Math::PlanePath::KnightSpiral;
  require Math::PlanePath::SquareSpiral;
  require Math::PlanePath::MultipleRings;
  require Math::PlanePath::HilbertCurve;
  require App::MathImage::PlanePath::Hilbert33;

  my $path = App::MathImage::PlanePath::Hilbert33->new (wider => 0,
                                                        # step => 0,
                                                       );
  foreach my $i (1 .. 64) {
    # $i -= 0.5;
    my ($x, $y) = $path->n_to_xy ($i) or next;
    # next unless $x < 0; # abs($x)>abs($y) && $x > 0;
    my $n = $path->xy_to_n ($x+.0, $y+.0) // 'norev';
    my ($n_lo, $n_hi) = $path->rect_to_n_range (0,$y, $x,$y);
    printf "%3d %8.4f,%8.4f   %3s %s %s\n",
      $i,  $x,$y,  $n,
        "${n_lo}_${n_hi}",
          ($i ne $n || $n_hi < $n ? "  ****" : "");
  }
  exit 0;
}



