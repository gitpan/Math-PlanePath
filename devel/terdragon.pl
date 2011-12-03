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

use 5.006;
use strict;
use warnings;
use Math::Libm 'M_PI', 'hypot';



{
  # turn
  require Math::PlanePath::MathImageTerdragonCurve;
  my $path = Math::PlanePath::MathImageTerdragonCurve->new;

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

    my $azeros = digit_above_low_zeros($n-1);
    my $azx = ($azeros == $turn ? '' : '*');

    my $aones = digit_above_low_ones($n-1);
    if ($aones==0) { $aones=1 }
    elsif ($aones==1) { $aones=0 }
    elsif ($aones==2) { $aones=2 }
    my $aox = ($aones == $turn ? '' : '*');

    my $atwos = digit_above_low_twos($n-2);
    if ($atwos==0) { $atwos=1 }
    elsif ($atwos==1) { $atwos=2 }
    elsif ($atwos==2) { $atwos=0 }
    my $atx = ($atwos == $turn ? '' : '*');

    my $lzero = digit_above_lowest_zero($n);
    my $lone = digit_above_lowest_one($n);
    my $ltwo = digit_above_lowest_two($n);
    print "$n  $turn   $aones$aox  $atwos$atx $azeros$azx $lzero $lone $ltwo\n";
  }
  print "\n";
  exit 0;
}
{
  # turn
  require Math::PlanePath::MathImageTerdragonCurve;
  my $path = Math::PlanePath::MathImageTerdragonCurve->new;

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

