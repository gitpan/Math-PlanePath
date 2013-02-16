#!/usr/bin/perl -w

# Copyright 2011, 2012, 2013 Kevin Ryde

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

use Math::PlanePath::FactorRationals;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::FactorRationals->new;

#------------------------------------------------------------------------------
# A011262 -- N at transpose Y/X
# cf A011264

MyOEIS::compare_values
  (anum => 'A011262',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x, $y) = $path->n_to_xy ($n);
       ($x, $y) = ($y, $x);
       my $n = $path->xy_to_n ($x, $y);
       push @got, $n;
     }
     return\@got;
   });

sub calc_A011262 {
  my ($n) = @_;
  my $ret = 1;
  for (my $p = 2; $p <= $n; $p++) {
    if (($n % $p) == 0) {
      my $count = 0;
      while (($n % $p) == 0) {
        $n /= $p;
        $count++;
      }
      $count = ($count & 1 ? $count+1 : $count-1);
      # $count++;
      # $count ^= 1;
      # $count--;
      $ret *= $p ** $count;
    }
  }
  return $ret;
}
MyOEIS::compare_values
  (anum => 'A011262',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       push @got, calc_A011262($n);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A102631 - n^2/squarefreekernel(n), is column at X=1

MyOEIS::compare_values
  (anum => 'A102631',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $y = 1; @got < $count; $y++) {
       push @got, $path->xy_to_n (1, $y);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A060837 - permutation DiagonalRationals N -> FactorRationals N

MyOEIS::compare_values
  (anum => 'A060837',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::PlanePath::DiagonalRationals;
     my $columns = Math::PlanePath::DiagonalRationals->new;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x,$y) = $columns->n_to_xy ($n);
       push @got, $path->xy_to_n($x,$y);
     }
     return \@got;
   });


#------------------------------------------------------------------------------
# A071970 - permutation Stern a[i]/[ai+1] which is Calkin-Wilf N -> power N

MyOEIS::compare_values
  (anum => 'A071970',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::PlanePath::RationalsTree;
     my $sb = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($x,$y) = $sb->n_to_xy ($n);
       push @got, $path->xy_to_n($x,$y);
     }
     return \@got;
   });


#------------------------------------------------------------------------------
exit 0;
