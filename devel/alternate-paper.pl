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

# uncomment this to run the ### lines
#use Smart::Comments;


{
  require Math::PlanePath::AlternatePaper;
  require Math::BaseCnv;
  my $path = Math::PlanePath::AlternatePaper->new;
  for my $x (0 .. 40) {
    my $y;
    $y = 0;
    $y = $x;

    my $n = $path->xy_to_n($x,$y);
    my $n2 = Math::BaseCnv::cnv($n,10,2);
    my $n4 = Math::BaseCnv::cnv($n,10,4);
    printf "%10s %10s  %d %d,%d\n", $n2, $n4, $n,$x,$y;
  }
  exit 0;
}
