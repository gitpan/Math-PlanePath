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


# Usage: perl numbers.pl CLASS...
#        perl numbers.pl all
#
# Print the given path CLASS or CLASSes as N numbers in a grid.  Eg.
#
#     perl numbers.pl SquareSpiral DiamondSpiral
#
# Parameters to the class can be given as
#
#     perl numbers.pl SquareSpiral,wider=4
#
# With option "all" print all classes and a selection of their parameters
# (per the table in the code below),
#
#     perl numbers.pl all
#
# See square-numbers.pl for a simpler program designed just for the
# SquareSpiral.  The code here tries to adapt itself to the tty width and
# stops when the width of the numbers to be displayed would be wider than
# the tty.
#
# Stopping when N goes outside the tty width means that just the first say
# 99 or so N values will be shown.  There's quite likely other bigger N
# within the X,Y grid region, but these first few N show how the path
# begins, without clogging up the output.
#
# The origin 0,0 is kept in the middle of the output, horizontally, to help
# see how much is on each side and to make multiple paths printed line up
# such as the "all" option.  Vertically only as many rows as necessary are
# printed.
#
# Paths with fractional X,Y positions like SacksSpiral or VogelFloret get
# rounded to character positions.  There's some hard-coded fudge factors to
# try to make them come out nicely.
#
# When an X,Y position is visited more than once, such as the DragonCurve or
# when rounding means that happens for a few initial points such as
# KochSquareflakes, the two N's are shown with a comma like "9,24".
#

use 5.004;
use strict;
use POSIX ();
use List::Util 'min', 'max';

my $width = 79;
my $height = 23;

# use Term::Size if available
# chars() can return 0 for unknown size
if (eval { require Term::Size }) {
  my ($term_width, $term_height) = Term::Size::chars();
  if ($term_width)  { $width = $term_width - 1; }
  if ($term_height) { $height = $term_height - 1; }
}

if (! @ARGV) {
  push @ARGV, 'HexSpiral';  # default class to print if no args
}

my @all_classes = ('SquareSpiral',
                   'SquareSpiral,wider=9',
                   'DiamondSpiral',
                   'PentSpiral',
                   'PentSpiralSkewed',
                   'HexSpiral',
                   'HexSpiral,wider=3',
                   'HexSpiralSkewed',
                   'HexSpiralSkewed,wider=5',
                   'HeptSpiralSkewed',
                   'OctagramSpiral',

                   'PyramidSpiral',
                   'PyramidRows',
                   'PyramidRows,step=5',
                   'PyramidSides',
                   'CellularRule54',
                   'CellularRule190',
                   'CellularRule190,mirror=1',
                   'TriangleSpiral',
                   'TriangleSpiralSkewed',

                   'Diagonals',
                   'DiagonalsAlternating',
                   'Staircase',
                   'StaircaseAlternating',
                   'Corner',
                   'Corner,wider=5',
                   'KnightSpiral',

                   'SquareArms',
                   'DiamondArms',
                   'HexArms',
                   'GreekKeySpiral',
                   'AztecDiamondRings',
                   'MPeaks',

                   'SacksSpiral',
                   'VogelFloret',
                   'TheodorusSpiral',
                   'MultipleRings',
                   'MultipleRings,step=14',
                   'PixelRings',
                   'Hypot',
                   'HypotOctant',
                   'TriangularHypot',

                   'Rows',
                   'Columns',
                   'UlamWarburton',
                   'UlamWarburtonQuarter',

                   'PeanoCurve',
                   'PeanoCurve,radix=5',
                   'HilbertCurve',
                   'HilbertSpiral',
                   'ZOrderCurve',
                   'ZOrderCurve,radix=5',
                   'WunderlichMeander',
                   'BetaOmega',
                   'KochelCurve',
                   'CincoCurve',
                   'ImaginaryBase',
                   'ImaginaryBase,radix=5',
                   'SquareReplicate',
                   'CornerReplicate',
                   'LTiling',
                   'LTiling,L_fill=ends',
                   'LTiling,L_fill=all',
                   'DigitGroups',
                   'FibonacciWordFractal',

                   'Flowsnake',
                   'Flowsnake,arms=3',
                   'FlowsnakeCentres',
                   'FlowsnakeCentres,arms=3',
                   'GosperReplicate',
                   'GosperIslands',
                   'GosperSide',

                   'QuintetCurve',
                   'QuintetCurve,arms=4',
                   'QuintetCentres',
                   'QuintetReplicate',

                   'KochCurve',
                   'KochPeaks',
                   'KochSnowflakes',
                   'KochSquareflakes',
                   'KochSquareflakes,inward=1',
                   'QuadricCurve',
                   'QuadricIslands',

                   'SierpinskiCurve',
                   'HIndexing',

                   'SierpinskiTriangle',
                   'SierpinskiArrowhead',
                   'SierpinskiArrowheadCentres',
                   'DragonCurve',
                   'DragonCurve,arms=4',
                   'DragonRounded',
                   'DragonRounded,arms=4',
                   'DragonMidpoint',
                   'DragonMidpoint,arms=2',
                   'DragonMidpoint,arms=3',
                   'DragonMidpoint,arms=4',
                   'ComplexMinus',
                   'ComplexMinus,realpart=2',

                   'PythagoreanTree,tree_type=UAD',
                   'PythagoreanTree,tree_type=UAD,coordinates=PQ',
                   'PythagoreanTree,tree_type=FB',
                   'PythagoreanTree,tree_type=FB,coordinates=PQ',

                   'DiagonalRationals',
                   'CoprimeColumns',
                   'RationalsTree,tree_type=SB',
                   'RationalsTree,tree_type=CW',
                   'RationalsTree,tree_type=AYT',
                   'RationalsTree,tree_type=Bird',
                   'RationalsTree,tree_type=Drib',

                   'DivisibleColumns',
                   'DivisibleColumns,divisor_type=proper',
                  );
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
  ($class, my @parameters) = split /\s*,\s*/, $class;

  $class =~ /^[a-z_][:a-z_0-9]*$/i or die "Bad class name: $class";
  eval "require $class" or die $@;

  @parameters = map { /(.*?)=(.*)/ or die "Missing value for parameter \"$_\"";
                      $1,$2 } @parameters;

  my %rows;
  my $x_min = 0;
  my $x_max = 0;
  my $y_min = 0;
  my $y_max = 0;
  my $cellwidth = 1;

  my $path = $class->new (width  => POSIX::ceil ($width / 4),
                          height => POSIX::ceil ($height / 2),
                          @parameters);
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
    if ($cell) { $cell .= ','; }
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
