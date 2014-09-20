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
plan tests => 23;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }
use MyOEIS;

use Math::PlanePath::DragonCurve;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $dragon = Math::PlanePath::DragonCurve->new;


#------------------------------------------------------------------------------
# A003476 Daykin and Tucker alpha[n]
#   = squares on right boundary, OFFSET=1 values 1, 2, 3, 5
#   = single points N=0 to N=2^(k-1) inclusive, with initial 1 for k=-1 one point
#
#                     *           
#                     |           
#   *---*         *---*
#  
#   k=0           k=1
#   singles=2     singles=3
#
#   

MyOEIS::compare_values
  (anum => 'A003476',
   max_value => 10000,
   func => sub {
     my ($count) = @_;
     my @got = (1);
     for (my $k = 0; @got < $count; $k++) {
       push @got, MyOEIS::path_n_to_singles ($dragon, 2**$k);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A121238 - -1 power something is 1=left,-1=right, extra initial 1
# A088585
# A088575

# A088567 a(0)=1, a(1)=1;
#   for m >= 1, a(2m)   = a(2m-1) + a(m) - 1,
#               a(2m+1) = a(2m) + 1
# A090678 = A088567 mod 2.

MyOEIS::compare_values
  (anum => 'A121238',
   func => sub {
     my ($count) = @_;
     my @got = (1);
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Left');
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       push @got, $value ? 1 : -1;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A166242 - turn cumulative doubling/halving, is 2^(total turn)

MyOEIS::compare_values
  (anum => 'A166242',
   func => sub {
     my ($count) = @_;
     my @got = (1);
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Left');
    my $cumulative = 1;
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       if ($value) {
         $cumulative *= 2;
       } else {
         $cumulative /= 2;
       }
       push @got, $cumulative;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A112347 - Kronecker -1/n is 1=left,-1=right, extra initial 0

MyOEIS::compare_values
  (anum => 'A112347',
   func => sub {
     my ($count) = @_;
     my @got = (0);
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Left');
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       push @got, $value ? 1 : -1;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A088748 - dragon cumulative turn +/-1

MyOEIS::compare_values
  (anum => 'A088748',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Left');
     my $cumulative = 1;
     while (@got < $count) {
       push @got, $cumulative;
       my ($i, $value) = $seq->next;
       if ($value) {
         $cumulative += 1; # left
       } else {
         $cumulative -= 1; # right
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A014710 -- relative direction 2=left, 1=right

MyOEIS::compare_values
  (anum => 'A014710',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Left');
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       push @got, $value+1;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A014709 -- relative direction 1=left, 2=right

MyOEIS::compare_values
  (anum => 'A014709',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Right');
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       push @got, $value+1;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A014577 -- relative direction 1=left, 0=right, starting from 1
#
# cf A059125 is almost but not quite the same, the 8,24,or some such entries
# differ

MyOEIS::compare_values
  (anum => 'A014577',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Left');
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A014707 -- relative direction 0=left, 1=right, starting from 1

MyOEIS::compare_values
  (anum => 'A014707',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Right');
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A088431 - dragon turns run lengths

MyOEIS::compare_values
  (anum => 'A088431',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Right');
     my ($i, $prev) = $seq->next;
     my $run = 1; # count for initial $prev_turn
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       if ($value == $prev) {
         $run++;
       } else {
         push @got, $run;
         $run = 1; # count for new $turn value
       }
       $prev = $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A007400 - 2 * run lengths, extra initial 0,1

MyOEIS::compare_values
  (anum => 'A007400',
   func => sub {
     my ($count) = @_;
     my @got = (0,1);
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Right');
     my ($i, $prev) = $seq->next;
     my $run = 1; # count for initial $prev_turn
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       if ($value == $prev) {
         $run++;
       } else {
         push @got, 2 * $run;
         $run = 1; # count for new $turn value
       }
       $prev = $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A099545 -- relative direction 1=left, 3=right

MyOEIS::compare_values
  (anum => 'A099545',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Right');
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       push @got, $value ? 3 : 1;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A003460 -- turn 1=left,0=right packed as octal high to low, in 2^n levels

MyOEIS::compare_values
  (anum => 'A003460',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::BigInt;
     my $bits = Math::BigInt->new(0);
     my $target_n_level = 2;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Left');
     for (my $n = 1; @got < $count; $n++) {
       if ($n >= $target_n_level) {  # not including n=2^level point itself
         my $octal = $bits->as_oct;  # new enough Math::BigInt
         $octal =~ s/^0+//;  # strip leading "0"
         push @got, Math::BigInt->new("$octal");
         $target_n_level *= 2;
       }
       my ($i, $value) = $seq->next;
       $bits = 2*$bits + $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A082410 -- complement reversal, is turn 1=left, 0=right

MyOEIS::compare_values
  (anum => 'A082410',
   func => sub {
     my ($count) = @_;
     my @got = (0);
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Left');
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       push @got, $value; # 1=left,0=right
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A164910 - dragon cumulative turn +/-1, partial sums of that cumulative

MyOEIS::compare_values
  (anum => 'A164910',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Left');
     my $cumulative = 1;
     my $partial_sum = $cumulative;
     while (@got < $count) {
       push @got, $partial_sum;
       my ($i, $value) = $seq->next;
       if ($value) {
         $cumulative += 1;
       } else {
         $cumulative -= 1;
       }
       $partial_sum += $cumulative;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A005811 -- total rotation, count runs of bits in binary

MyOEIS::compare_values
  (anum => 'A005811',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Left');
     my $cumulative = 0;
     while (@got < $count) {
       push @got, $cumulative;
       my ($i, $value) = $seq->next;
       if ($value) {
         $cumulative += 1;
       } else {
         $cumulative -= 1;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A091072 -- N positions of left turns

MyOEIS::compare_values
  (anum => 'A091072',
   func => sub {
     my ($count) = @_;
     my @got;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new(planepath_object=>$dragon,
                                                turn_type => 'Left');
     while (@got < $count) {
       my ($i, $value) = $seq->next;
       if ($value) {
         push @got, $i;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A126937 -- points numbered as SquareSpiral, starting N=0

MyOEIS::compare_values
  (anum => 'A126937',
   func => sub {
     my ($count) = @_;
     require Math::PlanePath::SquareSpiral;
     my $square  = Math::PlanePath::SquareSpiral->new (n_start => 0);
     my @got;
     for (my $n = $dragon->n_start; @got < $count; $n++) {
       my ($x, $y) = $dragon->n_to_xy ($n);
       my $square_n = $square->xy_to_n ($x, -$y);
       push @got, $square_n;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# Ba2 boundary of arms=2 around whole of level k

#                                 *
#                                 |
# 3        5---*   4      *   *---*---*
# |            |   |      |   |   |   |
# o---2        o---*      *---*   o---*
#  len=4    k=2 len=8       k=3 len=14
#
MyOEIS::compare_values
  (anum => 'A052537',
   max_value => 100,
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::DragonCurve->new (arms => 2);
     my $k = 0;
     my $prev = MyOEIS::path_boundary_length ($path, 2*2**$k + 1);
     for ($k++; @got < 5; $k++) {
       my $len = MyOEIS::path_boundary_length ($path, 2*2**$k + 1);
       my $diff = $len - $prev;
       push @got, $prev;
       $prev = $len;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A077949 join area increments, ie. first differences

MyOEIS::compare_values
  (anum => 'A077949',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     my $prev = 0;
     for (my $k = 3; @got < $count; $k++) {
       my $join_area = $dragon->_UNDOCUMENTED_level_to_enclosed_area_join($k);
       push @got, $join_area - $prev;
       $prev = $join_area;
     }
     return \@got;
   });

# A003479 join area
MyOEIS::compare_values
  (anum => 'A003479',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 3; @got < $count; $k++) {
       push @got, $dragon->_UNDOCUMENTED_level_to_enclosed_area_join($k);
     }
     return \@got;
   });


#------------------------------------------------------------------------------
# A003478 enclosed area increment, ie. first differences

MyOEIS::compare_values
  (anum => 'A003478',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     my $prev_area = 0;
     for (my $k = 4; @got < $count; $k++) {
       my $area = MyOEIS::path_enclosed_area ($dragon, 2**$k);
       push @got, $area - $prev_area;
       $prev_area = $area;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A003230 enclosed area to N <= 2^k

MyOEIS::compare_values
  (anum => 'A003230',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 4; @got < $count; $k++) {
       push @got, MyOEIS::path_enclosed_area ($dragon, 2**$k);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A164395 single points N=0 to N=2^k-1 inclusive, for k=4 up
#   is count binary with no substrings equal to 0001 or 0101

MyOEIS::compare_values
  (anum => 'A164395',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 4; @got < $count; $k++) {
       push @got, MyOEIS::path_n_to_singles ($dragon, 2**$k - 1);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A227036 boundary length N <= 2^k

MyOEIS::compare_values
  (anum => 'A227036',
   max_value => 10_000,
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $k = 0; @got < $count; $k++) {
       push @got, MyOEIS::path_boundary_length ($dragon, 2**$k);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A038189 -- bit above lowest 1, is 0=left,1=right

MyOEIS::compare_values
  (anum => 'A038189',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'DragonCurve',
                                                 turn_type => 'Right');
     my @got = (0);  # extra initial 0
     while (@got < $count) {
       my ($i,$value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });

# A089013=A038189 but initial extra 1
MyOEIS::compare_values
  (anum => 'A089013',
   func => sub {
     my ($count) = @_;
     require Math::NumSeq::PlanePathTurn;
     my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'DragonCurve',
                                                 turn_type => 'Right');
     my @got = (1);  # extra initial 1
     while (@got < $count) {
       my ($i,$value) = $seq->next;
       push @got, $value;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
