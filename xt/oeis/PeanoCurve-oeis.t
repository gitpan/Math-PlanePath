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
plan tests => 21;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::PeanoCurve;
use Math::PlanePath::Diagonals;
use Math::PlanePath::ZOrderCurve;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $peano  = Math::PlanePath::PeanoCurve->new;

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


#------------------------------------------------------------------------------
# A014578 -- abs(dX), 1=horizontal 0=vertical, extra initial 0
MyOEIS::compare_values
  (anum => 'A014578',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::PeanoCurve->new;
     my @got = (0);
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($dx,$dy) = $peano->n_to_dxdy($n);
       push @got, abs($dx);
     }
     return \@got;
   });

# A182581 -- abs(dY), but OFFSET=1
MyOEIS::compare_values
  (anum => 'A182581',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::PeanoCurve->new;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($dx,$dy) = $peano->n_to_dxdy($n);
       push @got, abs($dy);
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A007417 -- N+1 positions of horizontal step, dY==0, abs(dX)=1
# N+1 has even num trailing ternary 0-digits

MyOEIS::compare_values
  (anum => 'A007417',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::PeanoCurve->new;
     my @got;
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($dx,$dy) = $peano->n_to_dxdy($n);
       if ($dy == 0) {
         push @got, $n+1;
       }
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A163532 -- dX  a(n)-a(n-1) so extra initial 0

MyOEIS::compare_values
  (anum => 'A163532',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::PeanoCurve->new;
     my @got = (0); # extra initial entry N=0 no change
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($dx,$dy) = $peano->n_to_dxdy($n);
       push @got, $dx;
     }
     return \@got;
   });

# A163533 -- dY  a(n)-a(n-1)
MyOEIS::compare_values
  (anum => 'A163533',
   func => sub {
     my ($count) = @_;
     my $path  = Math::PlanePath::PeanoCurve->new;
     my @got = (0); # extra initial entry N=0 no change
     for (my $n = $path->n_start; @got < $count; $n++) {
       my ($dx,$dy) = $peano->n_to_dxdy($n);
       push @got, $dy;
     }
     return \@got;
   });

#------------------------------------------------------------------------------
# A163333 -- Peano N <-> Z-Order radix=3, with digit swaps
{
  my $anum = 'A163333';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my @got;
    if ($bvalues) {
      my $peano  = Math::PlanePath::PeanoCurve->new;
      my $zorder = Math::PlanePath::ZOrderCurve->new (radix => 3);
      for (my $n = $zorder->n_start; @got < @$bvalues; $n++) {
        my $nn = $n;
        {
          my ($x,$y) = $zorder->n_to_xy ($nn);
          ($x,$y) = ($y,$x);
          $nn = $zorder->xy_to_n ($x,$y);
        }
        {
          my ($x,$y) = $zorder->n_to_xy ($nn);
          $nn = $peano->xy_to_n ($x, $y);
        }
        {
          my ($x,$y) = $zorder->n_to_xy ($nn);
          ($x,$y) = ($y,$x);
          $nn = $zorder->xy_to_n ($x,$y);
        }
        push @got, $nn;
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum");
  }
  {
    my @got;
    if ($bvalues) {
      my $peano  = Math::PlanePath::PeanoCurve->new;
      my $zorder = Math::PlanePath::ZOrderCurve->new (radix => 3);
      for (my $n = 0; @got < @$bvalues; $n++) {
        my $nn = $n;
        {
          my ($x,$y) = $zorder->n_to_xy ($nn);
          ($x,$y) = ($y,$x);
          $nn = $zorder->xy_to_n ($x,$y);
        }
        {
          my ($x,$y) = $peano->n_to_xy ($nn);   # other way around
          $nn = $zorder->xy_to_n ($x, $y);
        }
        {
          my ($x,$y) = $zorder->n_to_xy ($nn);
          ($x,$y) = ($y,$x);
          $nn = $zorder->xy_to_n ($x,$y);
        }
        push @got, $nn;
      }
      if (! numeq_array(\@got, $bvalues)) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum");
  }
}


#------------------------------------------------------------------------------
# A163332 -- Peano N at points in Z-Order radix=3 sequence
{
  my $anum = 'A163332';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my @got;
    if ($bvalues) {
      my $peano  = Math::PlanePath::PeanoCurve->new;
      my $zorder = Math::PlanePath::ZOrderCurve->new (radix => 3);
      for (my $n = $zorder->n_start; @got < @$bvalues; $n++) {
        my ($x,$y) = $zorder->n_to_xy ($n);
        push @got, $peano->xy_to_n ($x, $y);
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum");
  }
  {
    my @got;
    if ($bvalues) {
      my $peano  = Math::PlanePath::PeanoCurve->new;
      my $zorder = Math::PlanePath::ZOrderCurve->new (radix => 3);
      for (my $n = $peano->n_start; @got < @$bvalues; $n++) {
        my ($x,$y) = $peano->n_to_xy ($n);   # other way around
        push @got, $zorder->xy_to_n ($x, $y);
      }
    }
    skip (! $bvalues,
          numeq_array(\@got, $bvalues),
          1, "$anum");
  }
}


#------------------------------------------------------------------------------
# A163334 -- diagonals same axis
{
  my $anum = 'A163334';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'up',
                                                    n_start => 0);
    for (my $n = $diagonal->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal->n_to_xy ($n);
      push @got, $peano->xy_to_n ($x, $y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163335 -- diagonals same axis, inverse
{
  my $anum = 'A163335';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'up',
                                                    n_start => 0);
    for (my $n = $peano->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $peano->n_to_xy ($n);
      push @got, $diagonal->xy_to_n($x,$y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163336 -- diagonals opposite axis
{
  my $anum = 'A163336';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'down',
                                                    n_start => 0);
    for (my $n = $diagonal->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal->n_to_xy ($n);
      push @got, $peano->xy_to_n ($x, $y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163337 -- diagonals opposite axis, inverse
{
  my $anum = 'A163337';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'down',
                                                    n_start => 0);
    for (my $n = $peano->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $peano->n_to_xy ($n);
      push @got, $diagonal->xy_to_n($x,$y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163338 -- diagonals same axis, 1-based
{
  my $anum = 'A163338';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'up');
    for (my $n = $diagonal->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal->n_to_xy ($n);
      push @got, $peano->xy_to_n ($x, $y) + 1;
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163339 -- diagonals same axis, 1-based, inverse
{
  my $anum = 'A163339';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'up');
    for (my $n = $peano->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $peano->n_to_xy ($n);
      push @got, $diagonal->xy_to_n ($x, $y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163340 -- diagonals same axis, 1 based
{
  my $anum = 'A163340';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'down');
    for (my $n = $diagonal->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal->n_to_xy ($n);
      push @got, $peano->xy_to_n($x,$y) + 1;
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163341 -- diagonals same axis, 1-based, inverse
{
  my $anum = 'A163341';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'down');
    for (my $n = $peano->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $peano->n_to_xy ($n);
      push @got, $diagonal->xy_to_n($x,$y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163342 -- diagonal sums
# no b-file as of Jan 2011
{
  my $anum = 'A163342';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $d = 0; @got < @$bvalues; $d++) {
      my $sum = 0;
      foreach my $x (0 .. $d) {
        my $y = $d - $x;
        $sum += $peano->xy_to_n ($x, $y);
      }
      push @got, $sum;
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, 'A163342 -- diagonal sums');
}

# A163479 -- diagonal sums div 6
{
  my $anum = 'A163479';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $d = 0; @got < @$bvalues; $d++) {
      my $sum = 0;
      foreach my $x (0 .. $d) {
        my $y = $d - $x;
        $sum += $peano->xy_to_n ($x, $y);
      }
      push @got, int($sum/6);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, 'A163479 -- diagonal sums');
}

#------------------------------------------------------------------------------
# A163344 -- N/4 on X=Y diagonal
{
  my $anum = 'A163344';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $x = 0; @got < @$bvalues; $x++) {
      push @got, int($peano->xy_to_n($x,$x) / 4);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- central diagonal div 4");
}

#------------------------------------------------------------------------------
# A163534 -- absolute direction 0=east, 1=south, 2=west, 3=north
# Y coordinates reckoned down the page, so south is Y increasing

{
  my $anum = 'A163534';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $peano->n_start; @got < @$bvalues; $n++) {
      my ($dx, $dy) = $peano->n_to_dxdy ($n);
      push @got, MyOEIS::dxdy_to_direction ($dx, $dy);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- absolute direction");
}

#------------------------------------------------------------------------------
# A163535 -- absolute direction transpose 0=east, 1=south, 2=west, 3=north

{
  my $anum = 'A163535';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $peano->n_start; @got < @$bvalues; $n++) {
      my ($dx, $dy) = $peano->n_to_dxdy ($n);
      push @got, MyOEIS::dxdy_to_direction ($dy, $dx);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- absolute direction transpose");
}

#------------------------------------------------------------------------------
# A163536 -- relative direction 0=ahead, 1=right, 2=left
# Y coordinates reckoned down the page
{
  my $anum = 'A163536';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my ($n0_x, $n0_y) = $peano->n_to_xy (0);
    my ($p_x, $p_y) = $peano->n_to_xy (1);
    my ($p_dx, $p_dy) = ($p_x - $n0_x, $p_y - $n0_y);
    foreach my $n (2 .. @$bvalues + 1) {
      my ($x, $y) = $peano->n_to_xy ($n);
      my $dx = $x - $p_x;
      my $dy = $y - $p_y;

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
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction");
}

#------------------------------------------------------------------------------
# A163537 -- relative direction 0=ahead, 1=right, 2=left
# Y coordinates reckoned down the page

sub transpose {
  my ($x, $y) = @_;
  return ($y, $x);
}
{
  my $anum = 'A163537';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my ($n0_x, $n0_y) = transpose ($peano->n_to_xy (0));
    my ($p_x, $p_y) = transpose ($peano->n_to_xy (1));
    my ($p_dx, $p_dy) = ($p_x - $n0_x, $p_y - $n0_y);
    foreach my $n (2 .. @$bvalues + 1) {
      my ($x, $y) = transpose ($peano->n_to_xy ($n));
      my $dx = $x - $p_x;
      my $dy = $y - $p_y;

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
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction transposed");
}


exit 0;
