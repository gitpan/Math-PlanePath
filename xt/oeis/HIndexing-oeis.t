#!/usr/bin/perl -w

# Copyright 2013 Kevin Ryde

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
use Math::PlanePath::HIndexing;
use Test;
plan tests => 11;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }
use MyOEIS;


# uncomment this to run the ### lines
#use Smart::Comments '###';


#------------------------------------------------------------------------------
# A097110 -- Y at N=2^k

require Math::NumSeq::PlanePathN;
my $bigclass = Math::NumSeq::PlanePathN::_bigint();

MyOEIS::compare_values
  (anum => 'A097110',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::HIndexing->new;
     my @got;
     for (my $n = $bigclass->new(1); @got < $count; $n *= 2) {
       my ($x,$y) = $path->n_to_xy($n);
       push @got, $y;
     }
     return \@got;
   });

#------------------------------------------------------------------------------

exit 0;
