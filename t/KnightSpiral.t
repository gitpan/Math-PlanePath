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

use 5.004;
use strict;
use warnings;
use Test::More tests => 1010;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

require Math::PlanePath::KnightSpiral;


#------------------------------------------------------------------------------
# VERSION

{
  my $want_version = 11;
  is ($Math::PlanePath::KnightSpiral::VERSION, $want_version,
      'VERSION variable');
  is (Math::PlanePath::KnightSpiral->VERSION,  $want_version,
      'VERSION class method');

  ok (eval { Math::PlanePath::KnightSpiral->VERSION($want_version); 1 },
      "VERSION class check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { Math::PlanePath::KnightSpiral->VERSION($check_version); 1 },
      "VERSION class check $check_version");

  my $path = Math::PlanePath::KnightSpiral->new;
  is ($path->VERSION,  $want_version, 'VERSION object method');

  ok (eval { $path->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  ok (! eval { $path->VERSION($check_version); 1 },
      "VERSION object check $check_version");
}

#------------------------------------------------------------------------------
# x_negative, y_negative

{
  ok (Math::PlanePath::KnightSpiral->x_negative, 'x_negative() class method');
  ok (Math::PlanePath::KnightSpiral->y_negative, 'y_negative() class method');
  my $path = Math::PlanePath::KnightSpiral->new (height => 123);
  ok ($path->x_negative, 'x_negative() instance method');
  ok ($path->y_negative, 'y_negative() instance method');
}

#------------------------------------------------------------------------------
# xy_to_n

{
  my $path = Math::PlanePath::KnightSpiral->new;
  my ($x, $y) = $path->n_to_xy(1);
  foreach my $n (2 .. 1000) {
    my ($nx, $ny) = $path->n_to_xy($n);
    # diag "n=$n  $nx,$ny";
    my $dx = abs($nx - $x);
    my $dy = abs($ny - $y);
    ok (($dx == 2 && $dy == 1)
        || ($dx == 1 && $dy == 2),
        "step n=$n from $x,$y to $nx,$ny   D=$dx,$dy");
    ($x,$y) = ($nx,$ny);
  }
}

exit 0;
