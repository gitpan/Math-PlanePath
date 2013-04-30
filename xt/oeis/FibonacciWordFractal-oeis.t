#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012, 2013 Kevin Ryde

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
use Test;
plan tests => 2;

use lib 't','xt';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings(); }
use MyOEIS;

use Math::PlanePath::FibonacciWordFractal;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path  = Math::PlanePath::FibonacciWordFractal->new;

# return true if the three X,Y's are on a straight line ... but assumed to
# be equal distance steps
sub xy_is_straight {
  my ($prev_x,$prev_y, $x,$y, $next_x,$next_y) = @_;
  return (($x - $prev_x) == ($next_x - $x)
          && ($y - $prev_y) == ($next_y - $y));
}

# with Y reckoned increasing upwards
sub dxdy_to_direction {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 0; }  # east
  if ($dx < 0) { return 2; }  # west
  if ($dy > 0) { return 1; }  # north
  if ($dy < 0) { return 3; }  # south
}

# return 0 if X,Y's are straight, 2 if left, 1 if right
sub xy_turn_021 {
  my ($prev_x,$prev_y, $x,$y, $next_x,$next_y) = @_;

  my $prev_dx = $x - $prev_x;
  my $prev_dy = $y - $prev_y;
  my $dx = $next_x - $x;
  my $dy = $next_y - $y;

  my $prev_dir = dxdy_to_direction ($prev_dx, $prev_dy);
  my $dir = dxdy_to_direction ($dx, $dy);
  my $turn = ($dir - $prev_dir) % 4;

  if ($turn == 0) {
    return 0;  # straight
  }
  if ($turn == 1) {
    return 2;  # left (anti-clockwise)
  }
  if ($turn == 3) {
    return 1;  # right (clockwise)
  }
  die "Oops, unrecognised turn $turn";
}

#------------------------------------------------------------------------------
# A003849 - Fibonacci word 0/1

MyOEIS::compare_values
  (anum => 'A003849',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $path->n_start + 1; @got < $count; $n++) {
       push @got, (xy_is_straight($path->n_to_xy($n-1),
                                  $path->n_to_xy($n),
                                  $path->n_to_xy($n+1))
                   ? 1 : 0);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A156596 - turns 0=straight,1=right,2=left

MyOEIS::compare_values
  (anum => 'A156596',
   func => sub {
     my ($count) = @_;
     my @got;
     for (my $n = $path->n_start + 1; @got < $count; $n++) {
       push @got, xy_turn_021($path->n_to_xy($n-1),
                              $path->n_to_xy($n),
                              $path->n_to_xy($n+1));
     }
     return \@got;
   });

#------------------------------------------------------------------------------

exit 0;
