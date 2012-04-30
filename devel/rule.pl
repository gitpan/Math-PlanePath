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

use strict;
use Math::PlanePath::CellularRule;

{
  my $rule = 57;
  my $path = Math::PlanePath::CellularRule->new(rule=>$rule);
  my @ys = (5..20);
  @ys = map{$_*2+1} @ys;
  my @ns = map{$path->xy_to_n(-$_,$_)
             }@ys;
  my @diffs = map {$ns[$_]-$ns[$_-1]} 1 .. $#ns;
  print "[",join(',',@diffs),"]\n";
  my @dds = map {$diffs[$_]-$diffs[$_-1]} 1 .. $#diffs;
  print "[",join(',',@dds),"]\n";
  exit 0;
}

{
  my $rule = 57;
  my $path = Math::PlanePath::CellularRule->new(rule=>$rule);
  my @ys = (5..10);
  @ys = map{$_*2+1} @ys;
  print "[",join(',',@ys),"]\n";
  print "[",join(',',map{$path->xy_to_n(-$_,$_)
                         }@ys),"]\n";
  exit 0;
}

