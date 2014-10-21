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


# A182619 Number of vertices that are connected to two edges in a spiral without holes constructed with n hexagons.
# A182617 Number of toothpicks in a toothpick spiral around n cells on hexagonal net.
# A182618 Number of new grid points that are covered by the toothpicks added at n-th-stage to the toothpick spiral of A182617.

# A063178 Hexagonal spiral sequence: sequence is written as a hexagonal spiral around a `dummy' center, each entry is the sum of the row in the previous direction containing the previous entry.
# A063253 Values of A063178 on folding point positions of the spiral.
# A063254 Values of A062410 on folding point positions of the spiral.
# A063255 Values of A063177 on folding point positions of the spiral.


# A113519 Semiprimes in first spoke of a hexagonal spiral (A056105).
# A113524 Semiprimes in second spoke of a hexagonal spiral (A056106).
# A113525 Semiprimes in third spoke of a hexagonal spiral (A056107).
# A113527 Semiprimes in fourth spoke of a hexagonal spiral (A056108).
# A113528 Semiprimes in fifth spoke of a hexagonal spiral (A056109).
# A113530 Semiprimes in sixth spoke of a hexagonal spiral (A003215). Semiprime hex (or centered hexagonal) numbers.
# A113653 Isolated semiprimes in the hexagonal spiral.


use 5.004;
use strict;
use Test;
plan tests => 1;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }
use MyOEIS;

use List::Util 'min', 'max';
use Math::PlanePath::HexSpiral;

# uncomment this to run the ### lines
#use Smart::Comments '###';


#------------------------------------------------------------------------------
# A063436 -- N on slope=3 WSW

MyOEIS::compare_values
  (anum => 'A063436',
   func => sub {
     my ($count) = @_;
     my @got;
     my $path = Math::PlanePath::HexSpiral->new (n_start => 0);
     my $x = 0;
     my $y = 0;
     while (@got < $count) {
       push @got, $path->xy_to_n ($x,$y);
       $x -= 3;
       $y -= 1;
     }
     return \@got;
   });


#------------------------------------------------------------------------------
# A063178 -- a(n) is sum of existing numbers in row of a(n-1)

#                   42
#                     \
#           2-----1    33
#         /        \     \
#        3     0-----1    23
#         \              /
#           5-----8----10
#
#        ^  ^  ^  ^  ^  ^  ^

MyOEIS::compare_values
  (anum => 'A063178',
   func => sub {
     my ($count) = @_;
     my $path = Math::PlanePath::HexSpiral->new;
     my @got;
     require Math::BigInt;
     my %plotted;
     $plotted{2,0} = Math::BigInt->new(1);
     my $xmin = 0;
     my $ymin = 0;
     my $xmax = 2;
     my $ymax = 0;
     push @got, 1;

     for (my $n = $path->n_start + 2; @got < $count; $n++) {
       my ($prev_x, $prev_y) = $path->n_to_xy ($n-1);
       my ($x, $y) = $path->n_to_xy ($n);
       ### at: "$x,$y  prev $prev_x,$prev_y"

       my $total = 0;
       if (($y > $prev_y && $x < $prev_x)
           || ($y < $prev_y && $x > $prev_x)) {
         ### forward diagonal ...
         foreach my $y ($ymin .. $ymax) {
           my $delta = $y - $prev_y;
           my $x = $prev_x + $delta;
           $total += $plotted{$x,$y} || 0;
         }
       } elsif (($y == $prev_y && $x < $prev_x)
                || ($y == $prev_y && $x > $prev_x)) {
         ### opp diagonal ...
         foreach my $y ($ymin .. $ymax) {
           my $delta = $y - $prev_y;
           my $x = $prev_x - $delta;
           $total += $plotted{$x,$y} || 0;
         }
       } else {
         ### row: "$xmin .. $xmax at y=$prev_y"
         foreach my $x ($xmin .. $xmax) {
           $total += $plotted{$x,$prev_y} || 0;
         }
       }
       ### total: "$total"

       $plotted{$x,$y} = $total;
       $xmin = min($xmin,$x);
       $xmax = max($xmax,$x);
       $ymin = min($ymin,$y);
       $ymax = max($ymax,$y);
       push @got, $total;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
exit 0;
