#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

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
#use Smart::Comments;



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
  # total turn
  require Math::PlanePath::AlternatePaper;
  require Math::BaseCnv;
  my $path = Math::PlanePath::AlternatePaper->new;
  my $total = 0;
  my $bits_total = 0;
  for (my $n = 1; $n <= 64; $n++) {
    my $n2 = Math::BaseCnv::cnv($n,10,2);
    my $n4 = Math::BaseCnv::cnv($n,10,4);
    printf "%10s %10s  %2d %2d\n", $n2, $n4, $total, $bits_total;

    # print "$total,";

    
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

  use Math::PlanePath::GrayCode;
  sub total_turn_by_bits {
    my ($n) = @_;
    my $bits = Math::PlanePath::GrayCode::_digit_split($n,2);
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
  # dX
  require Math::PlanePath::AlternatePaper;
  require Math::BaseCnv;
  my $path = Math::PlanePath::AlternatePaper->new;
  for (my $n = 0; $n <= 64; $n += 2) {
    my $n2 = Math::BaseCnv::cnv($n,10,2);
    my $n4 = Math::BaseCnv::cnv($n,10,4);
    my $dx = path_n_dx ($path, $n);

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

{
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
    printf "%10s %10s  %d %d,%d\n", $n2, $n4, $n,$x,$y;
  }
  exit 0;
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
  return dxdy_to_dir ($next_x - $x,
                      $next_y - $y);
}
# return 0,1,2,3, with Y reckoned increasing upwards
sub dxdy_to_dir {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 0; }  # east
  if ($dx < 0) { return 2; }  # west
  if ($dy > 0) { return 1; }  # north
  if ($dy < 0) { return 3; }  # south
}
