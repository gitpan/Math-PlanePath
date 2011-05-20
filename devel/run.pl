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

use 5.006;
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
  require Math::PlanePath::Staircase;
  require Math::PlanePath::PeanoCurve;
  require Math::PlanePath::PyramidRows;
  require Math::PlanePath::OctagramSpiral;
  require Math::PlanePath::MathImageFlowsnake;
  require Math::PlanePath::ArchimedeanChords;
  require Math::PlanePath::Hypot;
  require Math::PlanePath::HypotOctant;
  require Math::PlanePath::PythagoreanTree;
  require Math::PlanePath::GreekKeySpiral;
  require Math::PlanePath::PixelRings;
  require Math::PlanePath::MathImageCoprimeColumns;
  my $path = Math::PlanePath::MathImageCoprimeColumns->new
    (wider => 0,
     # step => 0,
     #tree_type => 'UAD',
     #coordinates => 'PQ',
    );
  my ($prev_x, $prev_y);
  my %seen;
  my $start = $path->n_start;
   for (my $i = $start; $i <= $start + 500000; $i=POSIX::ceil($i*1.1+1)) {
  # for (my $i = 9650; $i <= 9999; $i++) {
  # $i -= 0.5;
  #for (my $i = 0; $i <= 1000; $i++) {
    my ($x, $y) = $path->n_to_xy($i) or next;
    # next unless $x < 0; # abs($x)>abs($y) && $x > 0;

    my $dxdy = '';
    if (defined $prev_x) {
      my $dx = $x - $prev_x;
      my $dy = $y - $prev_y;
      my $d = Math::Libm::hypot($dx,$dy);
      $dxdy = sprintf "%.3f,%.3f(%.4f)", $dx,$dy,$d;
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

    my $n = $path->xy_to_n ($x+.0, $y-.2);
    if (! defined $n) { $n = 'norev'; }

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
{
  require Math::PlanePath::PixelRings;
  my $path = Math::PlanePath::PixelRings->new
    (wider => 0,
     # step => 0,
     #tree_type => 'UAD',
     #coordinates => 'PQ',
    );
  ### xy: $path->n_to_xy(500)
  ### n: $path->xy_to_n(3,3)
  exit 0;
}



