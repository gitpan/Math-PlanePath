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


# Usage: perl koch-svg.pl >output.svg
#        perl koch-svg.pl LEVEL >output.svg
#
# Print SVG format graphics to standard output which is a Koch snowflake
# curve of given LEVEL fineness.  The default level is 4.
#
# The range of N values used follows the formulas in the KochSnowflakes
# module docs.
#
# The svg size is a fixed 300x300, but of course the point of svg is that it
# can be resized by a graphics viewer program.

use 5.006;
use strict;
use warnings;
use List::Util 'min';
use Math::PlanePath::KochSnowflakes;

my $path = Math::PlanePath::KochSnowflakes->new;

my $level = $ARGV[0] || 4;
my $width = 300;
my $height = 300;

# use the svg translate() to centre the origin in the viewport, but don't
# use its scale() to shrink the path X,Y coordinates, just in case the
# factor 1/4^level becomes very small
my $xcentre = $width / 2;
my $ycentre = $height / 2;

print <<"HERE";
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
<svg xmlns="http://www.w3.org/2000/svg"
     width="$width" height="$height">
<title>Koch Snowflake level $level</title>
<!-- Generated by koch-svg.pl -->
<g transform="translate($xcentre,$ycentre)">
HERE


my $y_equilateral = sqrt(3);
my $path_width = 2 * 3**$level;
my $path_height = 2 * (2/3) * 3**$level * $y_equilateral;
my $scale = 0.9 * min ($width / $path_width,
                       $height / $path_height);

my $linewidth = 1/$level;

# N range for $level
my $n_lo = 4**$level;
my $n_hi = 4**($level+1) - 1;

my $points = '';
foreach my $n ($n_lo .. $n_hi) {
  my ($x, $y) = $path->n_to_xy($n);
  $x *= $scale;
  $y *= $scale;
  $y *= $y_equilateral;
  $points .= "\n  $x, $y";
}

print <<"HERE"
<polygon fill="none"
         stroke="#FF00FF"
         stroke-width="$linewidth"
         points="$points"/>
</g>
</svg>
HERE
