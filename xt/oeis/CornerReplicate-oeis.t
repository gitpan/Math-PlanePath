#!/usr/bin/perl -w

# Copyright 2012, 2013 Kevin Ryde

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

use Math::PlanePath::CornerReplicate;
use Math::PlanePath::ZOrderCurve;

# uncomment this to run the ### lines
#use Smart::Comments '###';

my $crep = Math::PlanePath::CornerReplicate->new;
my $zorder = Math::PlanePath::ZOrderCurve->new;

#------------------------------------------------------------------------------
# A048647 -- permutation N at transpose Y,X

MyOEIS::compare_values
  (anum => 'A048647',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $crep->n_start; @got < $count; $n++) {
       my ($x, $y) = $crep->n_to_xy ($n);
       ($x, $y) = ($y, $x);
       my $n = $crep->xy_to_n ($x, $y);
       push @got, $n;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A163241 -- flip base-4 digits 2,3 maps to ZOrderCurve

MyOEIS::compare_values
  (anum => 'A163241',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $crep->n_start; @got < $count; $n++) {
       my ($x, $y) = $crep->n_to_xy ($n);
       my $n = $zorder->xy_to_n ($x, $y);
       push @got, $n;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
