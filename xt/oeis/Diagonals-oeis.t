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
plan tests => 2;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::Diagonals;

# uncomment this to run the ### lines
#use Smart::Comments '###';


#------------------------------------------------------------------------------
# A215200 -- Kronecker(n-k,k) by rows, n>=1   1<=k<=n
# for n=6 runs n-k=5,4,3,2,1,0      for n=1 runs n-k=0
#                k=1,2,3,4,5,6                     k=1
# x=n-k  y=k  is diagonal up from X axis

MyOEIS::compare_values
  (anum => q{A215200},
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::Diagonals->new (direction => 'up',
                                                 x_start => 0,
                                                 y_start => 1);
     require Math::NumSeq::PlanePathCoord;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy ($n);
                                                 push @got, Math::NumSeq::PlanePathCoord::_kronecker_symbol($x,$y);
                                               }
       return \@got;
   });

#------------------------------------------------------------------------------
# A038722 -- permutation N at transpose Y,X, n_start=1

MyOEIS::compare_values
  (anum => 'A038722',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::Diagonals->new;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $path->xy_to_n ($y, $x);
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => 'A038722',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::Diagonals->new (direction => 'up');
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $path->xy_to_n ($y, $x);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A061579 -- permutation N at transpose Y,X

MyOEIS::compare_values
  (anum => 'A061579',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::Diagonals->new (n_start => 0);
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $path->xy_to_n ($y, $x);
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => 'A061579',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::Diagonals->new (n_start => 0,
                                                 direction => 'up');
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $path->xy_to_n ($y, $x);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
