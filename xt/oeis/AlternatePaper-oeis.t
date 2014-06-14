#!/usr/bin/perl -w

# Copyright 2012, 2013, 2014 Kevin Ryde

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
use Math::PlanePath::AlternatePaper;
use Test;
plan tests => 14;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }
use MyOEIS;

# uncomment this to run the ### lines
#use Smart::Comments '###';

my $paper = Math::PlanePath::AlternatePaper->new;


#------------------------------------------------------------------------------
# A052955 single-visited points  to N=2^k
MyOEIS::compare_values
  (anum => 'A052955',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got = (1);  # extra initial 1
     for (my $k = 0; @got < $count; $k++) {
       push @got, MyOEIS::path_n_to_singles ($paper, 2**$k);
     }
     return \@got;
   });

# A052940 single-visited points  to N=4^k
MyOEIS::compare_values
  (anum => 'A052940',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got = (1);    # initial 1 instead of 2
     for (my $k = 1; @got < $count; $k++) {
       push @got, MyOEIS::path_n_to_singles ($paper, 4**$k);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A122746  area increment  to N=2^k
MyOEIS::compare_values
  (anum => 'A122746',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 2; @got < $count; $k++) {
       push @got, (MyOEIS::path_enclosed_area($paper, 2**($k+1))
                   - MyOEIS::path_enclosed_area($paper, 2**$k));
     }
     return \@got;
   });


#------------------------------------------------------------------------------
# A052955  single-visit points to N=2^k
MyOEIS::compare_values
  (anum => 'A052955',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got = (1);
     for (my $k = 0; @got < $count; $k++) {
       push @got, MyOEIS::path_n_to_singles($paper, 2**$k);
     }
     return \@got;
   });

#------------------------------------------------------------------------------

# A028399  boundary to N=2*4^k
MyOEIS::compare_values
  (anum => 'A028399',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got = (0);
     for (my $k = 0; @got < $count; $k++) {
       push @got, MyOEIS::path_boundary_length($paper, 2*4**$k);
     }
     return \@got;
   });

# A131128  boundary to N=4^k
MyOEIS::compare_values
  (anum => 'A131128',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got = (1);
     for (my $k = 0; @got < $count; $k++) {
       push @got, MyOEIS::path_boundary_length($paper, 4**$k);
     }
     return \@got;
   });

# A027383  boundary/2 to N=2^k
# is also boundary length verticals or horizontals since boundary is half
# verticals and half horizontals
MyOEIS::compare_values
  (anum => 'A027383',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 0; @got < $count; $k++) {
       push @got, MyOEIS::path_boundary_length($paper, 2**$k) / 2;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A060867  area  to N=2*4^k
MyOEIS::compare_values
  (anum => 'A060867',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 1; @got < $count; $k++) {
       push @got, MyOEIS::path_enclosed_area($paper, 2*4**$k);
     }
     return \@got;
   });

# A134057  area  to N=4^k
MyOEIS::compare_values
  (anum => 'A134057',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 0; @got < $count; $k++) {
       push @got, MyOEIS::path_enclosed_area($paper, 4**$k);
     }
     return \@got;
   });

# A027556  area*2  to N=2^k
MyOEIS::compare_values
  (anum => 'A027556',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 0; @got < $count; $k++) {
       push @got, MyOEIS::path_enclosed_area($paper, 2**$k) * 2;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A106665 -- turn 1=left, 0=right
#   OFFSET=0 cf first turn at N=1 here

MyOEIS::compare_values
  (anum => 'A106665',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'AlternatePaper',
                                                 turn_type => 'Left');
     my @got;
     while (@got < $count) {
       my ($i,$value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });


#------------------------------------------------------------------------------
# A090678 "non-squashing partitions" A088567 mod 2
# and A121241 which is 1,-1
# almost but not quite arms=2 turn_type=Left
# A121241 1,-1
# A110036 2,0,-2
# A110037 1,0,-1


# MyOEIS::compare_values
#   (anum => 'A090678',
#    func => sub {
#      my ($count) = @_;
#      require Math::NumSeq::PlanePathTurn;
#      my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'AlternatePaper,arms=2',
#                                                  turn_type => 'Left');
#      my @got = (1,1,1,0,0,1,0,1,0,1,1,0,1,0,0,1,0,1);
#      while (@got < $count) {
#        my ($i,$value) = $seq->next;
#        push @got, $value;
#      }
#      return \@got;
#    });

#------------------------------------------------------------------------------
# A209615 Completely multiplicative with a(p^e) = 1 if p == 1 (mod 4),
#                                        a(p^e) = (-1)^e otherwise.

MyOEIS::compare_values
  (anum => 'A209615',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath_object => $paper,
                                                 turn_type => 'LSR');
     my @got;
     while (@got < $count) {
       my ($i,$value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A020985 - Golay/Rudin/Shapiro is dX and dY alternately
# also is dSum in Math::NumSeq::PlanePathDelta

MyOEIS::compare_values
  (anum => q{A020985},
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $paper->n_start; @got < $count; ) {
       {
         my ($dx, $dy) = $paper->n_to_dxdy ($n++);
         push @got, $dx;
       }
       last unless @got < $count;
       {
         my ($dx, $dy) = $paper->n_to_dxdy ($n++);
         push @got, $dy;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A020991 - position of last occurance of n, last time of X+Y=n

MyOEIS::compare_values
  (anum => 'A020991',
   func => sub {
     my ($count) = @_;
     my @got;
     my @occur;
     my $target = 1;
     for (my $n = $paper->n_start + 1; @got < $count; $n++) {
       my ($x, $y) = $paper->n_to_xy ($n);
       my $d = $x + $y;
       $occur[$d]++;
       if ($occur[$d] == $d) {
         push @got, $n-1;
         $target++;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A093573+1 - triangle of positions where cumulative=k
#   cumulative A020986 starts n=0 for GRS(0)=0  (A020985)
# 0,
# 1,  3,
# 2,  4,  6,
# 5,  7, 13, 15,
# 8, 12, 14, 16, 26,
# 9, 11, 17, 19, 25, 27
#
# cf diagonals
# 0
# 1
# 2, 4
# 3,7, 5
# 8, 6,14, 16
# 9,13, 15,27, 17

MyOEIS::compare_values
  (anum => 'A093573',
   func => sub {
     my ($count) = @_;
     my @got;
   OUTER: for (my $sum = 1; ; $sum++) {
       my @n_list;
       foreach my $y (0 .. $sum) {
         my $x = $sum - $y;
         push @n_list, $paper->xy_to_n_list($x,$y);;
       }
       @n_list = sort {$a<=>$b} @n_list;
       foreach my $n (@n_list) {
         last OUTER if @got >= $count;
         push @got, $n-1;
       }
     }
     return \@got;
   });


#------------------------------------------------------------------------------
# A020986 - GRS cumulative

# X+Y, starting from N=1 (doesn't have X+Y=0 for N=0)
MyOEIS::compare_values
  (anum => 'A020986',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $paper->n_start + 1; @got < $count; $n++) {
       my ($x, $y) = $paper->n_to_xy ($n);
       push @got, $x+$y;
     }
     return \@got;
   });

# is X coord undoubled, starting from N=2 (doesn't have X=0 for N=0)
MyOEIS::compare_values
  (anum => q{A020986},
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = 2; @got < $count; $n += 2) {
       my ($x, $y) = $paper->n_to_xy ($n);
       push @got, $x;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A022155 - positions of -1, is S,W steps

MyOEIS::compare_values
  (anum => 'A022155',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $paper->n_start; @got < $count; $n++) {
       my ($dx,$dy) = $paper->n_to_dxdy($n);
       if ($dx < 0 || $dy < 0) {
         push @got, $n;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A203463 - positions of 1, is N,E steps

MyOEIS::compare_values
  (anum => 'A203463',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $paper->n_start; @got < $count; $n++) {
       my ($dx,$dy) = $paper->n_to_dxdy($n);
       if ($dx > 0 || $dy > 0) {
         push @got, $n;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A020990 - Golay/Rudin/Shapiro * (-1)^k cumulative, is Y coord undoubled,
# except N=0

MyOEIS::compare_values
  (anum => 'A020990',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = 2; @got < $count; $n += 2) {
       my ($x, $y) = $paper->n_to_xy ($n);
       push @got, $y;
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => q{A020990},
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $paper->n_start + 1; @got < $count; $n++) {
       my ($x, $y) = $paper->n_to_xy ($n);
       push @got, $x-$y;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A212591 - position of first occurance of n, first time getting to X+Y=n
# seq    0, 1, 2, 5, 8,  9, 10, 21, 32, 33, 34, 37, 40, 41, 42, 85
# N   0  1  2  3  6, 9, 10, 11, 22, ...

MyOEIS::compare_values
  (anum => 'A212591',
   max_count => 1000,    # because simple linear search
   func => sub {
     my ($count) = @_;
     my @got;
     my $target = 1;
     for (my $n = $paper->n_start + 1; @got < $count; $n++) {
       my ($x, $y) = $paper->n_to_xy ($n);
       my $d = $x + $y;
       if ($d == $target) {
         push @got, $n-1;
         $target++;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------

exit 0;
