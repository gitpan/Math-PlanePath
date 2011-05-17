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
# see how much is on each side, and to make multiple paths printed line up,
# such as the "all" option.  Vertically only as many rows as necessary are
# printed.
#


use 5.004;
use strict;
use POSIX ();
use List::Util 'min', 'max';

my $width = 79;
my $height = 23;

# use Term::Size for tty size, if available
# chars() can return 0 for unknown size
if (eval { require Term::Size }) {
  my ($ttywidth, $ttyheight) = Term::Size::chars();
  if ($ttywidth)  { $width = $ttywidth - 1; }
  if ($ttyheight) { $height = $ttyheight - 1; }
}

if (! @ARGV) {
  push @ARGV, 'HexSpiral';  # default class to print if no args
}

my @all_classes = (qw(SquareSpiral
                      DiamondSpiral
                      PentSpiral
                      PentSpiralSkewed
                      HexSpiral
                      HexSpiralSkewed
                      HeptSpiralSkewed
                      OctagramSpiral

                      PyramidSpiral
                      PyramidRows
                      PyramidSides
                      TriangleSpiral
                      TriangleSpiralSkewed

                      Diagonals
                      Staircase
                      Corner
                      KnightSpiral
                      GreekKeySpiral

                      SacksSpiral
                      VogelFloret
                      TheodorusSpiral
                      MultipleRings
                      PixelRings
                      Hypot
                      HypotOctant
                      PythagoreanTree

                      Rows
                      Columns
                      HilbertCurve
                      PeanoCurve
                      ZOrderCurve));
# expand arg "all" to full list
@ARGV = map {$_ eq 'all' ? @all_classes : $_} @ARGV;

my $separator = '';
foreach my $class (@ARGV) {
  print $separator;
  $separator = "\n";

  if (@ARGV > 1) {
    # title if more than one class requested, including "all" option
    print "$class\n\n";
  }
  print_class ($class);
}

sub print_class {
  my ($class) = @_;

  unless ($class =~ /::/) {
    $class = "Math::PlanePath::$class";
  }
  $class =~ /^[a-z_][:a-z_0-9]*$/i or die "Bad class name: $class";
  eval "require $class" or die $@;

  my %rows;
  my $x_min = 0;
  my $x_max = 0;
  my $y_min = 0;
  my $y_max = 0;
  my $cellwidth = 1;

  my $path = $class->new (width  => POSIX::ceil ($width / 4),
                          height => POSIX::ceil ($height / 2));
  my $x_limit_lo;
  my $x_limit_hi;
  if ($path->x_negative) {
    my $w_cells = int ($width / $cellwidth);
    my $half = int(($w_cells - 1) / 2);
    $x_limit_lo = -$half;
    $x_limit_hi = +$half;
  } else {
    my $w_cells = int ($width / $cellwidth);
    $x_limit_lo = 0;
    $x_limit_hi = $w_cells - 1;
  }

  my $y_limit_lo = 0;
  my $y_limit_hi = $height-1;
  if ($path->y_negative) {
    my $half = int(($height-1)/2);
    $y_limit_lo = -$half;
    $y_limit_hi = +$half;
  }

  foreach my $n ($path->n_start .. 999) {
    my ($x, $y) = $path->n_to_xy ($n);

    # stretch these out for better resolution
    if ($class =~ /Sacks/) { $x *= 1.5; $y *= 2; }
    if ($class =~ /Archimedean/) { $x *= 2; $y *= 3; }
    if ($class =~ /Theodorus|MultipleRings/) { $x *= 2; $y *= 2; }
    if ($class =~ /Vogel/) { $x *= 2; $y *= 3.5; }

    # nearest integers
    $x = POSIX::floor ($x + 0.5);
    $y = POSIX::floor ($y + 0.5);

    my $cell = $rows{$x}{$y};
    if ($cell) { $cell .= '/'; }
    $cell .= $n;
    my $new_cellwidth = max ($cellwidth, length($cell) + 1);

    my $new_x_limit_lo;
    my $new_x_limit_hi;
    if ($path->x_negative) {
      my $w_cells = int ($width / $new_cellwidth);
      my $half = int(($w_cells - 1) / 2);
      $new_x_limit_lo = -$half;
      $new_x_limit_hi = +$half;
    } else {
      my $w_cells = int ($width / $new_cellwidth);
      $new_x_limit_lo = 0;
      $new_x_limit_hi = $w_cells - 1;
    }

    my $new_x_min = min($x_min, $x);
    my $new_x_max = max($x_max, $x);
    my $new_y_min = min($y_min, $y);
    my $new_y_max = max($y_max, $y);
    if ($new_x_min < $new_x_limit_lo
        || $new_x_max > $new_x_limit_hi
        || $new_y_min < $y_limit_lo
        || $new_y_max > $y_limit_hi) {
      last;
    }

    $rows{$x}{$y} = $cell;
    $cellwidth = $new_cellwidth;
    $x_limit_lo = $new_x_limit_lo;
    $x_limit_hi = $new_x_limit_hi;
    $x_min = $new_x_min;
    $x_max = $new_x_max;
    $y_min = $new_y_min;
    $y_max = $new_y_max;
  }

  foreach my $y (reverse $y_min .. $y_max) {
    foreach my $x ($x_limit_lo .. $x_limit_hi) {
      my $cell = $rows{$x}{$y};
      if (! defined $cell) { $cell = ''; }
      printf ('%*s', $cellwidth, $cell);
    }
    print "\n";
  }
}

exit 0;
