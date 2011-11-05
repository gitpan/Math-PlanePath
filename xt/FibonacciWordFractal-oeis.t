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

#------------------------------------------------------------------------------
# A003849 - Fibonacci word 0/1
{
  my $anum = 'A003849';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    $#$bvalues = 50;
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my ($prev_x,$prev_y) = $path->n_to_xy ($n-1);
      my ($x,$y) = $path->n_to_xy ($n);
      my ($next_x,$next_y) = $path->n_to_xy ($n+1);
      my $prev_dx = $x - $prev_x;
      my $prev_dy = $y - $prev_y;
      my $dx = $next_x - $x;
      my $dy = $next_y - $y;
      ### at: "n=$n  $prev_dx,$prev_dy  $dx,$dy"
      my $turn_zero;
      if ($dx == $prev_dx && $dy == $prev_dy) {
        $turn_zero = 1;
      } else {
        $turn_zero = 0;
      }
      push @got, $turn_zero;
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
    $#$bvalues = 50;
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my ($prev_x,$prev_y) = $path->n_to_xy ($n-1);
      my ($x,$y) = $path->n_to_xy ($n);
      my ($next_x,$next_y) = $path->n_to_xy ($n+1);
      my $prev_dx = $x - $prev_x;
      my $prev_dy = $y - $prev_y;
      my $dx = $next_x - $x;
      my $dy = $next_y - $y;
      ### at: "n=$n  $prev_dx,$prev_dy  $dx,$dy"
      my $turn;
      if ($dx == $prev_dx && $dy == $prev_dy) {
        $turn = 0;
      } else {
        # dy/dx > pdy/pdx is turn left
        # dy*pdx > pdy*dx
        if ($dy*$prev_dx > $prev_dy*$dx) {
          $turn = 2;
        } else {
          $turn = 1;
        }
      }
      push @got, $turn;
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
