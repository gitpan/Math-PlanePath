#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

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
use Math::PlanePath::CfracDigits;

use Math::PlanePath::Base::Digits
  'digit_join_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments '###';


#------------------------------------------------------------------------------
# A032924 - N in X=1 column, ternary no digit 0

MyOEIS::compare_values
  (anum => 'A032924',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::CfracDigits->new;
     my @got;
     for (my $y = 3; @got < $count; $y++) {
       push @got, $path->xy_to_n(1,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A023705 - N in X=1 column, base4 no digit 0

MyOEIS::compare_values
  (anum => 'A023705',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::CfracDigits->new (radix => 3);
     my @got;
     for (my $y = 3; @got < $count; $y++) {
       push @got, $path->xy_to_n(1,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A023721 - N in X=1 column, base5 no digit 0

MyOEIS::compare_values
  (anum => 'A023721',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::CfracDigits->new (radix => 4);
     my @got;
     for (my $y = 3; @got < $count; $y++) {
       push @got, $path->xy_to_n(1,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A052382 - N in X=1 column, base5 no digit 0

MyOEIS::compare_values
  (anum => 'A052382',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::CfracDigits->new (radix => 9);
     my @got;
     for (my $y = 3; @got < $count; $y++) {
       push @got, $path->xy_to_n(1,$y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
