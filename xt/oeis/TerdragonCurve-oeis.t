#!/usr/bin/perl -w

# Copyright 2011, 2012, 2013, 2014 Kevin Ryde

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
plan tests => 12;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }
use MyOEIS;

use Math::PlanePath::TerdragonCurve;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::TerdragonCurve->new;

sub ternary_digit_above_low_zeros {
  my ($n) = @_;
  if ($n == 0) {
    return 0;
  }
  while (($n % 3) == 0) {
    $n = int($n/3);
  }
  return ($n % 3);
}

#------------------------------------------------------------------------------
# A164346 boundary even powers, is 3*4^n
# also one side, odd powers
MyOEIS::compare_values
  (anum => 'A164346',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got = (3);
     for (my $k = 1; @got < $count; $k++) {
       push @got, MyOEIS::path_boundary_length ($path, 3**(2*$k),
                                                lattice_type => 'triangular');
     }
     return \@got;
   });
MyOEIS::compare_values
  (anum => 'A164346',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 0; @got < $count; $k++) {
       push @got, MyOEIS::path_boundary_length ($path, 3**(2*$k+1),
                                                lattice_type => 'triangular',
                                                side => 'left');
     }
     return \@got;
   });

# A002023 boundary odd powers 6*4^n
# also even powers one side
MyOEIS::compare_values
  (anum => 'A002023',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 0; @got < $count; $k++) {
       push @got, MyOEIS::path_boundary_length ($path, 3**(2*$k+1),
                                                lattice_type => 'triangular');
     }
     return \@got;
   });
MyOEIS::compare_values
  (anum => 'A002023',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 1; @got < $count; $k++) {
       push @got, MyOEIS::path_boundary_length ($path, 3**(2*$k),
                                                lattice_type => 'triangular',
                                                side => 'right');
     }
     return \@got;
   });

# A007283 boundary length is 3*2^k for points N <= 3^k
MyOEIS::compare_values
  (anum => 'A007283',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got = (3); # path initial boundary=2 vs bvalues=3
     for (my $k = 1; @got < $count; $k++) {
       push @got, MyOEIS::path_boundary_length ($path, 3**$k,
                                                lattice_type => 'triangular');
     }
     return \@got;
   });


#------------------------------------------------------------------------------
# A118004 1/2 enclosed area odd levels points N <= 3^(2k+1), is 9^k-4^k
# area[k] = 2*(3^(k-1)-2^(k-1))
# area[2k+1]/2 = 2*(3^(2k+1-1)-2^(2k+1-1))/2
#              = 9^k - 4^k

MyOEIS::compare_values
  (anum => 'A118004',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 0; @got < $count; $k++) {
       my $area = MyOEIS::path_enclosed_area ($path, 3**(2*$k+1),
                                              lattice_type => 'triangular');
       push @got, $area/2;
     }
     return \@got;
   });

# A056182 enclosed area is 2*(3^(k-1)-2^(k-1)) for points N <= 3^k
MyOEIS::compare_values
  (anum => 'A056182',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 1; @got < $count; $k++) {
       push @got, MyOEIS::path_enclosed_area ($path, 3**$k,
                                              lattice_type => 'triangular');
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A136442 1,1,0,1,1,0,1,0,0,1,1,0,1,1,0,1,0,0,1,1,0,1,0,0,
# OFFSET =0,1,2,3,...
# left    1,1,0,1,1,0,0,1,0,1,1,0,1,1,0,0,1,0,0,1,0,1,1,0,0,1,0,1,1,0,1,1,0,0,1,0,1,1,0,1,1,0,0,1,0,0,1,0,1,1,0,0,1,0,0,1,0,1,1,0,0,1,0,1,1,0,1,1,0,0,1,0,0,1,0,1,1,0,0,1,0,1,1,0,1,1,0,0,1,0,1,1,0,1,1,0,0,1,0,0,1,0,1,1,0
#         N=1,2,3,...

# Not quite
#
# MyOEIS::compare_values
#   (anum => 'A136442',
#    func => sub {
#      my ($count) = @_;
#      require Math::NumSeq::PlanePathTurn;
#      my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
#                                                  turn_type => 'Left');
#      my @got = (1);
#      while (@got < $count) {
#        my ($i, $value) = $seq->next;
#        push @got, $value;
#      }
#      return \@got;
#    });

#------------------------------------------------------------------------------
# A060032 - turn 1=left, 2=right as bignums to 3^level

MyOEIS::compare_values
  (anum => 'A060032',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                                 turn_type => 'LSR');
     my @got;
     for (my $level = 0; @got < $count; $level++) {
       require Math::BigInt;
       my $big = Math::BigInt->new(0);
       foreach my $n (1 .. 3**$level) {
         my $value = $seq->ith($n);
         if ($value == -1) { $value = 2; }
         $big = 10*$big + $value;
       }
       push @got, $big;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A189673 - morphism turn 1=left, 0=right, extra initial 0

MyOEIS::compare_values
  (anum => 'A189673',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                                 turn_type => 'Left');
     my @got = (0);
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A189640 - morphism turn 0=left, 1=right, extra initial 0

MyOEIS::compare_values
  (anum => 'A189640',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                                 turn_type => 'Right');
     my @got = (0);
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A005823 - N positions with total turn == 0, no ternary 1s

MyOEIS::compare_values
  (anum => 'A005823',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                                 turn_type => 'LSR');
     my $total_turn = 0;
     my @got = (0);
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       $total_turn += $value;
       if ($total_turn == 0) {
         push @got, $i;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A062756 - ternary count 1s, is cumulative turn

MyOEIS::compare_values
  (anum => 'A062756',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                                 turn_type => 'LSR');
     my @got;
     my $cumulative = 0;
     for (;;) {
       push @got, $cumulative;
       last if @got >= $count;
       my ($i, $value) = $seq->next;
       $cumulative += $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A080846 - turn 0=left, 1=right

MyOEIS::compare_values
  (anum => 'A080846',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                                 turn_type => 'Right');
     my @got;
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A038502 - taken mod 3 is 1=left, 2=right

MyOEIS::compare_values
  (anum => 'A038502',
   fixup => sub {
     my ($bvalues) = @_;
     @$bvalues = map { $_ % 3 } @$bvalues;
   },
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                                 turn_type => 'Right');
     my @got;
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       push @got, $value+1;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A026225 - N positions of left turns

MyOEIS::compare_values
  (anum => 'A026225',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                                 turn_type => 'Left');
     my @got;
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       if ($value == 1) {
         push @got, $i;
       }
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => 'A026225',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = 1; @got < $count; $n++) {
       if (ternary_digit_above_low_zeros($n) == 1) {
         push @got, $n;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A026179 - positions of right turns

MyOEIS::compare_values
  (anum => 'A026179',
   func => sub {
     my ($count) = @_;
     my @got = (1);   # extra initial 1 ...
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $path,
                                                 turn_type => 'Right');
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       if ($value == 1) {
         push @got, $i;
       }
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => 'A026179',
   func => sub {
     my ($count) = @_;
     my @got = (1);
     for (my $n = 1; @got < $count; $n++) {
       if (ternary_digit_above_low_zeros($n) == 2) {
         push @got, $n;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
