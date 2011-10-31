#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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
use Smart::Comments;

{
  my @xend = (0,0,1);
  my @yend = (0,1,1);
  my $f0 = 1;
  my $f1 = 2;
  my $level = 1;
  my $transpose = 0;
  my $rot = 0;

  ### at: "$xend[-1],$xend[-1] for $f1"

  foreach (1 .. 20) {
    ($f1,$f0) = ($f1+$f0,$f1);
    my $six = $level % 6;
    $transpose ^= 1;

    my ($x,$y);
    if (($level % 6) == 0) {
      $x = $yend[-2];     # T
      $y = $xend[-2];
    } elsif (($level % 6) == 1) {
      $x = $yend[-2];      # -90
      $y = - $xend[-2];
    } elsif (($level % 6) == 2) {
      $x = $xend[-2];     # T -90
      $y = - $yend[-2];

    } elsif (($level % 6) == 3) {
      ### T
      $x = $yend[-2];     # T
      $y = $xend[-2];
    } elsif (($level % 6) == 4) {
      $x = - $yend[-2];     # +90
      $y = $xend[-2];
    } elsif (($level % 6) == 5) {
      $x = - $xend[-2];     # T +90
      $y = $yend[-2];
    }

    push @xend, $xend[-1] + $x;
    push @yend, $yend[-1] + $y;
    ### new: ($level%6)." add $x,$y for $xend[-1],$yend[-1]  for $f1"
    $level++;
  }
  exit 0;
}

{
  my @xend = (0, 1);
  my @yend = (1, 1);
  my $f0 = 1;
  my $f1 = 2;

  foreach (1 .. 10) {
    {
      ($f1,$f0) = ($f1+$f0,$f1);
      my ($nx,$ny) = ($xend[-1] + $yend[-2], $yend[-1] + $xend[-2]); # T
      push @xend, $nx;
      push @yend, $ny;
      ### new 1: "$nx, $ny    for $f1"
    }

    {
      ($f1,$f0) = ($f1+$f0,$f1);
      my ($nx,$ny) = ($xend[-1] + $xend[-2], $yend[-1] - $yend[-2]); # T ...
      push @xend, $nx;
      push @yend, $ny;
      ### new 2: "$nx, $ny    for $f1"
    }

    {
      ($f1,$f0) = ($f1+$f0,$f1);
      my ($nx,$ny) = ($xend[-1] + $yend[-2], $yend[-1] + $xend[-2]); # T
      push @xend, $nx;
      push @yend, $ny;
      ### new 3: "$nx, $ny    for $f1"
    }

    {
      ($f1,$f0) = ($f1+$f0,$f1);
      my ($nx,$ny) = ($xend[-1] + $yend[-2], $yend[-1] + $xend[-2]);  # T
      push @xend, $nx;
      push @yend, $ny;
      ### new 1b: "$nx, $ny    for $f1"
    }

    {
      ($f1,$f0) = ($f1+$f0,$f1);
      my ($nx,$ny) = ($xend[-1] - $xend[-2], $yend[-1] + $yend[-2]); # T +90
      push @xend, $nx;
      push @yend, $ny;
      ### new 2b: "$nx, $ny    for $f1"
    }

    {
      ($f1,$f0) = ($f1+$f0,$f1);
      my ($nx,$ny) = ($xend[-1] + $yend[-2], $yend[-1] + $xend[-2]); # T
      push @xend, $nx;
      push @yend, $ny;
      ### new 1c: "$nx, $ny    for $f1"
    }

    {
      ($f1,$f0) = ($f1+$f0,$f1);
      my ($nx,$ny) = ($xend[-1] + $yend[-2], $yend[-1] - $xend[-2]);  # rot -90
      push @xend, $nx;
      push @yend, $ny;
      ### new 2c: "$nx, $ny    for $f1"
    }

  }
  exit 0;
}
