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


# Usage: perl hilbert-lines.pl
#
# This is a bit of fun printing the HilbertCurve path in ascii.  It follows
# the terminal width if you've got Term::Size, otherwise 79x23.
#
# Enough of the curve is drawn to fill the whole output size.  You could
# instead stop at say
#
#     $n_hi = 2**6;
#
# to see just one square portion of the curve.
#
# The $scale variable spaces out the points.  3 apart is quite good, or
# tighten it up to 2 to fit more on the screen.
#
# The output has Y increasing down the screen.  Taking the Y's in reverse
# order in the final output could show it going up the screen.
#

use 5.004;
use strict;
use POSIX ();
use Math::PlanePath::HilbertCurve;

# uncomment this to run the ### lines
use Smart::Comments;

my $width = 79;
my $height = 23;
my $scale = 3;

if (eval { require Term::Size }) {
  my ($w, $h) = Term::Size::chars();
  if ($w) { $width = $w - 1; }
  if ($h) { $height = $h - 1; }
}

my $x = 0;
my $y = 0;
my %grid;
sub plot {
  my ($char) = @_;
  if ($x < $width && $y < $height) {
    $grid{$x}{$y} = $char;
  }
}
plot('+');

my $path = Math::PlanePath::HilbertCurve->new;
my $pwidth = int($width / $scale) + 1;
my $pheight = int($height / $scale) + 1;
my ($n_lo, $n_hi) = $path->rect_to_n_range (0,0, $pwidth,$pheight);

foreach my $n (1 .. $n_hi) {

  my ($next_x, $next_y) = $path->n_to_xy ($n);
  $next_x *= $scale;
  $next_y *= $scale;

  while ($x > $next_x) {  # left
    $x--;
    plot ('-');
  }
  while ($x < $next_x) {  # right
    $x++;
    plot ('-');
  }

  while ($y > $next_y) {  # up
    $y--;
    plot ('|');
  }
  while ($y < $next_y) {  # down
    $y++;
    plot ('|');
  }

  plot ('+');
}

foreach my $y (0 .. $height-1) {
  foreach my $x (0 .. $width-1) {
    print $grid{$x}{$y} || ' ';
  }
  print "\n";
}

exit 0;
