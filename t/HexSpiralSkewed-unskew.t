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

use 5.004;
use strict;
use Test;
plan tests => 80;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use Math::PlanePath::HexSpiral;
use Math::PlanePath::HexSpiralSkewed;


my $plain  = Math::PlanePath::HexSpiral->new;
my $skewed = Math::PlanePath::HexSpiralSkewed->new;

foreach my $n (1 .. 20) {
  my ($plain_x, $plain_y)   = $plain->n_to_xy ($n);
  my ($skewed_x, $skewed_y) = $skewed->n_to_xy ($n);
  {
    my ($conv_x,$conv_y) = (($plain_x-$plain_y)/2, $plain_y);
    ok ($conv_x, $skewed_x,
        "plain->skewed x at n=$n plain $plain_x,$plain_y skewed $skewed_x,$skewed_y");
    ok ($conv_y, $skewed_y, "plain->skewed y at n=$n");
  }
  {
    my ($conv_x,$conv_y) = ((2*$skewed_x+$skewed_y), $plain_y);
    ok ($conv_x, $plain_x, "skewed->plain x at n=$n");
    ok ($conv_y, $plain_y, "skewed->plain y at n=$n");
  }
}

exit 0;
