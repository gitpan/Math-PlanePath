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
plan tests => 2;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use List::Util 'min', 'max';
use Math::PlanePath::TriangleSpiral;
use Math::PlanePath::TriangleSpiralSkewed;

# uncomment this to run the ### lines
#use Smart::Comments '###';

#------------------------------------------------------------------------------
# A217010 -- N values by SquareSpiral order

MyOEIS::compare_values
  (anum => 'A217010',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::SquareSpiral;
     my $tsp = Math::PlanePath::TriangleSpiralSkewed->new;
     my $square = Math::PlanePath::SquareSpiral->new;
     my @got;
     for (my $n = $square->n_start; @got < $count; $n++) {
       my ($x, $y) = $square->n_to_xy ($n);
       push @got, $tsp->xy_to_n ($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A217291 -- inverse, TriangleSpiralSkewed X,Y order, SquareSpiral N

MyOEIS::compare_values
  (anum => 'A217291',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::SquareSpiral;
     my $tsp = Math::PlanePath::TriangleSpiralSkewed->new;
     my $square = Math::PlanePath::SquareSpiral->new;
     my @got;
     for (my $n = $tsp->n_start; @got < $count; $n++) {
       my ($x, $y) = $tsp->n_to_xy ($n);
       push @got, $square->xy_to_n ($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
