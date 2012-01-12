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

use 5.006;
use strict;
use warnings;
use POSIX;
use Math::PlanePath::ComplexMinus;

# uncomment this to run the ### lines
#use Smart::Comments;


{
  # innermost points coverage
  require Math::BaseCnv;
  foreach my $realpart (1 .. 20) {
    my $norm = $realpart**2 + 1;
    my $path = Math::PlanePath::ComplexMinus->new (realpart => $realpart);
    my $n_max = 0;
    my $show = sub {
      my ($x,$y) = @_;
      my $n = $path->xy_to_n($x,$y);
      print "$x,$y n=$n\n";
      if ($n > $n_max) {
        $n_max = $n;
      }
    };
    $show->(1,0);
    $show->(1,1);
    $show->(0,1);
    $show->(-1,1);
    $show->(-1,0);
    $show->(-1,-1);
    $show->(0,-1);
    $show->(1,-1);
    my $n_max_base = to_base($n_max,$norm);
    my $n_max_log = log($n_max)/log($norm);
    print "n_max $n_max  $n_max_base  $n_max_log\n";
    print "\n";
  }
  exit 0;

  sub to_base {
    my ($n, $radix) = @_;
    my $ret = '';
    do {
      my $digit = $n % $radix;
      $ret = "[$digit]$ret";
    } while ($n = int($n/$radix));
    return $ret;
  }
}

{
  # min/max for level
  $|=1;
  my $realpart = 2;
  my $norm = $realpart**2 + 1;
  my $path = Math::PlanePath::ComplexMinus->new (realpart => $realpart);
  my $prev_min = 1;
  my $prev_max = 1;
  for (my $level = 1; $level < 25; $level++) {
    my $n_start = $norm**($level-1);
    my $n_end = $norm**$level;

    my $min_hypot = POSIX::DBL_MAX();
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
    # print "$min_hypot,";

    # print "  min $min_hypot   at $min_x,$min_y\n";
    # print "  max $max_hypot   at $max_x,$max_y\n";
    {
      my $factor = $min_hypot / $prev_min;
      print "  min r^2 $min_hypot 0b".sprintf('%b',$min_hypot)."   at $min_pos  factor $factor\n";
      print "  cf formula ", 2**($level-7), "\n";
    }
    # {
    #   my $factor = $max_hypot / $prev_max;
    #   print "  max r^2 $max_hypot 0b".sprintf('%b',$max_hypot)."   at $max_pos  factor $factor\n";
    # }
    $prev_min = $min_hypot;
    $prev_max = $max_hypot;
  }
  exit 0;
}

{
  require Math::PlanePath::ComplexPlus;
  require Math::BigInt;
  my $realpart = 10;
  my $norm = $realpart*$realpart + 1;
  ### $norm
  my $path = Math::PlanePath::ComplexPlus->new (realpart=>$realpart);
  my $prev_dist = 1;
  print sqrt($norm),"\n";
  foreach my $level (1 .. 10) {
    my $n = Math::BigInt->new($norm) ** $level - 1;
    my ($x,$y) = $path->n_to_xy($n);
    my $radians = atan2($y,$x);
    my $degrees = $radians / 3.141592 * 180;
    my $dist = sqrt($x*$x+$y*$y);
    my $f = $dist / $prev_dist;
    printf "%2d %.2f %.4f  %.2f\n",
      $level, $dist, $f, $degrees;
    $prev_dist = $dist;
  }
  exit 0;
}

{
  require Math::PlanePath::ComplexPlus;
  my $path = Math::PlanePath::ComplexPlus->new (realpart=>2);
  foreach my $i (0 .. 10) {
    {
      my $x = $i;
      my $y = 1;
      my $n = $path->xy_to_n($x,$y);
      if (! defined $n) { $n = 'undef'; }
      print "xy_to_n($x,$y) = $n\n";
    }
  }
  foreach my $i (0 .. 10) {
    {
      my $n = $i;
      my ($x,$y) = $path->n_to_xy($n);
      print "n_to_xy($n) = $x,$y\n";
    }
  }
  exit 0;
}

{
  my $count = 0;
  my $realpart = 5;
  my $norm = $realpart*$realpart+1;
  foreach my $x (-200 .. 200) {
    foreach my $y (-200 .. 200) {
      my $new_x = $x;
      my $neg_y = $x - $y*$realpart;
      my $digit = $neg_y % $norm;
      $new_x -= $digit;
      $neg_y -= $digit;

      next unless ($new_x*$realpart+$y)/$norm == $x;
      next unless -$neg_y/$norm == $y;

      print "$x,$y  digit=$digit\n";
      $count++;
    }
  }
  print "count $count\n";
  exit 0;
}

