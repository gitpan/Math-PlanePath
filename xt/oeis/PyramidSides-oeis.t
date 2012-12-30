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
plan tests => 6;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::PyramidSides;

# uncomment this to run the ### lines
#use Smart::Comments '###';

#------------------------------------------------------------------------------
# A004201 -- N for which X>=0

MyOEIS::compare_values
  (anum => 'A004201',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::PyramidSides->new;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       if ($x >= 0) {
         push @got, $n;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
