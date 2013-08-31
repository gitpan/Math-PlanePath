#!/usr/bin/perl -w

# Copyright 2012, 2013 Kevin Ryde

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
use Math::PlanePath::FactorRationals;

# uncomment this to run the ### lines
use Smart::Comments;

{
  # reversing binary, max factor=3
  # 0 0  0  fac=0
  # 1 1  1  fac=1
  # 2 2  2  fac=1
  # 3 -1  3  fac=3
  # 4 4  4  fac=
  # 5 -3  5  fac=
  # 6 -2  6  fac=3
  # 7 3  7  fac=
  # 8 8  8  fac=
  # 9 -7  9  fac=
  # 10 -6  10  fac=
  # 11 7  11  fac=
  # 12 -4  12  fac=3
  # 13 5  13  fac=
  # 14 6  14  fac=
  # 15 -5  15  fac=3
  # 16 16  16  fac=

  my $max_fac = 0;
  foreach my $n (0 .. 2**20) {
    my $pn = Math::PlanePath::FactorRationals::_pos_to_pn__revbinary($n);
    my $ninv = Math::PlanePath::FactorRationals::_pn_to_pos__revbinary($pn);

    my $fac = $n / abs($pn||1);
    if ($fac >= $max_fac) {
      $max_fac = $fac;
    } else {
      $fac = '';
    }
    print "$n $pn  $ninv  fac=$fac\n";

    die unless $ninv == $n;
  }
  print "\n";
  exit 0;
}

{
  # negabinary, max factor approach 5
  my %rev;
  my $max_fac = 0;
  foreach my $n (0 .. 2**20) {
    my $power = 1;
    my $nega = 0;
    for (my $bit = 1; $bit <= $n; $bit <<= 1) {
      if ($n & $bit) {
        $nega += $power;
      }
      $power *= -2;
    }
    my $fnega = Math::PlanePath::FactorRationals::_pos_to_pn__negabinary($n);
    my $ninv = Math::PlanePath::FactorRationals::_pn_to_pos__negabinary($nega);

    my $fac = -$n / ($nega||1);
    if ($fac > $max_fac) {
      $max_fac = $fac;
      print "$n $nega   $fnega $ninv  fac=$fac\n";
    } else {
      $fac = '';
    }
    $rev{$nega} = $n;
  }
  print "\n";
  exit 0;
  foreach my $nega (sort {$a<=>$b} keys %rev) {
    my $n = $rev{$nega};
    print "$nega $n\n";
  }
  exit 0;
}
