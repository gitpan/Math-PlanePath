#!/usr/bin/perl -w

# Copyright 2014 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
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
use List::Util 'min','max';
use Test;
plan tests => 637;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }

use lib 'xt';
use MyOEIS;

# uncomment this to run the ### lines
#use Smart::Comments;

use Math::PlanePath::CCurve;

my $path = Math::PlanePath::CCurve->new;

#------------------------------------------------------------------------------
# claimed in the pod N overlaps have different count 1-bits mod 4

{
  foreach my $n (0 .. 100_000) {
    my ($x,$y) = $path->n_to_xy($n);
    my @n_list = $path->xy_to_n_list($x,$y);
    my @seen;
    foreach my $n (@n_list) {
      my $c = count_1_bits($n) % 4;
      if ($seen[$c]++) {
        die;
      }
    }
  }
  ok (1,1);
}

sub count_1_bits {
  my ($n) = @_;
  my $count = 0;
  while ($n) {
    $count += ($n & 1);
    $n >>= 1;
  }
  return $count;
}


#------------------------------------------------------------------------------
exit 0;
