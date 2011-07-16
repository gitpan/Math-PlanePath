#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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


# Usage: perl hilbert-oeis.pl
#
# This spot of code prints sequence A163359 of Sloane's On-Line Encyclopedia
# of Integer Sequences
#
#     http://www.research.att.com/~njas/sequences/A163359
#
# which is the Hilbert curve N values which occur on squares numbered
# diagonally per Math::PlanePath::Diagonals,
#
#     0, 3, 1, 4, 2, 14, 5, 7, 13, 15, 58, 6, 8, 12, 16, 59, ...
#
# All squares are reached by both paths, so this is a re-ordering or the
# integers.
#
# In the code there's a kind of double transpose going on.  A163359 is
# conceived as the Hilbert starting downwards and the diagonals numbered
# from the X axis, but the HilbertCurve module code goes right first and the
# Diagonals module numbers from the Y axis.  The effect is the same,
# ie. that the first Hilbert step is the opposite axis as the diagonals are
# numbered from.
#
# Swapping the $x,$y in the code transposes the diagonals to make the first
# Hilbert step the same axis as the diagonal numbering, and that gives
# sequence A163357.
#

use 5.004;
use strict;
use Math::PlanePath::HilbertCurve;
use Math::PlanePath::Diagonals;

my $hilbert = Math::PlanePath::HilbertCurve->new;
my $diagonal  = Math::PlanePath::Diagonals->new;

print "A163359: ";
foreach my $n (1 .. 19) {  # Diagonals starts at N=1
  my ($x, $y) = $diagonal->n_to_xy ($n);
  my $hilbert_n = $hilbert->xy_to_n ($x, $y);
  print "$hilbert_n, ";
}
print "...\n";
exit 0;
