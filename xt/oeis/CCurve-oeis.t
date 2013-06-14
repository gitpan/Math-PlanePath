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
plan tests => 4;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }
use MyOEIS;

use Math::PlanePath::CCurve;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::CCurve->new;

# return 0,1,2,3 turn
sub path_n_turn {
  my ($path, $n) = @_;
  my $prev_dir = path_n_dir ($path, $n-1);
  my $dir = path_n_dir ($path, $n);
  return ($dir - $prev_dir) % 4;
}
# return 0,1,2,3
sub path_n_dir {
  my ($path, $n) = @_;
  my ($dx,$dy) = $path->n_to_dxdy($n) or die "Oops, no point at ",$n;
  return dxdy_to_dir ($dx, $dy);
}
# return 0,1,2,3, with Y reckoned increasing upwards
sub dxdy_to_dir {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 0; }  # east
  if ($dx < 0) { return 2; }  # west
  if ($dy > 0) { return 1; }  # north
  if ($dy < 0) { return 3; }  # south
}

#------------------------------------------------------------------------------
# A104488 -- num Hamiltonian groups
# No, different at n=67 and more
#
# MyOEIS::compare_values
#   (anum => 'A104488',
#    func => sub {
#      my ($count) = @_;
#      require Math::NumSeq::PlanePathTurn;
#      my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'CCurve',
#                                                  turn_type => 'Right');
#      my @got = (0,0,0,0);;
#      while (@got < $count) {
#        my ($i,$value) = $seq->next;
#        push @got, $value;
#      }
#      return \@got;
#    });

#------------------------------------------------------------------------------
# A146559 - (i+1)^k is X+iY at N=2^k
# A009545 - Im

    # A146559   X at N=2^k, being Re((i+1)^k)
    # A009545   Y at N=2^k, being Im((i+1)^k)

MyOEIS::compare_values
  (anum => 'A146559',
   func => sub {
     my ($count) = @_;
     my @got;
     my $n = 1;
     for (my $n = 1; @got < $count; $n *= 2) {
       my ($x,$y) = $path->n_to_xy($n);
       push @got, $x;
     }
     return \@got;
   });
MyOEIS::compare_values
  (anum => 'A009545',
   func => sub {
     my ($count) = @_;
     my @got;
     my $n = 1;
     for (my $n = 1; @got < $count; $n *= 2) {
       my ($x,$y) = $path->n_to_xy($n);
       push @got, $y;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A003159 - ending even 0 bits, is turn left or right

MyOEIS::compare_values
  (anum => 'A003159',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $path->n_start + 1; @got < $count; $n++) {
       my $turn = path_n_turn($path,$n);
       if ($turn == 1 || $turn == 3) { # left or right
         push @got, $n;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A036554 - ending odd 0 bits, is turn straight or reverse

MyOEIS::compare_values
  (anum => 'A036554',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $path->n_start + 1; @got < $count; $n++) {
       my $turn = path_n_turn($path,$n);
       if ($turn == 0 || $turn == 2) { # straight or reverse
         push @got, $n;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A007814 - count low 0s, is turn right - 1

MyOEIS::compare_values
  (anum => 'A007814',
   fixup => sub {
     my ($bvalues) = @_;
     @$bvalues = map {$_ % 4} @$bvalues;
   },
   func => sub {
     my ($count) = @_;
     my @got;
     my $total_turn = 0;
     for (my $n = $path->n_start + 1; @got < $count; $n++) {
       push @got, (1 - path_n_turn($path,$n)) % 4;  # negate to right
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A000120 - count 1 bits total turn

MyOEIS::compare_values
  (anum => 'A000120',
   fixup => sub {
     my ($bvalues) = @_;
     @$bvalues = map {$_ % 4} @$bvalues;
   },
   func => sub {
     my ($count) = @_;
     my @got = (0);
     my $total_turn = 0;
     for (my $n = $path->n_start + 1; @got < $count; $n++) {
       $total_turn += path_n_turn($path,$n);
       push @got, $total_turn % 4;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
