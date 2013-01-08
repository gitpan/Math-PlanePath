#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012, 2013 Kevin Ryde

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
plan tests => 4;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use List::Util 'min', 'max';
use Math::PlanePath::TriangleSpiralSkewed;

# uncomment this to run the ### lines
#use Smart::Comments '###';


#------------------------------------------------------------------------------
# A081272 -- N on slope=2 SSE

MyOEIS::compare_values
  (anum => 'A081272',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::TriangleSpiralSkewed->new;
     my $x = 0;
     my $y = 0;
     while (@got < $count) {
       push @got, $path->xy_to_n ($x,$y);
       $x += 1;
       $y -= 2;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A081275 -- N on X=Y+1 diagonal

MyOEIS::compare_values
  (anum => 'A081275',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::TriangleSpiralSkewed->new (n_start => 0);
     for (my $y = 0; @got < $count; $y++) {
       my $x = $y + 1;
       push @got, $path->xy_to_n ($x,$y);
     }
     return \@got;
   });

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
