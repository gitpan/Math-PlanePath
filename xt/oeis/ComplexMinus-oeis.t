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
plan tests => 1;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }
use MyOEIS;

# uncomment this to run the ### lines
#use Smart::Comments '###';


use Math::PlanePath::ComplexMinus;
my $path = Math::PlanePath::ComplexMinus->new;

#------------------------------------------------------------------------------
# A066322 - N on X axis, diffs at 16k+3,16k+4

MyOEIS::compare_values
  (anum => 'A066322',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $i = 0; @got < $count; $i++) {
       my $x = 16*$i+3;
       my $x_next = 16*$i+4;
       my $n = $path->xy_to_n ($x,0);
       my $n_next = $path->xy_to_n ($x_next,0);
       push @got, $n_next - $n;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A066323 - N on X axis, count 1 bits

MyOEIS::compare_values
  (anum => 'A066323',
   func => sub {
     my ($count) = @_;
     my @got = (0);
     for (my $x = 1; @got < $count; $x++) {
       my $n = $path->xy_to_n ($x,0);
       push @got, count_1_bits($n);
     }
     return \@got;
   });

sub count_1_bits {
  my ($n) = @_;
  my $count = 0;
  while ($n) {
    $count += ($n & 1);
    $n >>= 1;
  }
  return $count;
}

#------------------------------------------------------------------------------

exit 0;
