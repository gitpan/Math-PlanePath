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

use 5.004;
use strict;
use Test;
BEGIN { plan tests => 6 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::DragonCurve;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $dragon  = Math::PlanePath::DragonCurve->new;

sub numeq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  while (@$a1 && @$a2) {
    if ($a1->[0] ne $a2->[0]) {
      return 0;
    }
    shift @$a1;
    shift @$a2;
  }
  return (@$a1 == @$a2);
}

sub xy_is_straight {
  my ($prev_x,$prev_y, $x,$y, $next_x,$next_y) = @_;
  return (($x - $prev_x) == ($next_x - $x)
          && ($y - $prev_y) == ($next_y - $y));
}

#------------------------------------------------------------------------------
# A126937 -- points numbered as SquareSpiral

{
  my $anum = 'A126937';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");
    require Math::PlanePath::SquareSpiral;
    my $square  = Math::PlanePath::SquareSpiral->new;

    for (my $n = $dragon->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $dragon->n_to_xy ($n);
      my $square_n = $square->xy_to_n ($x, -$y) - 1;
      push @got, $square_n;
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction");
}


#------------------------------------------------------------------------------
# A005811 -- total rotation

# with Y reckoned increasing upwards
sub dxdy_to_direction {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 0; }  # east
  if ($dx < 0) { return 2; }  # west
  if ($dy > 0) { return 1; }  # north
  if ($dy < 0) { return 3; }  # south
}

{
  my $anum = 'A005811';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach (@$bvalues) { $_ %= 4; }
    # @$bvalues = (@{$bvalues}[0..10]);
    my ($prev_x, $prev_y) = $dragon->n_to_xy (0);
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $dragon->n_to_xy ($n);
      my $dx = $x - $prev_x;
      my $dy = $y - $prev_y;
      ### $x
      ### $y
      ### $dx
      ### $dy
      ### dir: dxdy_to_direction($dy,$dx)
      push @got, dxdy_to_direction ($dx, $dy);
      ($prev_x,$prev_y) = ($x,$y);
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
    ### bvalues: @$bvalues
    ### @got
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- total rotation");
}


#------------------------------------------------------------------------------
# A014577 -- relative direction 0=left, 1=right, starting from 1
#
# cf A082410 maybe same as A014577 with an extra initial 0
#
# cf A059125 is almost but not quite the same, the 8,24,or some such entries
# differ

{
  my $anum = 'A014577';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my ($n0_x, $n0_y) = $dragon->n_to_xy (0);
    my ($prev_x, $prev_y) = $dragon->n_to_xy (1);
    my ($prev_dx, $prev_dy) = ($prev_x - $n0_x, $prev_y - $n0_y);
    foreach my $n (2 .. @$bvalues + 1) {
      my ($x, $y) = $dragon->n_to_xy ($n);
      my $dx = ($x - $prev_x);
      my $dy = ($y - $prev_y);

      if ($prev_dx) {
        if ($dy == $prev_dx) {
          push @got, 1;  # right
        } else {
          push @got, 0;  # left
        }
      } else {
        if ($dx == $prev_dy) {
          push @got, 0;  # left
        } else {
          push @got, 1;  # right
        }
      }
      ### $n
      ### $prev_dx
      ### $prev_dy
      ### $dx
      ### $dy
      ### is: "$got[-1]   at idx $#got"

      ($prev_dx,$prev_dy) = ($dx,$dy);
      ($prev_x,$prev_y) = ($x,$y);
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction");
}


#------------------------------------------------------------------------------
# A014707 -- relative direction 1=left, 0=right, starting from 1

{
  my $anum = 'A014707';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my ($n0_x, $n0_y) = $dragon->n_to_xy (0);
    my ($prev_x, $prev_y) = $dragon->n_to_xy (1);
    my ($prev_dx, $prev_dy) = ($prev_x - $n0_x, $prev_y - $n0_y);
    foreach my $n (2 .. @$bvalues + 1) {
      my ($x, $y) = $dragon->n_to_xy ($n);
      my $dx = ($x - $prev_x);
      my $dy = ($y - $prev_y);

      if ($prev_dx) {
        if ($dy == $prev_dx) {
          push @got, 0;  # right
        } else {
          push @got, 1;  # left
        }
      } else {
        if ($dx == $prev_dy) {
          push @got, 1;  # left
        } else {
          push @got, 0;  # right
        }
      }
      ### $n
      ### $prev_dx
      ### $prev_dy
      ### $dx
      ### $dy
      ### is: "$got[-1]   at idx $#got"

      ($prev_dx,$prev_dy) = ($dx,$dy);
      ($prev_x,$prev_y) = ($x,$y);
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction");
}


#------------------------------------------------------------------------------
# A014709 -- relative direction 2=left, 1=right, starting from 1

{
  my $anum = 'A014709';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my ($n0_x, $n0_y) = $dragon->n_to_xy (0);
    my ($prev_x, $prev_y) = $dragon->n_to_xy (1);
    my ($prev_dx, $prev_dy) = ($prev_x - $n0_x, $prev_y - $n0_y);
    foreach my $n (2 .. @$bvalues + 1) {
      my ($x, $y) = $dragon->n_to_xy ($n);
      my $dx = ($x - $prev_x);
      my $dy = ($y - $prev_y);

      if ($prev_dx) {
        if ($dy == $prev_dx) {
          push @got, 1;  # right
        } else {
          push @got, 2;  # left
        }
      } else {
        if ($dx == $prev_dy) {
          push @got, 2;  # left
        } else {
          push @got, 1;  # right
        }
      }
      ### $n
      ### $prev_dx
      ### $prev_dy
      ### $dx
      ### $dy
      ### is: "$got[-1]   at idx $#got"

      ($prev_dx,$prev_dy) = ($dx,$dy);
      ($prev_x,$prev_y) = ($x,$y);
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction");
}


#------------------------------------------------------------------------------
# A014710 -- relative direction 1=left, 2=right, starting from 1

{
  my $anum = 'A014710';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my ($n0_x, $n0_y) = $dragon->n_to_xy (0);
    my ($prev_x, $prev_y) = $dragon->n_to_xy (1);
    my ($prev_dx, $prev_dy) = ($prev_x - $n0_x, $prev_y - $n0_y);
    foreach my $n (2 .. @$bvalues + 1) {
      my ($x, $y) = $dragon->n_to_xy ($n);
      my $dx = ($x - $prev_x);
      my $dy = ($y - $prev_y);

      if ($prev_dx) {
        if ($dy == $prev_dx) {
          push @got, 2;  # right
        } else {
          push @got, 1;  # left
        }
      } else {
        if ($dx == $prev_dy) {
          push @got, 1;  # left
        } else {
          push @got, 2;  # right
        }
      }
      ### $n
      ### $prev_dx
      ### $prev_dy
      ### $dx
      ### $dy
      ### is: "$got[-1]   at idx $#got"

      ($prev_dx,$prev_dy) = ($dx,$dy);
      ($prev_x,$prev_y) = ($x,$y);
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction");
}


#------------------------------------------------------------------------------
exit 0;
