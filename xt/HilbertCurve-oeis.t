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
BEGIN { plan tests => 25 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::HilbertCurve;
use Math::PlanePath::Diagonals;
use Math::PlanePath::ZOrderCurve;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $hilbert  = Math::PlanePath::HilbertCurve->new;
my $diagonal = Math::PlanePath::Diagonals->new;
my $zorder   = Math::PlanePath::ZOrderCurve->new;

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
# A059252 - Y coord

{
  my $anum = 'A059252';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      push @got, $y;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - Y coord");
}

# A059253 - X coord
{
  my $anum = 'A059253';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      push @got, $x;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - X coord");
}

# A059261 - X+Y
{
  my $anum = 'A059261';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      push @got, $x+$y;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - X+Y");
}

# A059285 - X-Y
{
  my $anum = 'A059285';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      push @got, $x-$y;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - X-Y");
}

# A163547 - X^2+Y^2
{
  my $anum = 'A163547';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      push @got, $x*$x+$y*$y;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - X^2+Y^2");
}

#------------------------------------------------------------------------------
# A163355 - in Z order sequence

{
  my $anum = 'A163355';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $zorder->n_to_xy ($n);
      push @got, $hilbert->xy_to_n ($x, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - ZOrder");
}

# A163356 - inverse
{
  my $anum = 'A163356';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      push @got, $zorder->xy_to_n ($x, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163357 - in diagonal sequence

{
  my $anum = 'A163357';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($y, $x) = $diagonal->n_to_xy ($n);     # transposed, same side
      push @got, $hilbert->xy_to_n ($x, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163358 - inverse
{
  my $anum = 'A163358';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (0 .. $#$bvalues) {
      my ($y, $x) = $hilbert->n_to_xy ($n);        # transposed, same side
      push @got, $diagonal->xy_to_n ($x, $y) - 1;  # 0-based diagonals
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163359 - in diagonal sequence, opp sides

{
  my $anum = 'A163359';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $diagonal->n_to_xy ($n);     # plain, opposite sides
      push @got, $hilbert->xy_to_n ($x, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163360 - inverse
{
  my $anum = 'A163360';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);     # plain, opposite sides
      push @got, $diagonal->xy_to_n ($x, $y) - 1;  # 0-based diagonals
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163361 - diagonal sequence, one based

{
  my $anum = 'A163361';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
  foreach my $n (1 .. @$bvalues) {
    my ($x, $y) = $diagonal->n_to_xy ($n);
    ($x, $y) = ($y, $x);                    # transpose for same side
    push @got, $hilbert->xy_to_n ($x, $y) + 1; # 1-based Hilbert
  }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
numeq_array(\@got, $bvalues),
      1);
}

# A163362 - inverse
{
  my $anum = 'A163362';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      ($x, $y) = ($y, $x);                    # transpose for same side
      push @got, $diagonal->xy_to_n ($x, $y); # 1-based Hilbert
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163363 - diagonal sequence, one based, opp sides

{
  my $anum = 'A163363';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $diagonal->n_to_xy ($n);  # no transpose for opp side
      push @got, $hilbert->xy_to_n ($x, $y) + 1;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163364 - inverse
{
  my $anum = 'A163364';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);  # no transpose for opp side
      push @got, $diagonal->xy_to_n ($x, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163365 - diagonal sums
{
  my $anum = 'A163365';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $d (0 .. $#$bvalues) {
      my $sum = 0;
      foreach my $x (0 .. $d) {
        my $y = $d - $x;
        $sum += $hilbert->xy_to_n ($x, $y);
      }
      push @got, $sum;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - diagonal sums");
}

# A163477 - diagonal sums divided by 4
{
  my $anum = 'A163477';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $d (0 .. $#$bvalues) {
      my $sum = 0;
      foreach my $x (0 .. $d) {
        my $y = $d - $x;
        $sum += $hilbert->xy_to_n ($x, $y);
      }
      push @got, int($sum/4);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - diagonal sums divided by 4");
}

#------------------------------------------------------------------------------
# A163482 -- row at Y=0
{
  my $anum = 'A163482';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $x (0 .. $#$bvalues) {
      push @got, $hilbert->xy_to_n ($x, 0);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- row at Y=0");
}

#------------------------------------------------------------------------------
# A163483 -- column at X=0
{
  my $anum = 'A163483';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $y (0 .. $#$bvalues) {
      push @got, $hilbert->xy_to_n (0, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- column at X=0");
}

#------------------------------------------------------------------------------
# A163538 -- delta X
# first entry is for N=0 no change
{
  my $anum = 'A163538';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my ($prev_x, $prev_y) = (0, 0);
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      my $dx = $x - $prev_x;
      push @got, $dx;
      ($prev_x, $prev_y) = ($x, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- delta X (transpose)");
}

#------------------------------------------------------------------------------
# A163539 -- delta Y
# first entry is for N=0 no change
{
  my $anum = 'A163539';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my ($prev_x, $prev_y) = (0, 0);
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      my $dy = $y - $prev_y;
      push @got, $dy;
      ($prev_x, $prev_y) = ($x, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- delta Y (transpose)");
}

#------------------------------------------------------------------------------
# A163540 -- absolute direction 0=east, 1=south, 2=west, 3=north
# Y coordinates reckoned down the page, so south is Y increasing

{
  my $anum = 'A163540';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my ($prev_x, $prev_y) = $hilbert->n_to_xy (0);
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      my $dx = $x - $prev_x;
      my $dy = $y - $prev_y;
      push @got, MyOEIS::dxdy_to_direction ($dx, $dy);
      ($prev_x,$prev_y) = ($x,$y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- absolute direction");
}

#------------------------------------------------------------------------------
# A163541 -- absolute direction transpose 0=east, 1=south, 2=west, 3=north

{
  my $anum = 'A163541';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my ($prev_x, $prev_y) = $hilbert->n_to_xy (0);
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      my $dx = $x - $prev_x;
      my $dy = $y - $prev_y;
      push @got, MyOEIS::dxdy_to_direction ($dy, $dx);
      ($prev_x,$prev_y) = ($x,$y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- absolute direction transpose");
}

#------------------------------------------------------------------------------
# A163542 -- relative direction 0=ahead, 1=right, 2=left
# Y coordinates reckoned down the page
{
  my $anum = 'A163542';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my ($n0_x, $n0_y) = $hilbert->n_to_xy (0);
    my ($p_x, $p_y) = $hilbert->n_to_xy (1);
    my ($p_dx, $p_dy) = ($p_x - $n0_x, $p_y - $n0_y);
    foreach my $n (2 .. @$bvalues + 1) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      my $dx = ($x - $p_x);
      my $dy = ($y - $p_y);

      if ($p_dx) {
        if ($dx) {
          push @got, 0;  # ahead horizontally
        } elsif ($dy == $p_dx) {
          push @got, 1;  # right
        } else {
          push @got, 2;  # left
        }
      } else {
        # p_dy
        if ($dy) {
          push @got, 0;  # ahead horizontally
        } elsif ($dx == $p_dy) {
          push @got, 2;  # left
        } else {
          push @got, 1;  # right
        }
      }
      ### $n
      ### $p_dx
      ### $p_dy
      ### $dx
      ### $dy
      ### is: "$got[-1]   at idx $#got"

      ($p_dx,$p_dy) = ($dx,$dy);
      ($p_x,$p_y) = ($x,$y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction");
}

#------------------------------------------------------------------------------
# A163543 -- relative direction 0=ahead, 1=right, 2=left
# Y coordinates reckoned down the page

sub transpose {
  my ($x, $y) = @_;
  return ($y, $x);
}
{
  my $anum = 'A163543';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my ($n0_x, $n0_y) = transpose ($hilbert->n_to_xy (0));
    my ($p_x, $p_y) = transpose ($hilbert->n_to_xy (1));
    my ($p_dx, $p_dy) = ($p_x - $n0_x, $p_y - $n0_y);
    foreach my $n (2 .. @$bvalues + 1) {
      my ($x, $y) = transpose ($hilbert->n_to_xy ($n));
      my $dx = ($x - $p_x);
      my $dy = ($y - $p_y);

      if ($p_dx) {
        if ($dx) {
          push @got, 0;  # ahead horizontally
        } elsif ($dy == $p_dx) {
          push @got, 1;  # right
        } else {
          push @got, 2;  # left
        }
      } else {
        # p_dy
        if ($dy) {
          push @got, 0;  # ahead horizontally
        } elsif ($dx == $p_dy) {
          push @got, 2;  # left
        } else {
          push @got, 1;  # right
        }
      }
      ### $n
      ### $p_dx
      ### $p_dy
      ### $dx
      ### $dy
      ### is: "$got[-1]   at idx $#got"

      ($p_dx,$p_dy) = ($dx,$dy);
      ($p_x,$p_y) = ($x,$y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction transposed");
}


exit 0;
