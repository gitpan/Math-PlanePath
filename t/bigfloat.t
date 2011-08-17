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
use Math::PlanePath::KochCurve;
use Math::PlanePath::PeanoCurve;
use Math::PlanePath::ZOrderCurve;

use lib 't';
use MyTestHelpers;

# uncomment this to run the ### lines
#use Devel::Comments '###';

my $test_count = 24;
plan tests => $test_count;

MyTestHelpers::diag ('Math::BigFloat version ', Math::BigFloat->VERSION);

{
  if (! eval { Math::BigFloat->new(2) ** 3 }) {
    MyTestHelpers::diag ('skip due to Math::BigFloat no "**" operator -- ',$@);
    foreach (1 .. $test_count) {
      skip ('due to no Math::BigFloat "**" operator', 1, 1);
    }
    exit 0;
  }
}
unless (eval { Math::BigFloat->VERSION(1.993); 1 }) {
  # something fishy for PeanoCurve and ZOrderCurve fraction n_to_xy()
  MyTestHelpers::diag ('skip due to doubtful oldish Math::BigFloat, maybe');
  foreach (1 .. $test_count) {
    skip ('due to oldish Math::BigFloat', 1, 1);
  }
  exit 0;
}

MyTestHelpers::nowarnings();

Math::BigFloat->precision(-20);  # digits right of decimal point

#------------------------------------------------------------------------------
# _round_nearest()

ok (Math::PlanePath::_round_nearest(Math::BigFloat->new('-.75')) == -1,  1);
ok (Math::PlanePath::_round_nearest(Math::BigFloat->new('-.5'))  == 0,  1);
ok (Math::PlanePath::_round_nearest(Math::BigFloat->new('-.25')) == 0,  1);

ok (Math::PlanePath::_round_nearest(Math::BigFloat->new('.25'))  == 0,  1);
ok (Math::PlanePath::_round_nearest(Math::BigFloat->new('1.25')) == 1,  1);
ok (Math::PlanePath::_round_nearest(Math::BigFloat->new('1.5'))  == 2,  1);
ok (Math::PlanePath::_round_nearest(Math::BigFloat->new('1.75')) == 2,  1);
ok (Math::PlanePath::_round_nearest(Math::BigFloat->new('2'))    == 2,  1);

#------------------------------------------------------------------------------
# _floor()

ok (Math::PlanePath::_floor(Math::BigFloat->new('-.75')) == -1,  1);
ok (Math::PlanePath::_floor(Math::BigFloat->new('-.5'))  == -1,  1);
ok (Math::PlanePath::_floor(Math::BigFloat->new('-.25')) == -1,  1);

ok (Math::PlanePath::_floor(Math::BigFloat->new('.25'))  == 0,  1);
ok (Math::PlanePath::_floor(Math::BigFloat->new('.75'))  == 0,  1);
ok (Math::PlanePath::_floor(Math::BigFloat->new('1.25')) == 1,  1);
ok (Math::PlanePath::_floor(Math::BigFloat->new('1.5'))  == 1,  1);
ok (Math::PlanePath::_floor(Math::BigFloat->new('1.75')) == 1,  1);
ok (Math::PlanePath::_floor(Math::BigFloat->new('2'))    == 2,  1);

#------------------------------------------------------------------------------
# PeanoCurve

{
  my $path = Math::PlanePath::PeanoCurve->new;

  require Math::BigFloat;
  my $n = Math::BigFloat->new(9) ** 128 + 1.5;
  my $want_x = Math::BigFloat->new(3) ** 128 + 1.5;
  my $want_y = Math::BigFloat->new(3) ** 128 - 1;

  my ($got_x,$got_y) = $path->n_to_xy($n);
  ok ($got_x == $want_x, 1, "PeanoCurve 9^128 + 1.5 X got $got_x want $want_x");
  ok ($got_y == $want_y, 1, "PeanoCurve 9^128 + 1.5 Y got $got_y want $want_y");
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
  ok ($got_x == $want_x, 1,
      "ZOrderCurve 4^128 + 0.5 X got $got_x want $want_x");
  ok ($got_y == $want_y, 1,
      "ZOrderCurve 4^128 + 0.5 Y got $got_y want $want_y");
}

#------------------------------------------------------------------------------
# KochCurve

{
  my $orig = Math::BigFloat->new(3) ** 64 + 1.25;
  my $n    = Math::BigFloat->new(3) ** 64 + 1.25;
  my ($pow,$exp) = Math::PlanePath::KochCurve::_round_down_pow3($n);

  ok ($n, $orig, "_round_down_pow3() unmodified input");
  ok ($pow == Math::BigFloat->new(3.0) ** 64, 1,
      "_round_down_pow3() 3^64 + 1.25 power");
  ok ($exp, 64, "_round_down_pow3() 3^64 + 1.25 exp");
}

exit 0;
