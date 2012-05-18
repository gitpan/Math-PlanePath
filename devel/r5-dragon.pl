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
use List::MoreUtils;
use POSIX 'floor';
use Math::Libm 'M_PI', 'hypot';
use List::Util 'min', 'max';

use lib 'devel/lib';

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
use Smart::Comments;


{
  # min/max for level

  # radial extent
  #
  # dist0to5 = sqrt(1*1+2*2) = sqrt(5)
  #
  #   4-->5
  #   ^
  #   |
  #   3<--2
  #       ^
  #       |
  #   0-->1
  #
  # Rlevel = sqrt(5)^level + Rprev
  #        = sqrt(5) + sqrt(5)^2 + ... + sqrt(5)^(level-1) + sqrt(5)^level
  # if level 
  #        = sqrt(5) + sqrt(5)^2 + sqrt(5)*sqrt(5)^2 + ... 
  #        = sqrt(5) + (1+sqrt(5))*5^1 + (1+sqrt(5))*5^2 + ... 
  #        = sqrt(5) + (1+sqrt(5))* [ 5^1 + 5^2 + ... ]
  #        = sqrt(5) + (1+sqrt(5))* (5^k - 1)/4
  #        <= 5^k
  # Rlevel^2 <= 5^level

  require Math::BaseCnv;
  require Math::PlanePath::R5DragonCurve;
  my $path = Math::PlanePath::R5DragonCurve->new;
  my $prev_min = 1;
  my $prev_max = 1;
  for (my $level = 1; $level < 10; $level++) {
    my $n_start = 5**($level-1);
    my $n_end = 5**$level;

    my $min_hypot = 128*$n_end*$n_end;
    my $min_x = 0;
    my $min_y = 0;
    my $min_pos = '';

    my $max_hypot = 0;
    my $max_x = 0;
    my $max_y = 0;
    my $max_pos = '';

    print "level $level  n=$n_start .. $n_end\n";

    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = $x*$x + $y*$y;

      if ($h < $min_hypot) {
        $min_hypot = $h;
        $min_pos = "$x,$y";
      }
      if ($h > $max_hypot) {
        $max_hypot = $h;
        $max_pos = "$x,$y";
      }
    }
    # print "  min $min_hypot   at $min_x,$min_y\n";
    # print "  max $max_hypot   at $max_x,$max_y\n";
    {
      my $factor = $min_hypot / $prev_min;
      my $min_hypot_5 = Math::BaseCnv::cnv($min_hypot,10,5);
      print "  min r^2 $min_hypot ${min_hypot_5}[5]  at $min_pos  factor $factor\n";
    }
    {
      my $factor = $max_hypot / $prev_max;
      my $max_hypot_5 = Math::BaseCnv::cnv($max_hypot,10,5);
      print "  max r^2 $max_hypot ${max_hypot_5}[5])  at $max_pos  factor $factor\n";
    }
    $prev_min = $min_hypot;
    $prev_max = $max_hypot;
  }
  exit 0;
}

{
  # 2i+1 powers
  my $x = 1;
  my $y = 0;
  foreach (1 .. 10) {
    ($x,$y) = ($x - 2*$y,
                 $y + 2*$x);
    print "$x  $y\n";
  }
  exit 0;
}

{
  # turn sequence
  require Math::NumSeq::PlanePathTurn;
  my @want = (0);
  foreach (1 .. 5) {
    @want = map { $_ ? (0,0,1,1,1) : (0,0,1,1,0) } @want;
  }

  my @got;
  foreach my $i (1 .. @want) {
    push @got, calc_n_turn($i);
  }
  # my $seq = Math::NumSeq::PlanePathTurn->new (planepath => 'R5DragonCurve',
  #                                             turn_type => 'Right');
  # while (@got < @want) {
  #   my ($i,$value) = $seq->next;
  #   push @got, $value;
  # }

  my $got = join(',',@got);
  my $want = join(',',@want);
  print "$got\n";
  print "$want\n";

  if ($got ne $want) {
    die;
  }
  exit 0;

  # return 0 for left, 1 for right
  sub calc_n_turn {
    my ($n) = @_;
    $n or die;
    for (;;) {
      if (my $digit = $n % 5) {
        return ($digit >= 3 ? 1 : 0);
      }
      $n = int($n/5);
    }
  }
}
