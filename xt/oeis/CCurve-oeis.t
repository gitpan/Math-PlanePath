#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012, 2013, 2014 Kevin Ryde

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
plan tests => 7;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }
use MyOEIS;

use Math::PlanePath::CCurve;

# uncomment this to run the ### lines
# use Smart::Comments '###';


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
  return dxdy_to_dir4 ($dx, $dy);
}
# return 0,1,2,3, with Y reckoned increasing upwards
sub dxdy_to_dir4 {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 0; }  # east
  if ($dx < 0) { return 2; }  # west
  if ($dy > 0) { return 1; }  # north
  if ($dy < 0) { return 3; }  # south
}

sub right_boundary {
  my ($n_end) = @_;
  return MyOEIS::path_boundary_length ($path, $n_end, side => 'right');
}
use Memoize;
Memoize::memoize('right_boundary');

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
# A003159 - positions ending even 0 bits is where turn either left or right

MyOEIS::compare_values
  (anum => 'A003159',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                                 turn_type => 'LSR');
     my @got;
     while (@got < $count) {
       my ($i, $lsr) = $seq->next;
       if ($lsr) { # left or right
         push @got, $i;
       }
     }
     return \@got;
   });

# A036554 - positions ending odd 0 bits is where turn straight or reverse
MyOEIS::compare_values
  (anum => 'A036554',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                                 turn_type => 'LSR');
     my @got;
     while (@got < $count) {
       my ($i, $lsr) = $seq->next;
       if ($lsr == 0) { # straight
         push @got, $i;
       }
     }
     return \@got;
   });


#------------------------------------------------------------------------------
# A027383 right boundary differences
MyOEIS::compare_values
  (anum => 'A027383',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got = (1);
     for (my $k = 1; @got < $count; $k++) {
       my $b1 = right_boundary(2**$k);
       my $b2 = right_boundary(2**($k+1));
       push @got, $b2 - $b1;
     }
     return \@got;
   });

# A131064 right boundary odd powers, extra initial 1
MyOEIS::compare_values
  (anum => 'A131064',
   max_value => 50_000,
   func => sub {
     my ($count) = @_;
     my @got = (1);
     for (my $k = 1; @got < $count; $k++) {
       my $boundary = right_boundary(2**(2*$k-1));  # 1,3,5,..
       push @got, $boundary;
       ### at: "k=$k $boundary"
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A035263 - morphism turn 0=straight, 1=not-straight

MyOEIS::compare_values
  (anum => 'A035263',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'CCurve',
                                                 turn_type => 'LSR');
     my @got;
     for (my $n = 1; @got < $count; $n++) {
       my ($i,$value) = $seq->next;
       push @got, $value == 0 ? 0 : 1;
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => 'A035263',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = 1; @got < $count; $n++) {
       push @got, (count_low_0_bits($n) + 1) % 2;
     }
     return \@got;
   });


#------------------------------------------------------------------------------
# A096268 - morphism turn 1=straight,0=not-straight
#   but OFFSET=0 is turn at N=1, so "next turn"

MyOEIS::compare_values
  (anum => 'A096268',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'CCurve',
                                                 turn_type => 'LSR');
     my @got;
     while (@got < $count) {
       my ($i,$value) = $seq->next;
       push @got, $value == 0 ? 1 : 0;
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => 'A096268',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       push @got, count_low_1_bits($n) % 2;
     }
     return \@got;
   });
MyOEIS::compare_values
  (anum => 'A096268',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = 0; @got < $count; $n++) {
       push @got, count_low_0_bits($n+1) % 2;
     }
     return \@got;
   });

sub count_low_1_bits {
  my ($n) = @_;
  my $count = 0;
  while ($n % 2) {
    $count++;
    $n = int($n/2);
  }
  return $count;
}

sub count_low_0_bits {
  my ($n) = @_;
  if ($n == 0) { die; }
  my $count = 0;
  until ($n % 2) {
    $count++;
    $n /= 2;
  }
  return $count;
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

require Math::NumSeq::PlanePathN;
my $bigclass = Math::NumSeq::PlanePathN::_bigint();

MyOEIS::compare_values
  (anum => 'A146559',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $bigclass->new(1); @got < $count; $n *= 2) {
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
     for (my $n = $bigclass->new(1); @got < $count; $n *= 2) {
       my ($x,$y) = $path->n_to_xy($n);
       push @got, $y;
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
