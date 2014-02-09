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
use List::Util 'min', 'max';
use Math::Trig 'pi';
use Math::PlanePath::Base::Digits 'digit_split_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments;


{
  # total turn
  require Math::PlanePath::AlternatePaper;
  require Math::BaseCnv;
  my $path = Math::PlanePath::AlternatePaper->new;
  my $total = 0;
  my $bits_total = 0;
  my @values;
  for (my $n = 1; $n <= 32; $n++) {
    my $n2 = Math::BaseCnv::cnv($n,10,2);
    my $n4 = Math::BaseCnv::cnv($n,10,4);
    printf "%10s %10s  %2d %2d\n", $n2, $n4, $total, $bits_total;

    # print "$total,";
    push @values, $total;
    
    $bits_total = total_turn_by_bits($n);

    my $turn = path_n_turn ($path, $n);
    if ($turn == 1) { # left
      $total++;
    } elsif ($turn == 0) { # right
      $total--;
    } else {
      die;
    }
  }

  use lib 'xt'; require MyOEIS;
  print join(',',@values),"\n";
  print MyOEIS->grep_for_values_aref(\@values);

  use Math::PlanePath;
  use Math::PlanePath::GrayCode;
  sub total_turn_by_bits {
    my ($n) = @_;
    my $bits = [ digit_split_lowtohigh($n,2) ];
    my $rev = 0;
    my $total = 0;
    for (my $pos = $#$bits; $pos >= 0; $pos--) { # high bit to low bit
      my $bit = $bits->[$pos];
      if ($rev) {
        if ($bit) {
        } else {
          if ($pos & 1) {
            $total--;
          } else {
            $total++;
          }
          $rev = 0;
        }
      } else {
        if ($bit) {
          if ($pos & 1) {
            $total--;
          } else {
            $total++;
          }
          $rev = 1;
        } else {
        }
      }
    }
    return $total;
  }

  exit 0;
}
{
  require Math::PlanePath::AlternatePaper;
  require Math::PlanePath::AlternatePaperMidpoint;
  my $paper = Math::PlanePath::AlternatePaper->new (arms => 8);
  my $midpoint = Math::PlanePath::AlternatePaperMidpoint->new (arms => 8);
  foreach my $n (0 .. 7) {
    my ($x1,$y1) = $paper->n_to_xy($n);
    my ($x2,$y2) = $paper->n_to_xy($n+8);
    my ($mx,$my) = $midpoint->n_to_xy($n);

    my $x = $x1+$x2;    # midpoint*2
    my $y = $y1+$y2;
    ($x,$y) = (($x+$y-1)/2,
               ($x-$y-1)/2);  # rotate -45 and shift

    print "$n  $x,$y   $mx,$my\n";
  }
  exit 0;
}

{
  # grid X,Y offset
  require Math::PlanePath::AlternatePaperMidpoint;
  my $path = Math::PlanePath::AlternatePaperMidpoint->new (arms => 8);

  my %dxdy_to_digit;
  my %seen;
  for (my $n = 0; $n < 4**4; $n++) {
    my $digit = $n % 4;

    foreach my $arm (0 .. 7) {
      my ($x,$y) = $path->n_to_xy(8*$n+$arm);
      my $nb = int($n/4);
      my ($xb,$yb) = $path->n_to_xy(8*$nb+$arm);

      $xb *= 2;
      $yb *= 2;
      my $dx = $xb - $x;
      my $dy = $yb - $y;

      my $dxdy = "$dx,$dy";
      my $show = "${dxdy}[$digit]";
      $seen{$x}{$y} = $show;
      if ($dxdy eq '0,0') {
      }
      $dxdy_to_digit{$dxdy} = $digit;
    }
  }

  foreach my $y (reverse -45 .. 45) {
    foreach my $x (-5 .. 5) {
      printf " %9s", $seen{$x}{$y}//'e'
    }
    print "\n";
  }
  ### %dxdy_to_digit

  exit 0;
}

{
  # sum/sqrt(n) goes below pi/4
 print "pi/4 ",pi/4,"\n";
  require Math::PlanePath::AlternatePaper;
  my $path = Math::PlanePath::AlternatePaper->new;
  my $min = 999;
  for my $n (1 .. 102400) {
    my ($x,$y) = $path->n_to_xy($n);
    my $sum = $x+$y;
    my $frac = $sum/sqrt($n);
#    printf "%10s %.4f\n", "$n,$x,$y", $frac;
    $min = min($min,$frac);
  }
  print "min  $min\n";
  exit 0;
}

{
  # repeat points
  require Math::PlanePath::AlternatePaper;
  require Math::BaseCnv;
  my $path = Math::PlanePath::AlternatePaper->new;
  for my $nn (0 .. 1024) {
    my ($x,$y) = $path->n_to_xy($nn);

     next unless $y == 18;

    my ($n,$m) = $path->xy_to_n_list($x,$y);
    next unless ($n == $nn) && $m;

    my $diff = $m - $n;
    my $xor = $m ^ $n;
    my $n4 = Math::BaseCnv::cnv($n,10,4);
    my $m4 = Math::BaseCnv::cnv($m,10,4);
    my $diff4 = Math::BaseCnv::cnv($diff,10,4);
    my $xor4 = Math::BaseCnv::cnv($xor,10,4);
    printf "%10s %6s %6s %6s,%-6s\n",
      "$n,$x,$y", $n4, $m4, $diff4, $diff4;
  }
  exit 0;
}

{
  # dY
  require Math::PlanePath::AlternatePaper;
  require Math::BaseCnv;
  my $path = Math::PlanePath::AlternatePaper->new;
  for (my $n = 1; $n <= 64; $n += 2) {
    my $n2 = Math::BaseCnv::cnv($n,10,2);
    my $n4 = Math::BaseCnv::cnv($n,10,4);
    my $dy = path_n_dy ($path, $n);

    my $nhalf = $n>>1;
    my $grs_half = GRS($nhalf);
    my $calc_dy = $grs_half * (($nhalf&1) ? -1 : 1);
    my $diff = ($calc_dy == $dy ? '' : '  ****');

    my $grs = GRS($n);

    printf "%10s %10s  %2d %2d %2d%s\n", $n2, $n4,
      $dy,
        $grs,
          $calc_dy,$diff;
  }
  exit 0;


  sub GRS {
    my ($n) = @_;
    return (count_1_bits($n&($n>>1)) & 1 ? -1 : 1);
  }
  sub count_1_bits {
    my ($n) = @_;
    my $count = 0;
    while ($n) {
      $count += ($n & 1);
      $n >>= 1;
    }
    return $count;
  }
}


{
  # base4 X,Y axes and diagonal
  # diagonal base4 all twos
  require Math::PlanePath::AlternatePaper;
  require Math::BaseCnv;
  my $path = Math::PlanePath::AlternatePaper->new;
  for my $x (0 .. 40) {
    my $y;
    $y = 0;
    $y = $x;

    my $n = $path->xy_to_n($x,$y);
    my $n2 = Math::BaseCnv::cnv($n,10,2);
    my $n4 = Math::BaseCnv::cnv($n,10,4);
    printf "%14s %10s  %4d  %d,%d\n",
      $n2, $n4, $n,$x,$y;
  }
  exit 0;
}




{
  # dX
  require Math::PlanePath::AlternatePaper;
  require Math::BaseCnv;
  my $path = Math::PlanePath::AlternatePaper->new;
  for (my $n = 0; $n <= 64; $n += 2) {
    my $n2 = Math::BaseCnv::cnv($n,10,2);
    my $n4 = Math::BaseCnv::cnv($n,10,4);
    my ($dx,$dy) = $path->n_to_dxdy($n);

    my $grs = GRS($n);
    my $calc_dx = 0;
    my $diff = ($calc_dx == $dx ? '' : '  ****');
    printf "%10s %10s  %2d %2d %2d%s\n", $n2, $n4,
      $dx,
        $grs,
          $calc_dx,$diff;
  }
  exit 0;
}

{
  # plain    rev
  # 0   0   0 -90
  # 1 +90   1   0
  # 2   0   2 +90
  # 3 -90   3   0
  #
  # dX ends even so plain, count 11 bits mod 2
  # dY ends odd so rev,

  # dX,dY
  require Math::PlanePath::AlternatePaper;
  require Math::BaseCnv;
  my $path = Math::PlanePath::AlternatePaper->new;
  for (my $n = 0; $n <= 128; $n += 2) {
    my ($x,$y) = $path->n_to_xy($n);
    my ($next_x,$next_y) = $path->n_to_xy($n+1);
    my $dx = $next_x - $x;
    my $dy = - path_n_dy ($path,$n ^ 0xFFFF);

    my $n2 = Math::BaseCnv::cnv($n,10,2);
    my $n4 = Math::BaseCnv::cnv($n,10,4);
    printf "%10s %10s  %2d,%2d\n", $n2, $n4, $dx,$dy;
  }
  exit 0;

  sub path_n_dx {
    my ($path,$n) = @_;
    my ($x,$y) = $path->n_to_xy($n);
    my ($next_x,$next_y) = $path->n_to_xy($n+1);
    return $next_x - $x;
  }
  sub path_n_dy {
    my ($path,$n) = @_;
    my ($x,$y) = $path->n_to_xy($n);
    my ($next_x,$next_y) = $path->n_to_xy($n+1);
    return $next_y - $y;
  }
}

# return 1 for left, 0 for right
sub path_n_turn {
  my ($path, $n) = @_;
  my $prev_dir = path_n_dir ($path, $n-1);
  my $dir = path_n_dir ($path, $n);
  my $turn = ($dir - $prev_dir) % 4;
  if ($turn == 1) { return 1; }
  if ($turn == 3) { return 0; }
  die "Oops, unrecognised turn";
}
# return 0,1,2,3
sub path_n_dir {
  my ($path, $n) = @_;
  my ($x,$y) = $path->n_to_xy($n);
  my ($next_x,$next_y) = $path->n_to_xy($n+1);
  return dxdy_to_dir4 ($next_x - $x,
                      $next_y - $y);
}
# return 0,1,2,3, with Y reckoned increasing upwards
sub dxdy_to_dir4 {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 0; }  # east
  if ($dx < 0) { return 2; }  # west
  if ($dy > 0) { return 1; }  # north
  if ($dy < 0) { return 3; }  # south
}
