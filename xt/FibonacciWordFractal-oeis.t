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
use Test;
BEGIN { plan tests => 2 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::FibonacciWordFractal;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path  = Math::PlanePath::FibonacciWordFractal->new;

sub numeq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  while (@$a1 && @$a2) {
    if ($a1->[0] != $a2->[0]) {
      return 0;
    }
    shift @$a1;
    shift @$a2;
  }
  return (@$a1 == @$a2);
}

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
{
  my $anum = 'A003849';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");
    # $#$bvalues = 50; # shorten for testing ...
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      push @got, (xy_is_straight($path->n_to_xy($n-1),
                                 $path->n_to_xy($n),
                                 $path->n_to_xy($n+1))
                  ? 1 : 0);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - 0/1 Fibonacci word");
}

#------------------------------------------------------------------------------
# A156596 - turns 0=straight,1=right,2=left
{
  my $anum = 'A156596';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");
    # $#$bvalues = 50; # shorten for testing ...
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      push @got, xy_turn_021($path->n_to_xy($n-1),
                             $path->n_to_xy($n),
                             $path->n_to_xy($n+1));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - 0,1,2 turns");
}

#------------------------------------------------------------------------------

exit 0;
