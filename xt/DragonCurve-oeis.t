#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

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
BEGIN { plan tests => 12 }

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
  my $i = 0; 
  while ($i < @$a1 && $i < @$a2) {
    if ($a1->[$i] ne $a2->[$i]) {
      return 0;
    }
    $i++;
  }
  return (@$a1 == @$a2);
}

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


#------------------------------------------------------------------------------
# A088431 - dragon turns run lengths

{
  my $anum = 'A088431';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");

    my $prev_turn = path_n_turn($dragon,1);
    my $run = 1; # count for initial $prev_turn
    for (my $n = 2; @got < @$bvalues; $n++) {
      my $turn = path_n_turn($dragon,$n);
      if ($turn == $prev_turn) {
        $run++;
      } else {
        push @got, $run;
        $run = 1; # count for new $turn value
      }
      $prev_turn = $turn;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- cumulative turn");
}

# return 1 for left, 0 for right
sub path_n_turn {
  my ($path, $n) = @_;
  my $prev_dir = path_n_dir ($path, $n-1);
  my $dir = path_n_dir ($path, $n);
  my $turn = ($dir - $prev_dir) % 4;
  if ($turn == 1) { return 1; }
  if ($turn == 3) { return 0; }
  die "Oops, unrecognised turn";
}
# return 0,1,2,3
sub path_n_dir {
  my ($path, $n) = @_;
  my ($x,$y) = $path->n_to_xy($n);
  my ($next_x,$next_y) = $path->n_to_xy($n+1);
  return dxdy_to_dir ($next_x - $x,
                      $next_y - $y);
}
# return 0,1,2,3, with Y reckoned increasing upwards
sub dxdy_to_dir {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 0; }  # east
  if ($dx < 0) { return 2; }  # west
  if ($dy > 0) { return 1; }  # north
  if ($dy < 0) { return 3; }  # south
}


#------------------------------------------------------------------------------
# A088748 - dragon cumulative turn +/-1

{
  my $anum = 'A088748';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");

    my ($n0_x, $n0_y) = $dragon->n_to_xy (0);
    my ($prev_x, $prev_y) = $dragon->n_to_xy (1);
    my $prev_dir = dxdy_to_direction ($prev_x - $n0_x,
                                      $prev_y - $n0_y);
    my $cumulative = 1;
    for (my $n = 2; @got < @$bvalues; $n++) {
      push @got, $cumulative;

      my ($x, $y) = $dragon->n_to_xy ($n);
      my $dir = dxdy_to_direction ($x - $prev_x,
                                   $y - $prev_y);
      my $turn = ($dir - $prev_dir) % 4;
      if ($turn == 1) {
        $turn = 1; # left
      } elsif ($turn == 3) {
        $turn = -1; # right
      } else {
        die "Oops, unrecognised turn $turn";
      }
      $cumulative += $turn;

      ($prev_x,$prev_y) = ($x,$y);
      $prev_dir = $dir;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- cumulative turn");
}

#------------------------------------------------------------------------------
# A164910 - dragon cumulative turn +/-1, then partial sums

{
  my $anum = 'A164910';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");

    my ($n0_x, $n0_y) = $dragon->n_to_xy (0);
    my ($prev_x, $prev_y) = $dragon->n_to_xy (1);
    my $prev_dir = dxdy_to_direction ($prev_x - $n0_x,
                                      $prev_y - $n0_y);
    my $cumulative = 1;
    my $partial_sum = $cumulative;
    for (my $n = 2; @got < @$bvalues; $n++) {
      push @got, $partial_sum;

      my ($x, $y) = $dragon->n_to_xy ($n);
      my $dir = dxdy_to_direction ($x - $prev_x,
                                   $y - $prev_y);
      my $turn = ($dir - $prev_dir) % 4;
      if ($turn == 1) {
        $turn = 1; # left
      } elsif ($turn == 3) {
        $turn = -1; # right
      } else {
        die "Oops, unrecognised turn $turn";
      }
      $cumulative += $turn;
      $partial_sum += $cumulative;

      ($prev_x,$prev_y) = ($x,$y);
      $prev_dir = $dir;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- partial sums cumulative turn");
}

#------------------------------------------------------------------------------
# A082410 -- complement reversal, is 1=left, 0=right

{
  my $anum = 'A082410';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");

    push @got, 0;

    my ($n0_x, $n0_y) = $dragon->n_to_xy (0);
    my ($prev_x, $prev_y) = $dragon->n_to_xy (1);
    my $prev_dir = dxdy_to_direction ($prev_x - $n0_x,
                                      $prev_y - $n0_y);
    for (my $n = 2; @got < @$bvalues; $n++) {
      my ($x, $y) = $dragon->n_to_xy ($n);
      my $dir = dxdy_to_direction ($x - $prev_x,
                                   $y - $prev_y);
      my $turn = ($dir - $prev_dir) % 4;
      if ($turn == 1) {
        push @got, 1;  # left
      } elsif ($turn == 3) {
        push @got, 0;  # right
      } else {
        die "Oops, unrecognised turn";
      }

      ($prev_x,$prev_y) = ($x,$y);
      $prev_dir = $dir;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- reversal complement");
}

#------------------------------------------------------------------------------
# A038189 -- bit above lowest 1, is 0=left,1=right

{
  my $anum = 'A038189';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");

    push @got, 0;

    my ($n0_x, $n0_y) = $dragon->n_to_xy (0);
    my ($prev_x, $prev_y) = $dragon->n_to_xy (1);
    my $prev_dir = dxdy_to_direction ($prev_x - $n0_x,
                                      $prev_y - $n0_y);
    for (my $n = 2; @got < @$bvalues; $n++) {
      my ($x, $y) = $dragon->n_to_xy ($n);
      my $dir = dxdy_to_direction ($x - $prev_x,
                                   $y - $prev_y);
      my $turn = ($dir - $prev_dir) % 4;
      if ($turn == 1) {
        push @got, 0;  # left
      } elsif ($turn == 3) {
        push @got, 1;  # right
      } else {
        die "Oops, unrecognised turn";
      }

      ($prev_x,$prev_y) = ($x,$y);
      $prev_dir = $dir;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A091072 -- N positions of left turns

{
  my $anum = 'A091072';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has $#$bvalues values");

    my ($n0_x, $n0_y) = $dragon->n_to_xy (0);
    my ($prev_x, $prev_y) = $dragon->n_to_xy (1);
    my $prev_dir = dxdy_to_direction ($prev_x - $n0_x,
                                      $prev_y - $n0_y);
    for (my $n = 2; @got < @$bvalues; $n++) {
      my ($x, $y) = $dragon->n_to_xy ($n);
      my $dir = dxdy_to_direction ($x - $prev_x,
                                   $y - $prev_y);
      my $turn = ($dir - $prev_dir) % 4;
      if ($turn == 1) {
        push @got, $n-1;  # left
      } elsif ($turn == 3) {
        # right
      } else {
        die "Oops, unrecognised turn";
      }

      ($prev_x,$prev_y) = ($x,$y);
      $prev_dir = $dir;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- left turn N positions");
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
# cf A082410 maybe same with an extra initial 0
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
