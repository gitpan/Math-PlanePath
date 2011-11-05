#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

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

# uncomment this to run the ### lines
use Smart::Comments;


{
  foreach my $i (0 .. 32) {
    printf "%05b  %05b\n", $i, _from_gray($i);
  }
  sub _from_gray {
    my ($n) = @_;
    my @digits;
    while ($n) {
      push @digits, $n & 1;
      $n >>= 1;
    }
    my $xor = 0;
    my $ret = 0;
    while (@digits) {
      my $digit = pop @digits;
      $ret <<= 1;
      $ret |= $digit^$xor;
      $xor ^= $digit;
    }
    return $ret;
  }
  exit 0;
}
