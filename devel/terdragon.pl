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
use List::Util 'min', 'max';

# # skip low zeros
# # 1 left
# # 2 right
# ones(n) - ones(n+1)

# 1*3^k  left
# 2*3^k  right

{
  # cumulative turn +/- 1 list
  require Math::PlanePath::TerdragonCurve;
  require Math::BaseCnv;
  my $path = Math::PlanePath::TerdragonCurve->new;
  my $cumulative = 0;
  for (my $n = $path->n_start + 1; $n < 35; $n++) {
    my $n3 = Math::BaseCnv::cnv($n,10,3);
    my $turn = calc_n_turn ($n);
    #    my $turn = path_n_turn($path, $n);
    if ($turn == 2) { $turn = -1 }
    $cumulative += $turn;
    printf "%3s  %4s  %d\n", $n, $n3, $cumulative;
  }
  print "\n";
  exit 0;
}

{
  # cumulative turn +/- 1
  require Math::PlanePath::TerdragonCurve;
  my $path = Math::PlanePath::TerdragonCurve->new;
  my $cumulative = 0;
  my $max = 0;
  my $min = 0;
  for (my $n = $path->n_start + 1; $n < 35; $n++) {
    my $turn = calc_n_turn ($n);
    #    my $turn = path_n_turn($path, $n);
    if ($turn == 2) { $turn = -1 }
    $cumulative += $turn;
    $max = max($cumulative,$max);
    $min = min($cumulative,$min);
        print "$cumulative,";
  }
  print "\n";
  print "min $min  max $max\n";
  exit 0;

  sub calc_n_turn {
    my ($n) = @_;

    die if $n == 0;
    while (($n % 3) == 0) {
      $n = int($n/3); # skip low 0s
    }
    return ($n % 3);  # next digit is the turn
  }
}

{
  # turn
  require Math::PlanePath::TerdragonCurve;
  my $path = Math::PlanePath::TerdragonCurve->new;

  my $n = $path->n_start;
  # my ($n0_x, $n0_y) = $path->n_to_xy ($n);
  # $n++;
  # my ($prev_x, $prev_y) = $path->n_to_xy ($n);
  # my ($prev_dx, $prev_dy) = ($prev_x - $n0_x, $prev_y - $n0_y);
  # my $prev_dir = dxdy_to_dir ($prev_dx, $prev_dy);
  $n++;

  my $pow = 3;
  for ( ; $n < 128; $n++) {
    # my ($x, $y) = $path->n_to_xy ($n);
    # my $dx = ($x - $prev_x);
    # my $dy = ($y - $prev_y);
    # my $dir = dxdy_to_dir ($dx, $dy);
    # my $turn = ($dir - $prev_dir) % 3;
    # 
    # $prev_dir = $dir;
    # ($prev_x,$prev_y) = ($x,$y);

    my $turn = path_n_turn($path, $n);

    my $azeros = digit_above_low_zeros($n);
    my $azx = ($azeros == $turn ? '' : '*');

    # my $aones = digit_above_low_ones($n-1);
    # if ($aones==0) { $aones=1 }
    # elsif ($aones==1) { $aones=0 }
    # elsif ($aones==2) { $aones=2 }
    # my $aox = ($aones == $turn ? '' : '*');
    #
    # my $atwos = digit_above_low_twos($n-2);
    # if ($atwos==0) { $atwos=1 }
    # elsif ($atwos==1) { $atwos=2 }
    # elsif ($atwos==2) { $atwos=0 }
    # my $atx = ($atwos == $turn ? '' : '*');
    #
    # my $lzero = digit_above_low_zeros($n);
    # my $lone = digit_above_lowest_one($n);
    # my $ltwo = digit_above_lowest_two($n);
    # print "$n  $turn   ones $aones$aox   twos $atwos$atx  zeros $azeros${azx}[$lzero]    $lone $ltwo\n";

    print "$n  $turn   zeros got=$azeros ${azx}\n";
  }
  print "\n";
  exit 0;

  sub digit_above_low_zeros {
    my ($n) = @_;
    if ($n == 0) {
      return 0;
    }
    while (($n % 3) == 0) {
      $n = int($n/3);
    }
    return ($n % 3);
  }

  sub path_n_turn {
    my ($path, $n) = @_;
    my $prev_dir = path_n_dir ($path, $n-1);
    my $dir = path_n_dir ($path, $n);
    return ($dir - $prev_dir) % 3;
  }
  sub path_n_dir {
    my ($path, $n) = @_;
    my ($prev_x, $prev_y) = $path->n_to_xy ($n);
    my ($x, $y) = $path->n_to_xy ($n+1);
    return dxdy_to_dir($x - $prev_x, $y - $prev_y);
  }
}

{
  # min/max for level
  require Math::PlanePath::TerdragonCurve;
  require Math::BaseCnv;
  my $path = Math::PlanePath::TerdragonCurve->new;
  my $prev_min = 1;
  my $prev_max = 1;
  for (my $level = 1; $level < 25; $level++) {
    my $n_start = 3**($level-1);
    my $n_end = 3**$level;

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
      my $h = $x*$x + 3*$y*$y;

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
      my $min_hypot3 = Math::BaseCnv::cnv($min_hypot,10,3);
      print "  min h= $min_hypot  [$min_hypot3]   at $min_pos  factor $factor\n";
      my $calc = (4/3/3) * 2.9**$level;
      print "    cf $calc\n";
    }
    # {
    #   my $factor = $max_hypot / $prev_max;
    # my $max_hypot3 = Math::BaseCnv::cnv($max_hypot,10,3);
    #   print "  max h= $max_hypot  [$max_hypot3]  at $max_pos  factor $factor\n";
    #   # my $calc = 4 * 3**($level*.9) * 4**($level*.1);
    #   # print "    cf $calc\n";
    # }
    $prev_min = $min_hypot;
    $prev_max = $max_hypot;
  }
  exit 0;
}

{
  # triplications
  require Math::PlanePath::TerdragonCurve;
  require Math::BaseCnv;
  my $path = Math::PlanePath::TerdragonCurve->new;
  my %seen;
  for (my $n = 0; $n < 2000; $n++) {
    my ($x,$y) = $path->n_to_xy($n);
    my $key = "$x,$y";
    push @{$seen{$key}}, $n;
    if (@{$seen{$key}} == 3) {
      my @v3;
      foreach my $v (@{delete $seen{$key}}) {
        my $v3 = Math::BaseCnv::cnv($v,10,3);
        push @v3, $v3;
        printf "%4s %7s\n", $v, $v3;
      }
      my $lenmatch = 0;
      foreach my $i (1 .. length($v3[0])) {
        my $want = substr ($v3[0], -$i);
        if ($v3[1] =~ /$want$/ && $v3[2] =~ /$want$/) {
          next;
        } else {
         $lenmatch = $i-1;
          last;
          last;
        }
      }
      my $zeros = ($v3[0] =~ /(0*)$/ && $1);
      my $lenzeros = length($zeros);
      my $same = ($lenmatch == $lenzeros+1 ? "same" : "diff");
      print "low same $lenmatch zeros $lenzeros   $same\n";
      print "\n";
    }
  }
  exit 0;
}


{
  # turn
  require Math::PlanePath::TerdragonCurve;
  my $path = Math::PlanePath::TerdragonCurve->new;

  my $n = $path->n_start;
  my ($n0_x, $n0_y) = $path->n_to_xy ($n);
  $n++;
  my ($prev_x, $prev_y) = $path->n_to_xy ($n);
  my ($prev_dx, $prev_dy) = ($prev_x - $n0_x, $prev_y - $n0_y);
  my $prev_dir = dxdy_to_dir ($prev_dx, $prev_dy);
  $n++;

  my $pow = 3;
  for ( ; $n < 128; $n++) {
    my ($x, $y) = $path->n_to_xy ($n);
    my $dx = ($x - $prev_x);
    my $dy = ($y - $prev_y);
    my $dir = dxdy_to_dir ($dx, $dy);
    my $turn = ($dir - $prev_dir) % 3;

    $prev_dir = $dir;
    ($prev_x,$prev_y) = ($x,$y);

    print "$turn";
    if ($n-1 == $pow) {
      $pow *= 3;
      print "\n";
    }
  }
  print "\n";
  exit 0;
}


# per KochCurve.t
sub dxdy_to_dir {
  my ($dx,$dy) = @_;
  if ($dy == 0) {
    if ($dx == 2) { return 0/2; }
    # if ($dx == -2) { return 3; }
  }
  if ($dy == 1) {
    # if ($dx == 1) { return 1; }
    if ($dx == -1) { return 2/2; }
  }
  if ($dy == -1) {
    # if ($dx == 1) { return 5; }
    if ($dx == -1) { return 4/2; }
  }
  die "unrecognised $dx,$dy";
}

sub digit_above_low_ones {
  my ($n) = @_;
  if ($n == 0) {
    return 0;
  }
  while (($n % 3) == 1) {
    $n = int($n/3);
  }
  return ($n % 3);
}
sub digit_above_low_twos {
  my ($n) = @_;
  if ($n == 0) {
    return 0;
  }
  while (($n % 3) == 2) {
    $n = int($n/3);
  }
  return ($n % 3);
}

sub digit_above_lowest_zero {
  my ($n) = @_;
  for (;;) {
    if (($n % 3) == 0) {
      last;
    }
    $n = int($n/3);
  }
  $n = int($n/3);
  return ($n % 3);
}
sub digit_above_lowest_one {
  my ($n) = @_;
  for (;;) {
    if (! $n || ($n % 3) != 0) {
      last;
    }
    $n = int($n/3);
  }
  $n = int($n/3);
  return ($n % 3);
}
sub digit_above_lowest_two {
  my ($n) = @_;
  for (;;) {
    if (! $n || ($n % 3) != 0) {
      last;
    }
    $n = int($n/3);
  }
  $n = int($n/3);
  return ($n % 3);
}

