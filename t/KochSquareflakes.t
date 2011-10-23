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

use 5.004;
use strict;
use Test;
BEGIN { plan tests => 330 }

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }

use Math::PlanePath::KochSquareflakes;


# uncomment this to run the ### lines
#use Devel::Comments;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 49;
  ok ($Math::PlanePath::KochSquareflakes::VERSION, $want_version,
      'VERSION variable');
  ok (Math::PlanePath::KochSquareflakes->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::KochSquareflakes->VERSION($want_version); 1 },
      1,
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::KochSquareflakes->VERSION($check_version); 1 },
      1,
      "VERSION class check $check_version");

  my $path = Math::PlanePath::KochSquareflakes->new;
  ok ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      1,
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      1,
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# n_start, x_negative, y_negative

{
  my $path = Math::PlanePath::KochSquareflakes->new;
  ok ($path->n_start, 1, 'n_start()');
  ok ($path->x_negative, 1, 'x_negative()');
  ok ($path->y_negative, 1, 'y_negative()');
}

#------------------------------------------------------------------------------
# xy_to_n() coverage

foreach my $inward (0, 1) {
  my $path = Math::PlanePath::KochSquareflakes->new (inward => $inward);
  foreach my $x (-10 .. 10) {
    foreach my $y (-10 .. 10) {
      next if $x == 0 && $y == 0;
      my $n = $path->xy_to_n ($x, $y);
      next if ! defined $n;
      ### $n
      my ($nx,$ny) = $path->n_to_xy ($n);
      ok ($nx,$x, "x=$x,y=$y  n=$n  nxy=$nx,$ny");
      ok ($ny,$y);
    }
  }
}

exit 0;
