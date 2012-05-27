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
use List::MoreUtils;
use POSIX 'floor';
use Math::Libm 'M_PI', 'hypot';
use List::Util 'min', 'max';

use lib 'xt';

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
use Smart::Comments;


{
  # Dir4 maximum
  require Math::PlanePath::CubicBase;
  require Math::NumSeq::PlanePathDelta;
  require Math::BigInt;
  my $path = Math::PlanePath::CubicBase->new;
  my $seq = Math::NumSeq::PlanePathDelta->new (planepath => 'CubicBase',
                                               delta_type => 'Dir4');
  my $dir4_max = 0;
  foreach my $level (0 .. 600) {
    my $n = Math::BigInt->new(2)**$level - 1;
    my $dir4 = $seq->ith($n);
    if (1 || $dir4 > $dir4_max) {
      $dir4_max = $dir4;
      my ($dx,$dy) = path_n_dxdy($path,$n);
      printf "%3d  %2b,\n    %2b %8.6f\n", $n, abs($dx),abs($dy), $dir4;
    }
  }
  exit 0;

  sub path_n_dxdy {
    my ($path, $n) = @_;
    my ($x,$y) = $path->n_to_xy($n);
    my ($next_x,$next_y) = $path->n_to_xy($n+1);
    return ($next_x - $x,
            $next_y - $y);
  }
}
