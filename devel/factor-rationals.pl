#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

# This file is part of Math-PlanePath.
#
# Math-PlanePath is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-PlanePath is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-PlanePath.  If not, see <http://www.gnu.org/licenses/>.


use 5.010;
use strict;
use List::Util 'min', 'max';

# uncomment this to run the ### lines
use Devel::Comments;

{
  # negabinary
  my %rev;
  foreach my $n (0 .. 32) {
    my $power = 1;
    my $nega = 0;
    for (my $bit = 1; $bit <= $n; $bit <<= 1) {
      if ($n & $bit) {
        $nega += $power;
      }
      $power *= -2;
    }
    print "$n $nega\n";
    $rev{$nega} = $n;
  }
  print "\n";
  foreach my $nega (sort {$a<=>$b} keys %rev) {
    my $n = $rev{$nega};
    print "$nega $n\n";
  }
  exit 0;
}
