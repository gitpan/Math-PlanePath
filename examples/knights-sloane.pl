#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


# Usage: perl knights-sloane.pl
#
# This spot of code prints the infinite knight's tour path from
# Math::PlanePath::KnightSpiral, but not as X,Y positions, instead by
# numbering the X,Y positions according to the SquareSpiral and printing the
# resulting integer sequence.
#
#     1, 10, 3, 16, 19, 22, 9, 12, 15, 18, 7, 24, 11, 14, ...
#
# All squares are reached so this is a re-ordering or the integers and can
# be found as sequence A068608 of Sloane's On-Line Encyclopedia of Integer
# Sequences,
#
#     http://www.research.att.com/~njas/sequences/A068608
#
# There's eight variations on the sequence.  2 directions clockwise or
# counter-clockwise and the 4 different sides to start from.  (Is that
# right?)
#
#     A068608
#     A068609
#     A068610
#     A068611
#     A068612
#     A068613
#     A068614
#     A068615

use 5.004;
use strict;
use warnings;
use Math::PlanePath::KnightSpiral;
use Math::PlanePath::SquareSpiral;

my $knights = Math::PlanePath::KnightSpiral->new;
my $square  = Math::PlanePath::SquareSpiral->new;

foreach my $n (1 .. 20) {
  my ($x, $y) = $knights->n_to_xy ($n);
  my $sq_n = $square->xy_to_n ($x, $y);
  print "$sq_n, ";
}
print "...\n";
exit 0;

