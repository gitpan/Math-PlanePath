#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

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

use 5.010;
use strict;
use warnings;
use List::Util 'min', 'max';
use Math::PlanePath::ChanTree;
use Math::PlanePath::Base::Digits
  'round_down_pow',
  'digit_split_lowtohigh';

# uncomment this to run the ### lines
use Smart::Comments;

{
  # X/Y list
  require Math::PlanePath::GcdRationals;
  require Math::BaseCnv;
  my $k = 10;
  my $path = Math::PlanePath::ChanTree->new
    (k => $k,
     n_start => 1,
    );
  my $n = $path->n_start;
  my $prevlen = 1;
  for (;;) {
    my $nk = Math::BaseCnv::cnv($n,10,$k);
    my $len = length($nk);
    last if $len > 3;
    if ($len > $prevlen) {
      print "\n";
      $prevlen = $len;
    }
    my ($x,$y) = $path->n_to_xy($n);
    my $gcd = Math::PlanePath::GcdRationals::_gcd($x,$y);
    my $xg = $x/$gcd;
    my $yg = $y/$gcd;
    print "$n $nk  $x / $y   $gcd  reduced $xg,$yg\n";
    $n++;
  }
  exit 0;
}

{
  # 1 2 2 
  # 1 4 6 5 2 6 8 6 2 5 6 4 1 6 10 9 4 14 20 16 6 17 22 16 5 12 14 9

  require Math::Polynomial;
  Math::Polynomial->string_config({ ascending => 1 });

  sub make_poly_k4 {
    my ($level) = @_;
    my $pow = 4**$level;
    my $exp = 0;
    my $ret = 0;
    foreach my $coeff (1,2,2,1,2,2,1) {
      $ret += Math::Polynomial->monomial ($exp, $coeff);
      $exp += $pow;
    }
    return $ret;
  }
  print make_poly_k4(0),"\n";
  print make_poly_k4(1),"\n";

  my $poly = 1;
  foreach my $level (0 .. 4) {
    $poly *= make_poly_k4($level);
    foreach my $i (0 .. 30) {
      print " ",$poly->coeff($i);
    }
    print "\n";
  }
  exit 0;
}

{
  # children formulas
  foreach my $k (3 .. 8) {
    my $half_ceil = int(($k+1) / 2);
    foreach my $digit (0 .. $k-1) {
      my $c1 = ($digit < $half_ceil ? $digit+1 : $k-$digit);
      my $c0 = ($digit <= $half_ceil ? $digit : $k-$digit+1);
      my $c2 = ($digit < $half_ceil-1 ? $digit+2 : $k-$digit-1);
      print "${c1}x + ${c0}y / ${c2}x + ${c1}y\n";
    }
    print "\n";
  }
  exit 0;
}

{
 # 1 2 3 2 1 4 7 8 5 2 7 12 13 8 3 8 13 12 7 2 5 8 7 4 1 6 11 14 9 4 15

  require Math::Polynomial;
  Math::Polynomial->string_config({ ascending => 1 });

  sub make_poly_k5 {
    my ($level) = @_;
    my $pow = 5**$level;
    my $exp = 0;
    my $ret = 0;
    foreach my $coeff (1,2,3,2,1,2,3,2,1) {
      $ret += Math::Polynomial->monomial ($exp, $coeff);
      $exp += $pow;
    }
    return $ret;
  }
  print make_poly_k5(0),"\n";
  print make_poly_k5(1),"\n";

  my $poly = 1;
  foreach my $level (0 .. 4) {
    $poly *= make_poly_k5($level);
    foreach my $i (0 .. 30) {
      print " ",$poly->coeff($i);
    }
    print "\n";
  }
  # (1 + 2*x + 3*x^2 + 2*x^3 + x^4 + 2*x^5 + 3*x^6 + 2*x^7 + x^8)
  # * (1 + 2*x^5 + 3*x^10 + 2*x^15 + x^20 + 2*x^25 + 3*x^30 + 2*x^35 + x^40)
  # * (1 + 2*x^(25*1) + 3*x^(25*2) + 2*x^(25*3) + x^(25*4) + 2*x^(25*5) + 3*x^(25*6) + 2*x^(25*7) + x^(25*8))
  exit 0;
}

