#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

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
plan tests => 3;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::Corner;

# uncomment this to run the ### lines
#use Smart::Comments '###';


#------------------------------------------------------------------------------
# A004201 -- N for which Y<=X, half below diagonal

MyOEIS::compare_values
  (anum => 'A004201',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::Corner->new;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       if ($x >= $y) {
         push @got, $n;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A020703 -- permutation transpose Y,X

MyOEIS::compare_values
  (anum => 'A020703',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::Corner->new;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, $path->xy_to_n ($y, $x);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A053188 -- abs(X-Y), distance to next higher pronic, wider=1, extra 0

MyOEIS::compare_values
  (anum => 'A053188',
   func => sub {
     my ($count) = @_;
     my @got = (0);  # extra initial 0
     my $path = Math::PlanePath::Corner->new (wider => 1);
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       push @got, abs($x-$y);
     }
     return \@got;
   });


#------------------------------------------------------------------------------
exit 0;
