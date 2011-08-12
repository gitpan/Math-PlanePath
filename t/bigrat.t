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
use Math::PlanePath::KochCurve;
use Math::PlanePath::PeanoCurve;
use Math::PlanePath::ZOrderCurve;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Devel::Comments '###';


my $test_count = 30;
plan tests => $test_count;

MyTestHelpers::diag ('Math::BigRat version ', Math::BigRat->VERSION);
if (! eval { require Math::BigRat; 1 }) {
  MyTestHelpers::diag ('skip due to Math::BigRat not available -- ',$@);
  foreach (1 .. $test_count) {
    skip ('due to no Math::BigRat', 1, 1);
  }
  exit 0;
}

# Crib notes:
#
# In perl 5.8.4 "BigInt != BigRat" doesn't work, must have it other way
# around as "BigRat != BigInt".  Symptom is "uninitialized" warnings.
#


{
  my $f = Math::BigRat->new('-1/2');
  my $int = int($f);
  if ($int == 0) {
    MyTestHelpers::diag ('BigRat has int(-1/2) == 0 correctly');
  } else {
    MyTestHelpers::diag ('BigRat has int(-1/2) != 0 dodginess: ',"$int");
  }
}

#------------------------------------------------------------------------------
# _round_nearest()

ok (Math::PlanePath::_round_nearest(Math::BigRat->new('-7/4')) == -2, 1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('-3/2')) == -1,  1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('-5/4')) == -1,  1);

ok (Math::PlanePath::_round_nearest(Math::BigRat->new('-3/4')) == -1, 1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('-1/2')) == 0,  1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('-1/4')) == 0,  1);

ok (Math::PlanePath::_round_nearest(Math::BigRat->new('1/4')) == 0,  1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('5/4')) == 1,  1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('3/2')) == 2,  1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('7/4')) == 2,  1);
ok (Math::PlanePath::_round_nearest(Math::BigRat->new('2'))   == 2,  1);

#------------------------------------------------------------------------------
# _floor()

ok (Math::PlanePath::_floor(Math::BigRat->new('-7/4')) == -2,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('-3/2')) == -2,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('-5/4')) == -2,  1);

ok (Math::PlanePath::_floor(Math::BigRat->new('-3/4')) == -1,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('-1/2')) == -1,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('-1/4')) == -1,  1);

ok (Math::PlanePath::_floor(Math::BigRat->new('1/4')) == 0,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('3/4')) == 0,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('5/4')) == 1,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('3/2')) == 1,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('7/4')) == 1,  1);
ok (Math::PlanePath::_floor(Math::BigRat->new('2'))   == 2,  1);

#------------------------------------------------------------------------------
# PeanoCurve

{
  my $path = Math::PlanePath::PeanoCurve->new;

  require Math::BigRat;
  my $n = Math::BigRat->new(9) ** 128 + Math::BigRat->new(4/3);
  my $want_x = Math::BigRat->new(3) ** 128 + Math::BigRat->new(4/3);
  my $want_y = Math::BigRat->new(3) ** 128 - 1;

  my ($got_x,$got_y) = $path->n_to_xy($n);
  ok ($got_x, $want_x);
  ok ($got_y, $want_y);
}

#------------------------------------------------------------------------------
# ZOrderCurve

{
  my $path = Math::PlanePath::ZOrderCurve->new;

  require Math::BigRat;
  my $n = Math::BigRat->new(4) ** 128 + Math::BigRat->new(1/3);
  $n->isa('Math::BigRat') || die "Oops, n not a BigRat";
  my $want_x = Math::BigRat->new(2) ** 128 + Math::BigRat->new(1/3);
  my $want_y = 0;

  my ($got_x,$got_y) = $path->n_to_xy($n);
  ok ($got_x, $want_x);
  ok ($got_y, $want_y);
}

#------------------------------------------------------------------------------
# KochCurve

{
  my $orig = Math::BigRat->new(3) ** 128 + Math::BigRat->new('1/7');
  my $n    = Math::BigRat->new(3) ** 128 + Math::BigRat->new('1/7');
  my ($pow,$exp) = Math::PlanePath::KochCurve::_round_down_pow3($n);

  ok ($n, $orig);
  ok ($pow, Math::BigRat->new(3) ** 128);
  ok ($exp, 128);
}

exit 0;
