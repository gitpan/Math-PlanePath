#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012 Kevin Ryde

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
use POSIX qw(floor ceil);
use List::Util qw(min max);
use Module::Load;
use Math::PlanePath::Base::Digits 'round_down_pow';

# uncomment this to run the ### lines
#use Smart::Comments;

{
  my $path_class;
  require Math::PlanePath::Hypot;
  require Math::PlanePath::PythagoreanTree;
  require Math::PlanePath::SquareArms;
  require Math::PlanePath::CellularRule54;
  require Math::PlanePath::SquareReplicate;
  require Math::PlanePath::DivisibleColumns;
  require Math::PlanePath::DiamondSpiral;
  require Math::PlanePath::DekkingCurve;
  require Math::PlanePath::DekkingStraight;
  require Math::PlanePath::HilbertCurve;
  require Math::PlanePath::Corner;
  require Math::PlanePath::SquareSpiral;
  require Math::PlanePath::PentSpiral;
  require Math::PlanePath::PentSpiralSkewed;
  require Math::PlanePath::HexArms;
  require Math::PlanePath::KochelCurve;
  require Math::PlanePath::KochPeaks;
  require Math::PlanePath::MPeaks;
  require Math::PlanePath::CincoCurve;
  require Math::PlanePath::DiagonalRationals;
  require Math::PlanePath::FactorRationals;
  require Math::PlanePath::VogelFloret;
  require Math::PlanePath::CellularRule;
  require Math::PlanePath::AnvilSpiral;
  require Math::PlanePath::CellularRule57;
  require Math::PlanePath::DragonRounded;
  require Math::PlanePath::QuadricIslands;
  require Math::PlanePath::CretanLabyrinth;
  require Math::PlanePath::PeanoHalf;
  require Math::PlanePath::StaircaseAlternating;
  require Math::PlanePath::SierpinskiCurveStair;
  require Math::PlanePath::AztecDiamondRings;
  require Math::PlanePath::PyramidRows;
  require Math::PlanePath::KochSnowflakes;
  require Math::PlanePath::MultipleRings;
  require Math::PlanePath::SacksSpiral;
  require Math::PlanePath::TheodorusSpiral;
  require Math::PlanePath::MooreSpiral;
  require Math::PlanePath::QuintetSide;
  require Math::PlanePath::GosperSide;
  $path_class = 'Math::PlanePath::GosperIslands';
  $path_class = 'Math::PlanePath::QuadricCurve';
  $path_class = 'Math::PlanePath::SierpinskiCurve';
  $path_class = 'Math::PlanePath::LTiling';
  $path_class = 'Math::PlanePath::TerdragonCurve';
  $path_class = 'Math::PlanePath::TerdragonMidpoint';
  $path_class = 'Math::PlanePath::DragonCurve';
  $path_class = 'Math::PlanePath::SierpinskiArrowhead';
  $path_class = 'Math::PlanePath::DragonMidpoint';
  $path_class = 'Math::PlanePath::QuintetCentres';
  $path_class = 'Math::PlanePath::HIndexing';
  $path_class = 'Math::PlanePath::WunderlichMeander';
  $path_class = 'Math::PlanePath::ComplexRevolving';
  $path_class = 'Math::PlanePath::WunderlichSerpentine';
  $path_class = 'Math::PlanePath::Flowsnake';
  $path_class = 'Math::PlanePath::FractionsTree';
  $path_class = 'Math::PlanePath::RationalsTree';
  $path_class = 'Math::PlanePath::R5DragonCurve';
  $path_class = 'Math::PlanePath::R5DragonMidpoint';
  $path_class = 'Math::PlanePath::BetaOmega';
  $path_class = 'Math::PlanePath::AR2W2Curve';
  $path_class = 'Math::PlanePath::CCurve';

  $path_class = 'Math::PlanePath::NxN';
  $path_class = 'Math::PlanePath::NxNinv';
  $path_class = 'Math::PlanePath::Dispersion';
  $path_class = 'Math::PlanePath::DiagonalsOctant';
  $path_class = 'Math::PlanePath::Diagonals';
  $path_class = 'Math::PlanePath::GcdRationals';
  $path_class = 'Math::PlanePath::WythoffArray';
  $path_class = 'Math::PlanePath::KochSquareflakes';
  $path_class = 'Math::PlanePath::UlamWarburtonQuarter';
  $path_class = 'Math::PlanePath::TerdragonRounded';
  $path_class = 'Math::PlanePath::CornerReplicate';
  $path_class = 'Math::PlanePath::SierpinskiArrowheadCentres';
  $path_class = 'Math::PlanePath::QuintetCurve';
  $path_class = 'Math::PlanePath::FilledRings';
  $path_class = 'Math::PlanePath::HilbertSpiral';
  $path_class = 'Math::PlanePath::HilbertCurve';
  $path_class = 'Math::PlanePath::FlowsnakeCentres';
  $path_class = 'Math::PlanePath::AlternatePaperMidpoint';
  $path_class = 'Math::PlanePath::AlternatePaper';
  $path_class = 'Math::PlanePath::GreekKeySpiral';
  $path_class = 'Math::PlanePath::TriangularHypot';
  $path_class = 'Math::PlanePath::ComplexMinus';
  $path_class = 'Math::PlanePath::QuintetReplicate';
  $path_class = 'Math::PlanePath::GosperReplicate';
  $path_class = 'Math::PlanePath::ComplexPlus';
  $path_class = 'Math::PlanePath::CubicBase';
  $path_class = 'Math::PlanePath::DigitGroups';
  $path_class = 'Math::PlanePath::GrayCode';
  $path_class = 'Math::PlanePath::ZOrderCurve';
  $path_class = 'Math::PlanePath::ImaginaryBase';
  $path_class = 'Math::PlanePath::ImaginaryHalf';
  $path_class = 'Math::PlanePath::KochCurve';
  $path_class = 'Math::PlanePath::PixelRings';
  $path_class = 'Math::PlanePath::PeanoCurve';
  $path_class = 'Math::PlanePath::TriangleSpiralSkewed';
  $path_class = 'Math::PlanePath::TriangleSpiral';
  $path_class = 'Math::PlanePath::SierpinskiTriangle';
  $path_class = 'Math::PlanePath::HypotOctant';
  $path_class = 'Math::PlanePath::Hypot';


  Module::Load::load($path_class);
  my $path = $path_class->new
    (
     n_start => 37,
     # align => 'diagonal',
     # offset => -0.5,
     # radix => 3,
     # points => 'hex',
     # turns => 1,
     # arms => 8,
     # pairs_order => 'rows_reverse',
     # pairs_order => 'diagonals_down',
     # base => 7,
     # direction => 'up',
     # step => 6,
     # ring_shape => 'polygon',
     # diagonal_length => 5,
     # apply_type => 'FS',
     # serpentine_type => '010_000',
     # straight_spacing => 3,
     # diagonal_spacing => 7,
     # arms => 7,
     # wider => 3,
     # rule => 8,
     # realpart => 1,
     # mirror => 1,
     # divisor_type => 'proper',
     # tree_type => 'Kepler',
     # coordinates => 'PQ',
    );
  ### $path
  my ($prev_x, $prev_y);
  my %seen;
  my $n_start = $path->n_start;
  my $arms_count = $path->arms_count;
  my $path_ref = ref($path);
  print "n_start() $n_start arms_count() $arms_count   $path_ref\n";

   for (my $i = $n_start; $i <= 580; $i+=1) {
    #for (my $i = $n_start; $i <= $n_start + 800000; $i=POSIX::ceil($i*2.01+1)) {

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
    my $xy = (defined $x ? $x : 'undef').','.(defined $y ? $y : 'undef');
    if (defined $seen{$xy}) {
      $rep = "rep$seen{$xy}";
      $seen{$xy} .= ",$i";
    } else {
      $seen{$xy} = $i;
    }

    my @n_list = $path->xy_to_n_list ($x+.0, $y-.0);
    my $n_rev;
    if (@n_list) {
      $n_rev = join(',',@n_list);
    } else {
      $n_rev = 'norev';
    }
    my $rev = '';
    if (@n_list && $n_list[0] ne $seen{$xy}) {
      $rev = 'Rev';
    }

    my ($n_lo, $n_hi) = $path->rect_to_n_range ($x,$y, $x,$y);
    my $range = '';
    if ($n_hi < $i || $n_lo > $i) {
      $range = 'Range';
    }

    my $flag = '';
    if ($rev || $range) {
      $flag = "  ***$rev$range";
    }

    if (! defined $n_lo) { $n_lo = 'undef'; }
    if (! defined $n_hi) { $n_hi = 'undef'; }

    my $iwidth = ($i == int($i) ? 0 : 2);
    printf "%.*f %8.4f,%8.4f   %3s  %s  %s %s %s\n",
      $iwidth,$i,  $x,$y,
        $n_rev,
          "${n_lo}_${n_hi}",
            $dxdy,
              " $rep",
                $flag;

    # %.2f ($x*$x+$y*$y),
  }
  exit 0;
}

__END__
{
  use Math::PlanePath::KochCurve;
  package Math::PlanePath::KochCurve;
  sub rect_to_n_range {
    my ($self, $x1,$y1, $x2,$y2) = @_;

    $y1 = round_nearest ($y1);
    $y2 = round_nearest ($y2);
    if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1) }
    if ($y2 < 0) {
      return (1,0);
    }

    $x1 = round_nearest ($x1);
    $x2 = round_nearest ($x2);
    if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1) }
    ### rect_to_n_range(): "$x1,$y1  $x2,$y2"

    my (undef, $top_level) = round_down_pow (max(2, abs($x1), abs($x2)),
                                             3);
    $top_level += 2;
    ### $top_level

    my ($tx,$ty, $dir, $len);
    my $intersect_rect_p = sub {
      if ($dir < 0) {
        $dir += 6;
      } elsif ($dir > 5) {
        $dir -= 6;
      }
      my $left_x = $tx;
      my $peak_y = $ty;
      my $offset;
      if ($dir & 1) {
        # pointing downwards
        if ($dir == 1) {
          $left_x -= $len-1;  # +1 to exclude left edge
          $peak_y += $len;
        } elsif ($dir == 3) {
          $left_x -= 2*$len;
        } else {
          $peak_y++;  # exclude top edge
        }
        if ($peak_y < $y1) {
          ### all below ...
          return 0;
        }
        $offset = $y2 - $peak_y;

      } else {
        # pointing upwards
        if ($dir == 2) {
          $left_x -= 2*$len;
        } elsif ($dir == 4) {
          $left_x -= $len;
          $peak_y -= $len-1;  # +1 exclude bottom edge
        }
        if ($peak_y > $y2) {
          ### all above ...
          return 0;
        }
        $offset = $peak_y - $y1;
      }
      my $right_x = $left_x + 2*($len-1);
      if ($offset > 0) {
        $left_x += $offset;
        $right_x -= $offset;
      }
      ### $offset
      ### $left_x
      ### $right_x
      ### result: ($left_x <= $x2 && $right_x >= $x1)
      return ($left_x <= $x2 && $right_x >= $x1);
    };

    my @pending_tx = (0);
    my @pending_ty = (0);
    my @pending_dir = (0);
    my @pending_level = ($top_level);
    my @pending_n = (0);

    my $n_lo;
    for (;;) {
      if (! @pending_tx) {
        ### nothing in rectangle for low ...
        return (1,0);
      }
      $tx = pop @pending_tx;
      $ty = pop @pending_ty;
      $dir = pop @pending_dir;
      my $level = pop @pending_level;
      my $n = pop @pending_n;
      $len = 3**$level;

      ### pop for low ...
      ### n: sprintf('0x%X',$n)
      ### $level
      ### $len
      ### $tx
      ### $ty
      ### $dir

      unless (&$intersect_rect_p()) {
        next;
      }
      $level--;
      if ($level < 0) {
        $n_lo = $n;
        last;
      }
      $n *= 4;
      $len = 3**$level;

      ### descend: "len=$len"
      push @pending_tx, $tx+4*$len;
      push @pending_ty, $ty;
      push @pending_dir, $dir;
      push @pending_level, $level;
      push @pending_n, $n+3;

      push @pending_tx, $tx+3*$len;
      push @pending_ty, $ty;
      push @pending_dir, $dir-1;
      push @pending_level, $level;
      push @pending_n, $n+2;

      push @pending_tx, $tx+2*$len;
      push @pending_ty, $ty;
      push @pending_dir, $dir+1;
      push @pending_level, $level;
      push @pending_n, $n+1;

      push @pending_tx, $tx;
      push @pending_ty, $ty;
      push @pending_dir, $dir;
      push @pending_level, $level;
      push @pending_n, $n;
    }

    ### high ...

    @pending_tx = (0);
    @pending_ty = (0);
    @pending_dir = (0);
    @pending_level = ($top_level);
    @pending_n = (0);

    for (;;) {
      if (! @pending_tx) {
        ### nothing in rectangle for high ...
        return (1,0);
      }
      $tx = pop @pending_tx;
      $ty = pop @pending_ty;
      $dir = pop @pending_dir;
      my $level = pop @pending_level;
      my $n = pop @pending_n;

      ### pop for high ...
      ### n: sprintf('0x%X',$n)
      ### $level
      ### $len
      ### $tx
      ### $ty
      ### $dir

      $len = 3**$level;
      unless (&$intersect_rect_p()) {
        next;
      }
      $level--;
      if ($level < 0) {
        return ($n_lo, $n);
      }
      $n *= 4;
      $len = 3**$level;

      ### descend
      push @pending_tx, $tx;
      push @pending_ty, $ty;
      push @pending_dir, $dir;
      push @pending_level, $level;
      push @pending_n, $n;

      push @pending_tx, $tx+2*$len;
      push @pending_ty, $ty;
      push @pending_dir, $dir+1;
      push @pending_level, $level;
      push @pending_n, $n+1;

      push @pending_tx, $tx+3*$len;
      push @pending_ty, $ty;
      push @pending_dir, $dir-1;
      push @pending_level, $level;
      push @pending_n, $n+2;

      push @pending_tx, $tx+4*$len;
      push @pending_ty, $ty;
      push @pending_dir, $dir;
      push @pending_level, $level;
      push @pending_n, $n+3;
    }
  }
}
{
  require Math::PlanePath::KochSnowflakes;
  my $path = Math::PlanePath::KochSnowflakes->new;
  my @range = $path->rect_to_n_range (0,0, 0,2);
  ### @range
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



