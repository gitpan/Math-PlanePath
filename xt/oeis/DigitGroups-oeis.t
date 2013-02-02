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
plan tests => 3;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::DigitGroups;

# uncomment this to run the ### lines
#use Smart::Comments '###';


#------------------------------------------------------------------------------
# A084472 - X axis in binary, excluding 0

MyOEIS::compare_values
  (anum => 'A084472',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::DigitGroups->new;
     for (my $x = 1; @got < $count; $x++) {
       my $n = $path->xy_to_n ($x,0);
       push @got, to_binary($n);
     }
     return \@got;
   });

sub to_binary {
  my ($n) = @_;
  return ($n < 0 ? '-' : '') . sprintf('%b', abs($n));
}

#------------------------------------------------------------------------------
# A060142 - X axis sorted

MyOEIS::compare_values
  (anum => 'A060142',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::DigitGroups->new;
     for (my $x = 0; @got < 16 * $count; $x++) {
       push @got, $path->xy_to_n ($x,0);
     }
     @got = sort {$a<=>$b} @got;
     $#got = $count-1;
     return \@got;
   });


#------------------------------------------------------------------------------

exit 0;
