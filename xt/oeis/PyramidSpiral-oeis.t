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


# A217295 Permutation of natural numbers arising from applying the walk of triangular horizontal-last spiral (defined in A214226) to the data of square spiral (e.g. A214526).
# A214227 -- sum of 4 neighbours horizontal-last


use 5.004;
use strict;
use Test;
plan tests => 4;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::PyramidSpiral;

# uncomment this to run the ### lines
#use Smart::Comments '###';


#------------------------------------------------------------------------------
# A217013 - inverse permutation, SquareSpiral -> PyramidSpiral
#   X,Y in SquareSpiral order, N of PyramidSpiral

MyOEIS::compare_values
  (anum => 'A217013',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::SquareSpiral;
     my $pyramid = Math::PlanePath::PyramidSpiral->new;
     my $square  = Math::PlanePath::SquareSpiral->new;
     my @got;
     for (my $n = $square->n_start; @got < $count; $n++) {
       my ($x, $y) = $square->n_to_xy($n);
       ($x,$y) = (-$y,$x);  # rotate +90
       push @got, $pyramid->xy_to_n($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A217294 - permutation PyramidSpiral -> SquareSpiral
#   X,Y in PyramidSpiral order, N of SquareSpiral
#   but A217294 conceived by square spiral going up and clockwise
#                        and pyramid spiral going left and clockwise
#     which means rotate -90 here

MyOEIS::compare_values
  (anum => 'A217294',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::SquareSpiral;
     my $pyramid = Math::PlanePath::PyramidSpiral->new;
     my $square  = Math::PlanePath::SquareSpiral->new;
     my @got;
     for (my $n = $pyramid->n_start; @got < $count; $n++) {
       my ($x, $y) = $pyramid->n_to_xy($n);
       ($x,$y) = ($y,-$x);  # rotate -90
       push @got, $square->xy_to_n($x,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A053615 -- distance to pronic is abs(X)

MyOEIS::compare_values
  (anum => 'A053615',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::PyramidSpiral->new;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, abs($x);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A214250 -- sum of 8 neighbours N

MyOEIS::compare_values
  (anum => 'A214250',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::PyramidSpiral->new;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy ($n);
       push @got, ($path->xy_to_n($x+1,$y)
                   + $path->xy_to_n($x-1,$y)
                   + $path->xy_to_n($x,$y+1)
                   + $path->xy_to_n($x,$y-1)
                   + $path->xy_to_n($x+1,$y+1)
                   + $path->xy_to_n($x-1,$y-1)
                   + $path->xy_to_n($x-1,$y+1)
                   + $path->xy_to_n($x+1,$y-1)
                  );
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
