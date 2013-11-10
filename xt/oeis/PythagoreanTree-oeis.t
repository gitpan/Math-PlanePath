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
BEGIN { MyTestHelpers::nowarnings(); }
use MyOEIS;

use Math::PlanePath::PythagoreanTree;

# uncomment this to run the ### lines
#use Smart::Comments '###';

#------------------------------------------------------------------------------
# A058529 - all prime factors == +/-1 mod 8
#   is differences mid-small legs

MyOEIS::compare_values
  (anum => 'A058529',
   max_count => 35,
   func => sub {
     my ($count) = @_;
     require Math::BigInt;
     my $path = Math::PlanePath::PythagoreanTree->new (coordinates => 'SM');
     my %seen;
     for (my $n = $path->n_start; $n < 100000; $n++) {
       my ($s,$m) = $path->n_to_xy($n);
       my $diff = $m - $s;
       $seen{$diff} = 1;
     }
     my @got = sort {$a<=>$b} keys %seen;
     $#got = $count-1;
     return \@got;
   });

#------------------------------------------------------------------------------
# A003462 = (3^n-1)/2 is tree_depth_to_n_end()

MyOEIS::compare_values
  (anum => 'A003462',
   func => sub {
     my ($count) = @_;
     require Math::BigInt;
     my @got = (0);
     my $path = Math::PlanePath::PythagoreanTree->new;
     for (my $depth = Math::BigInt->new(0); @got < $count; $depth++) {
       push @got, $path->tree_depth_to_n_end($depth);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
