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
plan tests => 15;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use List::Util 'min', 'max';
use Math::PlanePath::TriangularHypot;

# uncomment this to run the ### lines
# use Smart::Comments '###';


#------------------------------------------------------------------------------
# A217219 - theta of honeycomb at centre hole
#           count of how many at norm=4*k, possibly zero

MyOEIS::compare_values
  (anum => 'A217219',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new(points=>'hex_centred');
     my @got;
     my $n = $path->n_start;
     my $num = 0;
     my $want_norm = 0;
     while (@got < $count) {
       my ($x,$y) = $path->n_to_xy($n);
       my $norm = $x*$x + 3*$y*$y;
       if ($norm > $want_norm) {
         ### push: $num
         push @got, $num;
         $want_norm += 4;
         $num = 0;
       } else {
         ### point: "$n at $x,$y norm=$norm  total num=$num"
         $n++;
         $num++;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A113062 - theta of honeycomb at node,
#           count of how many at norm=4*k, possibly zero

MyOEIS::compare_values
  (anum => 'A113062',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new (points => 'hex');
     my @got;
     my $n = $path->n_start;
     my $num = 0;
     my $want_norm = 0;
     while (@got < $count) {
       my ($x,$y) = $path->n_to_xy($n);
       my $norm = $x*$x + 3*$y*$y;
       if ($norm > $want_norm) {
         ### push: $num
         push @got, $num;
         $want_norm += 4;
         $num = 0;
       } else {
         ### point: "$n at $x,$y norm=$norm  total num=$num"
         $n++;
         $num++;
       }
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => 'A113063',      # divided by 3
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new (points => 'hex');
     my @got;
     my $n = $path->n_start + 1;  # excluding origin X=0,Y=0
     my $num = 0;
     my $want_norm = 4;
     while (@got < $count) {
       my ($x,$y) = $path->n_to_xy($n);
       my $norm = $x*$x + 3*$y*$y;
       if ($norm > $want_norm) {
         ### push: $num
           push @got, $num/3;
         $want_norm += 4;
         $num = 0;
       } else {
         ### point: "$n at $x,$y norm=$norm  total num=$num"
         $n++;
         $num++;
       }
     }
     return \@got;
   });


#------------------------------------------------------------------------------
# A005929 - theta series midpoint of edge
#           2,0,0,0,0,0,4,0,0,0,0,0,4,0,0,0,0,0,4,0,0,0,0,0,2,0,0,0,0,0,4,0,

#             .     .     .     .     .     .                  5
#
#                .     4     .     4     .                     4
#
#             .     .     .     .     .     .                  3
#
#          .     3     .     2     .     3     .               2
#
#       .     .     .     .     .     .     .     .            1
#
#    .     .     .     1     o     1     .     .     .    <- Y=0
#
# .     .     .     .     .     .     .     .     .    .      -1
#
#    .     .     3     .     2     .     3     .     .        -2
#
# .     .     .     .     .     .     .     .     .    .      -3
#
#    .     .     .     4     .     4     .     .     .        -4
#
#       .     .     .     .     .     .     .     .           -5
#
#    .     .     .     .     -     .     .     .     .        -6


#------------------------------------------------------------------------------
# A038588 - clusters A2 centred deep hole
#           3, 6, 12, 18, 21, 27 ...
# unique values from A038587 = 3,6,12,12,18,21,27,27,30,
# which is partial sums A005882 theta relative hole,
#                       = 3,3,6,0,6,3,6,0,3,6,6,0,6,0,6,0,9,6,0,0,6
# theta = num points of norm==n

#               3---------3                 3,-1 = 3*3+3 = 12
#              / \       / \               -3,-1          = 12
#             /   \     /   \               0, 2 = 0+3*2*2 = 12
#            /     \   /     \
#           /       \ /       \             4,2 = 6*6+3*2*2 = 48
#          2---------1---------2           -4,2              = 48
#         / \       / \       / \           0,-4 = 0+3*4*4 = 48
#        /   \     /   \     /   \
#       /     \   /  *  \   /     \
#      /       \ /       \ /       \
#     3---------1---------1---------3
#      \       / \       / \       /
#       \     /   \     /   \     /
#        \   /     \   /     \   /
#         \ /       \ /       \ /
#          3---------2---------3

#             .     3     .     .     3     .                  5
#
#                .     .     .     .     .                     4
#
#             .     .     .     .     .     .                  3
#
#          2     .     .     1     .     .     2               2
#
#       .     .     .     .     .     .     .     .            1
#
#    .     .     .     .     o     .     .     .     .    <- Y=0
#
# 3     .     .     1     .     .     1     .     .    3      -1
#
#    .     .     .     .     .     .     .     .     .        -2
#
# .     .     .     .     .     .     .     .     .    .      -3
#
#    .     3     .     .     2     .     .     3     .        -4
#
#       .     .     .     .     .     .     .     .           -5
#
#    .     .     .     .     -     .     .     .     .        -6

#                           X=0 1  2  3  4  5  6  7
#
# X+Y=6k+2
# Y=3z+2
#
# block X mod 6, Y mod 6 only X=0,Y=2 and X=3,Y=5
# X+6Y mod 36 = 2*6=12 or 3+6*5=33 cf -3+6*-1=-9=
# shift down X=0,Y=0 X=3,Y=3 only
# X+6Y mod 36 = 0 or 3+6*3=21
#
# X=6k
# also rotate +120 -(X+3Y)/2 = 6k is X+3Y = 12k
# also rotate -120 (3Y-X)/2 = 6k  is X-3Y = 12k

sub xy_is_tcentred {
  my ($x, $y) = @_;
  return ($y % 3 == 2 &&($x+$y) % 6 == 2);

  # Wrong:
  #  my $k = ($x + 6*$y) % 36;
  #  return ($k == 0+6*2 || $k == 3+6*5);
}

MyOEIS::compare_values
  (anum => q{A038588},      # no duplicates
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new (points => 'even');
     my @got;
     my $n = $path->n_start;
     my $num = 0;
     my $want_norm = 12;
     while (@got < $count) {
       my ($x,$y) = $path->n_to_xy($n);
       my $norm = $x*$x + 3*$y*$y;

       if (! xy_is_tcentred($x,$y)) {
         ### sk: "$n at $x,$y norm=$norm"
         $n++;
         next;
       }

       if ($norm > $want_norm) {
         ### push: $num
         push @got, $num;
         $want_norm = $norm;
       } else {
         ### point: "$n at $x,$y norm=$norm  total num=$num"
         $num++;
         $n++;
       }
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => q{A038587},       # with duplicates
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new (points => 'even');
     my @got;
     my $n = $path->n_start;
     my $num = 0;
     my $want_norm = 12;
     while (@got < $count) {
       my ($x,$y) = $path->n_to_xy($n);
       if (! xy_is_tcentred($x,$y)) {
         $n++;
         next;
       }
       my $norm = $x*$x + 3*$y*$y;

       if ($norm > $want_norm) {
         ### push: $num
         push @got, $num;
         $want_norm += 36;
       } else {
         ### point: "$n at $x,$y norm=$norm  total num=$num"
         $num++;
         $n++;
       }
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => q{A005882},       # with zeros
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new (points => 'even');
     my @got;
     my $n = $path->n_start;
     my $num = 0;
     my $want_norm = 12;
     while (@got < $count) {
       my ($x,$y) = $path->n_to_xy($n);
       if (! xy_is_tcentred($x,$y)) {
         $n++;
         next;
       }
       my $norm = $x*$x + 3*$y*$y;
       if ($norm > $want_norm) {
         ### push: $num
         push @got, $num;
         $want_norm += 36;
         $num = 0;
       } else {
         ### point: "$n at $x,$y norm=$norm  total num=$num"
         $n++;
         $num++;
       }
     }
     return \@got;
   });

MyOEIS::compare_values
  (anum => q{A033685},       # with zeros, 1/3 steps of norm
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new (points => 'even');
     my @got = (0);
     my $n = $path->n_start;
     my $num = 0;
     my $want_norm = 12;
     while (@got < $count) {
       my ($x,$y) = $path->n_to_xy($n);
       if (! xy_is_tcentred($x,$y)) {
         $n++;
         next;
       }
       my $norm = $x*$x + 3*$y*$y;
       if ($norm > $want_norm) {
         ### push: $num
         push @got, $num;
         $want_norm += 12;
         $num = 0;
       } else {
         ### point: "$n at $x,$y norm=$norm  total num=$num"
         $n++;
         $num++;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A014201 - number of solutions x^2+xy+y^2 <= n excluding 0,0
#
# norm = x^2+x*y+y^2 <= n
#      = (X^2 + 3*Y^2) / 4 <= n
#      = X^2 + 3*Y^2 <= 4*n

MyOEIS::compare_values
  (anum => 'A014201',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new (points => 'even');
     my @got;
     my $num = 0;
     my $want_norm = 0;
     my $n = $path->n_start + 1; # skip X=0,Y=0 at N=Nstart
     while (@got < $count) {
       my ($x,$y) = $path->n_to_xy($n);

       ($x,$y) = (($y-$x)/2, ($x+$y)/2);
       my $norm = $x*$x + $x*$y + $y*$y;

       if ($norm > $want_norm) {
         ### push: $num
         push @got, $num;
         $want_norm++;
       } else {
         $num++;
         ### point: "$n at $x,$y norm=$norm  total num=$num"
         $n++;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A038589 - number of solutions x^2+xy+y^2 <= n including 0,0
#         - sizes successive clusters A2 centred at lattice point

MyOEIS::compare_values
  (anum => 'A038589',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new (points => 'even');
     my @got;
     my $num = 0;
     my $want_norm = 0;
     my $n = $path->n_start;
     while (@got < $count) {
       my ($x,$y) = $path->n_to_xy($n);

       ($x,$y) = (($y-$x)/2, ($x+$y)/2);
       my $norm = $x*$x + $x*$y + $y*$y;

       if ($norm > $want_norm) {
         ### push: $num
         push @got, $num;
         $want_norm++;
       } else {
         $num++;
         ### point: "$n at $x,$y norm=$norm  total num=$num"
         $n++;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A092572 - all X^2+3Y^2 values which occur, points="all" X>0,Y>0

MyOEIS::compare_values
  (anum => 'A092572',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new (points => 'all');
     my @got;
     my $prev_h = -1;
     for (my $n = 1; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy($n);
       next unless ($x > 0 && $y > 0);

       my $h = $x*$x + 3*$y*$y;
       if ($h != $prev_h) {
         push @got, $h;
         $prev_h = $h;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A158937 - all X^2+3Y^2 values which occur, points="all" X>0,Y>0, with repeats

MyOEIS::compare_values
  (anum => 'A158937',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new (points => 'all');
     my @got;
     my $prev_h = -1;
     for (my $n = 1; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy($n);
       next unless ($x > 0 && $y > 0);

       my $h = $x*$x + 3*$y*$y;
       push @got, $h;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A092573 - count of points at distance n, points="all" X>0,Y>0

MyOEIS::compare_values
  (anum => 'A092573',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new (points => 'all');
     my @got;
     my $prev_h = 0;
     my $num = 0;
     for (my $n = 1; @got+1 < $count; $n++) {
       my ($x,$y) = $path->n_to_xy($n);
       next unless ($x > 0 && $y > 0);

       my $h = $x*$x + 3*$y*$y;
       if ($h == $prev_h) {
         $num++;
       } else {
         $got[$prev_h] = $num;
         $num = 1;
         $prev_h = $h;
       }
     }
     shift @got;  # drop n=0, start from n=1
     $#got = $count-1;   # trim
     foreach my $got (@got) { $got ||= 0 }  # pad, mutate array

     return \@got;
   });

#------------------------------------------------------------------------------
# A092574 - all X^2+3Y^2 values which occur, points="all" X>0,Y>0 gcd(X,Y)=1

MyOEIS::compare_values
  (anum => 'A092574',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new (points => 'all');
     my @got;
     my $prev_h = -1;
     for (my $n = 1; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy($n);
       next unless ($x > 0 && $y > 0);
       next unless gcd($x,$y) == 1;

       my $h = $x*$x + 3*$y*$y;
       if ($h != $prev_h) {
         push @got, $h;
         $prev_h = $h;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A092575 - count of points at distance n, points="all" X>0,Y>0 gcd(X,Y)=1

MyOEIS::compare_values
  (anum => 'A092575',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new (points => 'all');
     my @got;
     my $prev_h = 0;
     my $num = 0;
     for (my $n = 1; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy($n);
       next unless ($x > 0 && $y > 0);
       next unless gcd($x,$y) == 1;

       my $h = $x*$x + 3*$y*$y;
       if ($h == $prev_h) {
         $num++;
       } else {
         $got[$prev_h] = $num;
         $num = 1;
         $prev_h = $h;
       }
     }
     shift @got;  # drop n=0, start from n=1
     $#got = $count-1;   # trim
     foreach my $got (@got) { $got ||= 0 }  # pad, mutate array

     return \@got;
   });

sub gcd {
  my ($x, $y) = @_;
  #### _gcd(): "$x,$y"

  if ($y > $x) {
    $y %= $x;
  }
  for (;;) {
    if ($y <= 1) {
      return ($y == 0 ? $x : 1);
    }
    ($x,$y) = ($y, $x % $y);
  }
}

#------------------------------------------------------------------------------
# A088534 - count of points 0<=x<=y, points="even"

MyOEIS::compare_values
  (anum => 'A088534',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new;
     my @got = (0) x scalar($count);
     my $prev_h = 0;
     my $num = 0;
     for (my $n = 1; ; $n++) {
       my ($x,$y) = $path->n_to_xy($n);
       # next unless 0 <= $x && $x <= $y;
       next unless 0 <= $y && $y <= $x/3;

       my $h = ($x*$x + 3*$y*$y) / 4;

       # Same when rotate -45 as per POD notes.
       # ($x,$y) = (($x+$y)/2,
       #            ($y-$x)/2);
       # $h = $x*$x + $x*$y + $y*$y;

       if ($h == $prev_h) {
         $num++;
       } else {
         last if $prev_h >= $count;
         $got[$prev_h] = $num;
         $num = 1;
         $prev_h = $h;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A003136 - Loeschian numbers, norms of A2 lattice

MyOEIS::compare_values
  (anum => 'A003136',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new;
     my @got;
     my $prev_h = -1;
     for (my $n = 1; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy($n);
       my $h = ($x*$x + 3*$y*$y) / 4;

       if ($h != $prev_h) {
         push @got, $h;
         $prev_h = $h;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A004016 - count of points at distance n

MyOEIS::compare_values
  (anum => 'A004016',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::TriangularHypot->new;
     my @got;
     my $prev_h = 0;
     my $num = 0;
     for (my $n = 1; @got < $count; $n++) {
       my ($x,$y) = $path->n_to_xy($n);
       my $h = ($x*$x + 3*$y*$y) / 4;

       # Same when rotate -45 as per POD notes.
       # ($x,$y) = (($x+$y)/2,
       #            ($y-$x)/2);
       # $h = $x*$x + $x*$y + $y*$y;

       if ($h == $prev_h) {
         $num++;
       } else {
         $got[$prev_h] = $num;
         $num = 1;
         $prev_h = $h;
       }
     }
     $#got = $count-1;   # trim
     foreach my $got (@got) { $got ||= 0 }  # pad, mutate array

     return \@got;
   });

#------------------------------------------------------------------------------
# A035019 - count of each hypot distance

MyOEIS::compare_values
  (anum => 'A035019',
   func => sub {
     my ($count) = @_;
    my $path = Math::PlanePath::TriangularHypot->new;
    my @got;
    my $prev_h = 0;
    my $num = 0;
    for (my $n = 1; @got < $count; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = $x*$x + 3*$y*$y;
      if ($h == $prev_h) {
        $num++;
      } else {
        push @got, $num;
        $num = 1;
        $prev_h = $h;
      }
    }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
