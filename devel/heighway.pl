#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

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


# Usage: perl numbers.pl [CLASS]
#        perl numbers.pl all
#
# Print the given path class in a grid, or with option "all" print all
# classes.
#
# See square-numbers.pl for a simpler program designed just for the
# SquareSpiral.  The code here tries to adapt itself to the tty width and
# stops when the width of the numbers to be displayed would be wider than
# the tty.
#
# The origin 0,0 is kept in the middle of the display, horizontally, to help
# see how much is on each side, and to make the "all" line up.  But
# vertically only as many rows as necessary are printed.
#


use 5.004;
use strict;
use warnings;
use POSIX ();
use List::Util 'min', 'max';

# uncomment this to run the ### lines
use Smart::Comments;

my $width = 79;
my $height = 23;

sub turn_right {
  my ($n) = @_;
  until ($n & 1) {
    $n >>= 1;
  }
  return (($n >> 1) & 1) ^ 1;
}

{
  my %rows;
  my $x_min = 0;
  my $x_max = 0;
  my $y_min = 0;
  my $y_max = 0;
  my $cellwidth = 1;

  my $xd = 1;
  my $yd = 0;
  my $x = 0;
  my $y = 0;
  my $n = 1;
  foreach my $n (1 .. 500) {
    $x += $xd;
    $y += $yd;

    my $cell = $rows{$x}{$y};
    if ($cell) { $cell .= '/'; }
    $cell .= $n;
    $rows{$x}{$y} = $cell;
    $cellwidth = max ($cellwidth, length($cell)+1);
    ### draw: "$x,$y  $cell"

    $x_min = min ($x_min, $x);
    $x_max = max ($x_max, $x);
    $y_min = min ($y_min, $y);
    $y_max = max ($y_max, $y);

    if (turn_right($n)) {
      ### right: "$xd,$yd -> $yd,@{[-$xd]}"
      ($xd,$yd) = ($yd,-$xd);
    } else {
      ### left: "$xd,$yd -> @{[-$yd]},$xd"
      ($xd,$yd) = (-$yd,$xd);
    }
  }

  ### $x_min
  ### $x_max
  ### $y_min
  ### $y_max

  foreach my $y (reverse $y_min .. $y_max) {
    foreach my $x ($x_min .. $x_max) {
      printf ('%*s', $cellwidth, $rows{$x}{$y} || '');
    }
    print "\n";
  }

  exit 0;
}

{
  foreach my $n (1 .. 50) {
    print turn($n),",";
  }
  print "\n";
  exit 0;
}
