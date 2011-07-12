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
use Test;
use Math::BigFloat;
use Math::PlanePath::PeanoCurve;
use Math::PlanePath::ZOrderCurve;

use lib 't';
use MyTestHelpers;

# uncomment this to run the ### lines
#use Smart::Comments '###';

my $test_count = 4;
plan tests => $test_count;

{
  if (! eval { Math::BigFloat->new(2) ** 3 }) {
    MyTestHelpers::diag ('skip due to Math::BigFloat no "**" operator -- ',$@);
    foreach (1 .. $test_count) {
      skip ('due to no Math::BigFloat "**" operator', 1, 1);
    }
    exit 0;
  }
}

MyTestHelpers::nowarnings();

Math::BigFloat->precision(256);  # digits

#------------------------------------------------------------------------------
# PeanoCurve

{
  my $path = Math::PlanePath::PeanoCurve->new;

  require Math::BigFloat;
  my $n = Math::BigFloat->new(9) ** 128 + 1.5;
  my $want_x = Math::BigFloat->new(3) ** 128 + 1.5;
  my $want_y = Math::BigFloat->new(3) ** 128 - 1;

  my ($got_x,$got_y) = $path->n_to_xy($n);
  ok ($got_x, $want_x);
  ok ($got_y, $want_y);
}

#------------------------------------------------------------------------------
# ZOrderCurve

{
  my $path = Math::PlanePath::ZOrderCurve->new;

  require Math::BigFloat;
  my $n = Math::BigFloat->new(4) ** 128 + 0.5;
  my $want_x = Math::BigFloat->new(2) ** 128 + 0.5;
  my $want_y = 0;

  my ($got_x,$got_y) = $path->n_to_xy($n);
  ok ($got_x, $want_x);
  ok ($got_y, $want_y);
}

exit 0;
