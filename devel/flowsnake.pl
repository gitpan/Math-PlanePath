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
  require Math::PlanePath::GosperIslands;
  my $path = Math::PlanePath::GosperIslands->new;
  foreach my $level (0 .. 20) {
    my $n_start = 3**($level+1) - 2;
    my $n_end = 3**($level+2) - 2 - 1;
    my ($prev_x) = $path->n_to_xy($n_start);
    foreach my $n ($n_start .. $n_end) {
      my ($x,$y) = $path->n_to_xy($n);

      # if ($y == 0 && $x > 0) {
      #   print "level $level  x=$x y=$y n=$n\n";
      # }

      if (($prev_x>0) != ($x>0) && $y > 0) {
        print "level $level  x=$x y=$y n=$n\n";
      }
      $prev_x = $x;
    }
    print "\n";
  }
  exit 0;
}

{
  require Math::PlanePath::MathImageGosperIslandSide;
  my $path = Math::PlanePath::MathImageGosperIslandSide->new;
  my $prev_angle = 0;
  my $prev_dist = 0;
  foreach my $level (0 .. 20) {
    my ($x,$y) = $path->n_to_xy(3**$level);
    $y *= sqrt(3);
    my $angle = atan2($y,$x);
    $angle *= 180/M_PI();
    if ($angle < 0) { $angle += 360; }
    my $delta_angle = $angle - $prev_angle;
    my $dist = log(hypot($x,$y));
    my $delta_dist = $dist - $prev_dist;
    printf "%d  %d,%d   %.1f  %+.3f   %.3f %+.5f\n",
      $level, $x, $y, $angle, $delta_angle,
        $dist, $delta_dist;

    $prev_angle = $angle;
    $prev_dist = $dist;
  }
  exit 0;
}

sub hij_to_xy {
  my ($h, $i, $j) = @_;
  return ($h*2 + $i - $j,
          $i+$j);
}

{
  # y<0 at n=8598  x=-79,y=-1
  require App::MathImage::PlanePath::Flowsnake;
  my $path = App::MathImage::PlanePath::Flowsnake->new;
  for (my $n = 3; ; $n++) {
    my ($x,$y) = $path->n_to_xy($n);
    if ($y == 0) {
      print "zero n=$n  $x,$y\n";
    }
    if ($y < 0) {
      print "yneg n=$n  $x,$y\n";
      exit 0;
    }
    # if ($y < 0 && $x >= 0) {
    #   print "yneg n=$n  $x,$y\n";
    #   exit 0;
    # }
  }
  exit 0;
}

{
  {
    my $sh = 1;
    my $si = 0;
    my $sj = 0;
    my $n = 1;
    foreach my $level (1 .. 20) {
      $n *= 7;
      ($sh, $si, $sj) = (2*$sh - $sj,
                         2*$si + $sh,
                         2*$sj + $si);
      my ($x, $y) = hij_to_xy($sh,$si,$sj);
      $n = sprintf ("%f",$n);
      print "$level $n  $sh,$si,$sj  $x,$y\n";
    }
  }
  exit 0;
}


our $level;

my $n = 0;
my $x = 0;
my $y = 0;

my %seen;
my @row;
my $x_offset = 8;
my $dir = 0;

sub step {
  $dir %= 6;
  print "$n  $x, $y   dir=$dir\n";
  my $key = "$x,$y";
  if (defined $seen{$key}) {
    print "repeat   $x, $y  from $seen{$key}\n";
  }
  $seen{"$x,$y"} = $n;
  if ($y >= 0) {
    $row[$y]->[$x+$x_offset] = $n;
  }

  if ($dir == 0) { $x += 2; }
  elsif ($dir == 1) { $x++, $y++; }
  elsif ($dir == 2) { $x--, $y++; }
  elsif ($dir == 3) { $x -= 2; }
  elsif ($dir == 4) { $x--, $y--; }
  elsif ($dir == 5) { $x++, $y--; }
  else { die; }
  $n++;
}

sub forward {
  if ($level == 1) {
    step ();
    return;
  }
  local $level = $level-1;
  forward(); $dir++;           # 0
  backward(); $dir += 2;       # 1
  backward(); $dir--;          # 2
  forward(); $dir -= 2;           # 3
  forward();                   # 4
  forward();  $dir--;                 # 5
  backward(); $dir++;          # 6
}

sub backward {
  my ($dir) = @_;
  if ($level == 1) {
    step ();
    return;
  }
  print "backward\n";
  local $level = $level-1;

  $dir += 2;
  forward();
  forward();
  $dir--;                 # 5
  forward();
  $dir--;                 # 5
  forward();
  $dir--;                 # 5
  backward();
  $dir--;                 # 5
  backward();
  $dir--;                 # 5
  forward();
  $dir--;                 # 5
}

$level = 3;
forward (2);


foreach my $y (reverse 0 .. $#row) {
  my $aref = $row[$y];
  foreach my $x (0 .. $#$aref) {
    printf ('%*s', 3, (defined $aref->[$x] ? $aref->[$x] : ''));
  }
  print "\n";
}
