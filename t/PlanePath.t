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

use 5.004;
use strict;
use Test;
plan tests => 29;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Devel::Comments;

require Math::PlanePath;

#----------------------------------------------------------------------------
# _divrem()

{
  my $n = 123;
  my ($q,$r) = Math::PlanePath::_divrem($n,5);
  ok ("$n", 123);
  ok ("$q", 24);
  ok ("$r", 3);
}

{
  # perl 5.6 did integer divisions in IV or something, exercise only up to ~0>>1
  my $n = ~0 >> 1;
  foreach my $d (2,3,4, 5, 6,7,8,9, 10, 16, 37) {
    my ($q,$r) = Math::PlanePath::_divrem($n,$d);
    my $m = $q * $d + $r;
    ok ($n, $m, "_divrem() ~0=$n / $d got q=$q rem=$r");
  }
}

#----------------------------------------------------------------------------
# _divrem_mutate()

{
  my $n = 123;
  my $r = Math::PlanePath::_divrem_mutate($n,5);
  ok ("$n", 24);
  ok ("$r", 3);
}
{
  my $n = -123;
  my $r = Math::PlanePath::_divrem_mutate($n,5);
  ok ("$n", -25);
  ok ("$r", 2);
}

{
  foreach my $d (2,3,4, 5, 6,7,8,9, 10, 16, 37) {
    # perl 5.6 did integer divisions in IV or something, exercise only to ~0>>1
    my $n = ~0 >> 1;
    my $q = $n;
    my $r = Math::PlanePath::_divrem_mutate($q,$d);
    my $m = $q * $d + $r;
    ok ($n, $m, "_divrem_mutate() ~0=$n / $d got q=$q rem=$r");
  }
}

#------------------------------------------------------------------------------
exit 0;
