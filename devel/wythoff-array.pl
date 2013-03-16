#!/usr/bin/perl -w

# Copyright 2012, 2013 Kevin Ryde

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
use Math::PlanePath::WythoffArray;

# uncomment this to run the ### lines
#use Smart::Comments;


{
  # left-align shift amount
  my $path = Math::PlanePath::WythoffArray->new;
  foreach my $y (0 .. 50) {
    my $a = $path->xy_to_n(0,$y);
    my $b = $path->xy_to_n(1,$y);
    my $count = 0;
    while ($a < $b) {
      ($a,$b) = ($b-$a,$a);
      $count++;
    }
    print "$y  $count\n";
  }
  exit 0;
}
{
  # Y*phi
  use constant PHI => (1 + sqrt(5)) / 2;
  my $path = Math::PlanePath::WythoffArray->new (y_start => 0);
  foreach my $y ($path->y_minimum .. 20) {
    my $n = $path->xy_to_n(0,$y);
    my $prod = int(PHI*PHI*$y + PHI);
    print "$y  $n $prod\n";
  }
  exit 0;
}
{
  # dual
  require Math::NumSeq::Fibbinary;
  my $seq = Math::NumSeq::Fibbinary->new;
  foreach my $value
    (
1 .. 300,
     1,
     #                                                    # 1,10
     # 4, 6, 10, 16, 26, 42, 68, 110, 178, 288, 466       # 101,1001
     # 7, 11, 18, 29, 47, 76, 123, 199, 322, 521, 843     # 1010,10100
     # 9, 14, 23, 37, 60, 97, 157, 254, 411, 665, 1076,   # 10001,100001
     # 12, 19, 31, 50, 81, 131, 212, 343, 555, 898, 1453  # 10101,101001

    ) {
    my $z = $seq->ith($value);
    printf "%3d %6b\n", $value, $z;
  }
  exit 0;
}

{
  # Fibbinary with even trailing 0s
  require Math::NumSeq::Fibbinary;
  require Math::NumSeq::DigitCountLow;
  my $seq = Math::NumSeq::Fibbinary->new;
  my $cnt = Math::NumSeq::DigitCountLow->new (radix => 2, digit => 0);
  my $e = 0;
  foreach (1 .. 40) {
    my ($i,  $value) = $seq->next;
    my $c = $cnt->ith($value);
    my $str = ($c % 2 ? 'odd' : 'even');
    my $ez = $seq->ith($e);
    if ($c % 2 == 0) {
      printf "%2d %6b %s [%d]   %5b\n", $i, $value, $str, $c, $ez;
    } else {
      printf "%2d %6b %s [%d]\n", $i, $value, $str, $c;
    }
    if ($c % 2 == 0) {
      $e++;
    }
  }
  exit 0;
}

{
  require Math::BaseCnv;
  require Math::PlanePath::PowerArray;
  my $path;
  my $radix = 3;
  my $width = 9;
  $path = Math::PlanePath::PowerArray->new (radix => $radix);
  foreach my $y (reverse 0 .. 6) {
    foreach my $x (0 .. 5) {
      my $n = $path->xy_to_n($x,$y);
      my $nb = sprintf '%*s', $width, Math::BaseCnv::cnv($n,10,$radix);
      print $nb;
    }
    print "\n";
  }
  exit 0;
}

{
  # max Dir4

  require Math::BaseCnv;

  print 4-atan2(2,1)/atan2(1,1)/2,"\n";

  require Math::NumSeq::PlanePathDelta;
  my $realpart = 3;
  my $radix = $realpart*$realpart + 1;
  my $planepath = "WythoffArray";
   $planepath = "GcdRationals,pairs_order=rows_reverse";
  my $seq = Math::NumSeq::PlanePathDelta->new (planepath => $planepath,
                                               delta_type => 'Dir4');
  my $dx_seq = Math::NumSeq::PlanePathDelta->new (planepath => $planepath,
                                                  delta_type => 'dX');
  my $dy_seq = Math::NumSeq::PlanePathDelta->new (planepath => $planepath,
                                                  delta_type => 'dY');
  my $max = -99;
  for (1 .. 1000000) {
    my ($i, $value) = $seq->next;
    $value = -$value;
    if ($value > $max) {
      my $dx = $dx_seq->ith($i);
      my $dy = $dy_seq->ith($i);
      my $ri = Math::BaseCnv::cnv($i,10,$radix);
      my $rdx = Math::BaseCnv::cnv($dx,10,$radix);
      my $rdy = Math::BaseCnv::cnv($dy,10,$radix);
      my $f = $dy && $dx/$dy;
      printf "%d %s %.5f  %s %s   %.3f\n", $i, $ri, $value, $rdx,$rdy, $f;
      $max = $value;
    }
  }

  exit 0;
}
