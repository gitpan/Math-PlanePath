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
use Math::BigInt;

# uncomment this to run the ### lines
#use Devel::Comments '###';

use lib 't';
use MyTestHelpers;

my $test_count = 16;
plan tests => $test_count;

MyTestHelpers::diag ('Math::BigInt version ', Math::BigInt->VERSION);
{
  my $n = Math::BigInt->new(2) ** 256;
  my $int = int($n);
  if (! ref $int) {
    MyTestHelpers::diag ('skip due to Math::BigInt no "int" operator');
    foreach (1 .. $test_count) {
      skip ('due to no Math::BigInt "**" operator', 1, 1);
    }
    exit 0;
  }
}

MyTestHelpers::nowarnings();


#------------------------------------------------------------------------------
# PeanoCurve

require Math::PlanePath::PeanoCurve;
{
  my $path = Math::PlanePath::PeanoCurve->new;

  require Math::BigInt;
  my $n = Math::BigInt->new(9) ** 128 + 2;
  my $want_x = Math::BigInt->new(3) ** 128 + 2;
  my $want_y = Math::BigInt->new(3) ** 128 - 1;

  my ($got_x,$got_y) = $path->n_to_xy($n);
  ok ($got_x, $want_x);
  ok ($got_y, $want_y);
}

#------------------------------------------------------------------------------
# ZOrderCurve

require Math::PlanePath::ZOrderCurve;
{
  my $path = Math::PlanePath::ZOrderCurve->new;

  require Math::BigInt;
  my $n = Math::BigInt->new(4) ** 128 + 9;
  my $want_x = Math::BigInt->new(2) ** 128 + 1;
  my $want_y = 2;

  my ($got_x,$got_y) = $path->n_to_xy($n);
  ok ($got_x, $want_x);
  ok ($got_y, $want_y);
}

#------------------------------------------------------------------------------
# KochCurve

require Math::PlanePath::KochCurve;
{
  my $orig = Math::BigInt->new(3) ** 128 + 2;
  my $n    = Math::BigInt->new(3) ** 128 + 2;
  my ($pow,$exp) = Math::PlanePath::KochCurve::_round_down_pow($n,3);

  ok ($n, $orig);
  ok ($pow, Math::BigInt->new(3) ** 128);
  ok ($exp, 128);
}
{
  my $orig = Math::BigInt->new(3) ** 128;
  my $n    = Math::BigInt->new(3) ** 128;
  my ($pow,$exp) = Math::PlanePath::KochCurve::_round_down_pow($n,3);

  ok ($n, $orig);
  ok ($pow, Math::BigInt->new(3) ** 128);
  ok ($exp, 128);
}

#------------------------------------------------------------------------------
# RationalsTree

require Math::PlanePath::RationalsTree;
{
  my $path = Math::PlanePath::RationalsTree->new (tree_type => 'CW');

  require Math::BigInt;
  my $n = Math::BigInt->new(2) ** 256 - 1;
  my $want_x = 256;
  my $want_y = 1;

  my ($got_x,$got_y) = $path->n_to_xy($n);
  ok ($got_x, $want_x);
  ok ($got_y, $want_y);
}

{
  my $path = Math::PlanePath::RationalsTree->new (tree_type => 'SB');

  require Math::BigInt;
  my $n = Math::BigInt->new(2) ** 256 - 1;
  my $want_x = 256;
  my $want_y = 1;

  my ($got_x,$got_y) = $path->n_to_xy($n);
  ok ($got_x, $want_x);
  ok ($got_y, $want_y);
}

{
  my $path = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');

  # cf 2^256 - 1 gives fibonacci F[k]/F[k+1]
  require Math::BigInt;
  my $n = Math::BigInt->new(2) ** 256 + 1;
  my $want_x = 1;
  my $want_y = 257;

  my ($got_x,$got_y) = $path->n_to_xy($n);
  ok ($got_x, $want_x);
  ok ($got_y, $want_y);
}


exit 0;
