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

# uncomment this to run the ### lines
#use Devel::Comments '###';

use Math::PlanePath::CellularRule54;
my $path = Math::PlanePath::CellularRule54->new;

#------------------------------------------------------------------------------
# A118109 - 0/1 by rows

MyOEIS::compare_values
  (anum => 'A118109',
   func => sub {
     my ($count) = @_;
     my @got;
     my $x = 0;
     my $y = 0;
     foreach my $n (1 .. $count) {
       push @got, ($path->xy_is_visited($x,$y) ? 1 : 0);
       $x++;
       if ($x > $y) {
         $y++;
         $x = -$y;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A118108 - rows as bignum bits

MyOEIS::compare_values
  (anum => 'A118108',
   func => sub {
     my ($count) = @_;
     require Math::BigInt;
     my @got;
     my $y = 0;
     foreach my $n (1 .. $count) {
       my $b = 0;
       foreach my $i (0 .. 2*$y+1) {
         if ($path->xy_to_n ($y-$i, $y)) {
           $b += Math::BigInt->new(2) ** $i;
         }
       }
       push @got, "$b";
       $y++;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
