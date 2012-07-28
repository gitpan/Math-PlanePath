#!/usr/bin/perl -w

# Copyright 2010, 2011, 2012 Kevin Ryde

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
plan tests => 39;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use List::Util 'min', 'max';
use Math::PlanePath::SquareSpiral;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::SquareSpiral->new;

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

# return 1,2,3,4
sub path_n_dir4_1 {
  my ($path, $n) = @_;
  my ($x,$y) = $path->n_to_xy($n);
  my ($next_x,$next_y) = $path->n_to_xy($n+1);
  return dxdy_to_dir4_1 ($next_x - $x,
                         $next_y - $y);
}
# return 1,2,3,4, with Y reckoned increasing upwards
sub dxdy_to_dir4_1 {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 1; }  # east
  if ($dx < 0) { return 3; }  # west
  if ($dy > 0) { return 2; }  # north
  if ($dy < 0) { return 4; }  # south
}


#------------------------------------------------------------------------------
# A143856 -- N values ENE slope=2
{
  my $anum = 'A143856';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n (2*$i, $i);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- ENE");
}

#------------------------------------------------------------------------------
# A143861 -- N values NNE slope=2
{
  my $anum = 'A143861';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n ($i, 2*$i);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- NNE");
}

#------------------------------------------------------------------------------
# A069894 -- wider=1 diagonal SW
{
  my $anum = 'A069894';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::SquareSpiral->new (wider => 1);
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n (-$i, -$i);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- NNE");
}

#------------------------------------------------------------------------------
# A069894 -- wider=1 diagonal SE, extra initial 0
{
  my $anum = 'A002939';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0);
  if ($bvalues) {
    my $path = Math::PlanePath::SquareSpiral->new (wider => 1);
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n ($i, -$i);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- NNE");
}

#------------------------------------------------------------------------------
# A063826 -- direction 1,2,3,4 = E,N,W,S

{
  my $anum = 'A063826';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      push @got, path_n_dir4_1($path,$n);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A062410 -- a(n) is sum of existing numbers in row of a(n-1)

{
  my $anum = 'A062410';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                      max_value => 'unlimited');
  my @got;
  if ($bvalues) {
    require Math::BigInt;
    my %plotted;
    $plotted{0,0} = Math::BigInt->new(1);
    my $xmin = 0;
    my $ymin = 0;
    my $xmax = 0;
    my $ymax = 0;
    push @got, 1;

    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my ($prev_x, $prev_y) = $path->n_to_xy ($n-1);
      my ($x, $y) = $path->n_to_xy ($n);
      my $total = 0;
      if ($y == $prev_y) {
        ### column: "$ymin .. $ymax at x=$prev_x"
        foreach my $y ($ymin .. $ymax) {
          $total += $plotted{$prev_x,$y} || 0;
        }
      } else {
        ### row: "$xmin .. $xmax at y=$prev_y"
        foreach my $x ($xmin .. $xmax) {
          $total += $plotted{$x,$prev_y} || 0;
        }
      }
      ### total: "$total"

      $plotted{$x,$y} = $total;
      $xmin = min($xmin,$x);
      $xmax = max($xmax,$x);
      $ymin = min($ymin,$y);
      $ymax = max($ymax,$y);
      push @got, $total;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- sum of rows");
}

#------------------------------------------------------------------------------
# A053615 -- distance to pronic is abs(X-Y)

{
  my $anum = 'A053615';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, abs($x-$y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A118175 -- abs(dX) is k 0's followed by k 1s etc, with initial 1

{
  my $anum = 'A118175';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      my ($next_x, $next_y) = $path->n_to_xy ($n+1);
      my $dx = $next_x - $x;
      push @got, abs($dx);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A079813 -- abs(dY) is k 0's followed by k 1s etc

{
  my $anum = 'A079813';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      my ($next_x, $next_y) = $path->n_to_xy ($n+1);
      my $dy = $next_y - $y;
      push @got, abs($dy);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}


#------------------------------------------------------------------------------
# A141481 -- plot sum of existing eight surrounding values entered

{
  my $anum = 'A141481';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                      max_value => 'unlimited');
  my @got;
  if ($bvalues) {
    require Math::BigInt;
    my %plotted;
    $plotted{0,0} = Math::BigInt->new(1);
    push @got, 1;

    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      my $value = (
                   ($plotted{$x+1,$y+1} || 0)
                   + ($plotted{$x+1,$y} || 0)
                   + ($plotted{$x+1,$y-1} || 0)

                   + ($plotted{$x-1,$y-1} || 0)
                   + ($plotted{$x-1,$y} || 0)
                   + ($plotted{$x-1,$y+1} || 0)

                   + ($plotted{$x,$y-1} || 0)
                   + ($plotted{$x,$y+1} || 0)
                  );
      $plotted{$x,$y} = $value;
      push @got, $value;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- sum of eight surrounding");
}

#------------------------------------------------------------------------------
# A033638 -- N positions of the turns

{
  my $anum = 'A033638';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    push @got, 1, 1;
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my ($prev_x, $prev_y) = $path->n_to_xy ($n-1);
      my ($x, $y) = $path->n_to_xy ($n);
      my ($next_x, $next_y) = $path->n_to_xy ($n+1);

      if ($x - $prev_x != $next_x - $x
          || $y - $prev_y != $next_y - $y) {
        # not straight ahead
        push @got, $n;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- N positions of turns");
}

#------------------------------------------------------------------------------
# A172979 -- N positions of the turns which are also primes

{
  my $anum = 'A172979';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    for (my $n = $path->n_start + 1; @got < @$bvalues; $n++) {
      my ($prev_x, $prev_y) = $path->n_to_xy ($n-1);
      my ($x, $y) = $path->n_to_xy ($n);
      my ($next_x, $next_y) = $path->n_to_xy ($n+1);

      if ($x - $prev_x != $next_x - $x
          || $y - $prev_y != $next_y - $y) {
        # not straight ahead

        if (Math::Prime::XS::is_prime($n)) {
          push @got, $n;
        }
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- N positions of turns which are primes too");
}

#------------------------------------------------------------------------------
# A020703 -- permutation read clockwise, ie. negative Y
{
  my $anum = 'A020703';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $path->xy_to_n ($y, $x);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- permutation clockwise");
}

#------------------------------------------------------------------------------
# A121496 -- run lengths of consecutive N in A068225 N at X+1,Y

{
  my $anum = 'A121496';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $count = 0;
    my $prev_right_n = A068225(1) - 1;  # make first value look like a run
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my $right_n = A068225($n);
      if ($right_n == $prev_right_n + 1) {
        $count++;
      } else {
        push @got, $count;
        $count = 1;
      }
      $prev_right_n = $right_n;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- run lengths of consecutive N at X+1,Y");
}


#------------------------------------------------------------------------------
# A054551 -- plot Nth prime at each N, values are those primes on X axis

{
  my $anum = 'A054551';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    my $hi = $bvalues->[-1];
    my @primes = (0,  # skip N=0
                  Math::Prime::XS::sieve_primes($hi));
    for (my $x = 0; @got < @$bvalues; $x++) {
      my $n = $path->xy_to_n($x,0);
      last if $n > $#primes;
      push @got, $primes[$n];
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- primes X axis");
}

#------------------------------------------------------------------------------
# A054553 -- plot Nth prime at each N, values are those primes on X=Y diagonal

{
  my $anum = 'A054553';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    my $hi = $bvalues->[-1];
    my @primes = (0,  # skip N=0
                  Math::Prime::XS::sieve_primes($hi));
    for (my $x = 0; @got < @$bvalues; $x++) {
      my $n = $path->xy_to_n($x,$x);
      last if $n > $#primes;
      push @got, $primes[$n];
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- primes X=Y diagonal");
}

#------------------------------------------------------------------------------
# A054555 -- plot Nth prime at each N, values are those primes on Y axis

{
  my $anum = 'A054555';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    my $hi = $bvalues->[-1];
    my @primes = (0,  # skip N=0
                  Math::Prime::XS::sieve_primes($hi));
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $n = $path->xy_to_n(0,$y);
      last if $n > $#primes;
      push @got, $primes[$n];
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- primes Y axis");
}

#------------------------------------------------------------------------------
# A053999 -- plot Nth prime at each N, values are those primes on South-East

{
  my $anum = 'A053999';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    my $hi = $bvalues->[-1];
    my @primes = (0,  # skip N=0
                  Math::Prime::XS::sieve_primes($hi));
    for (my $x = 0; @got < @$bvalues; $x++) {
      my $n = $path->xy_to_n($x,-$x);
      last if $n > $#primes;
      push @got, $primes[$n];
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- primes Y axis");
}

#------------------------------------------------------------------------------
# A054564 -- plot Nth prime at each N, values are those primes on North-West

{
  my $anum = 'A054564';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    my $hi = $bvalues->[-1];
    my @primes = (0,  # skip N=0
                  Math::Prime::XS::sieve_primes($hi));
    for (my $x = 0; @got < @$bvalues; $x--) {
      my $n = $path->xy_to_n($x,-$x);
      last if $n > $#primes;
      push @got, $primes[$n];
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- primes Y axis");
}

#------------------------------------------------------------------------------
# A054566 -- plot Nth prime at each N, values are those primes on negative X

{
  my $anum = 'A054566';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::Prime::XS }) {
    $skip = "Math::Prime::XS not available";
    MyTestHelpers::diag ("Math::Prime::XS not available -- $@");

  } else {
    my $hi = $bvalues->[-1];
    my @primes = (0,  # skip N=0
                  Math::Prime::XS::sieve_primes($hi));
    for (my $x = 0; @got < @$bvalues; $x--) {
      my $n = $path->xy_to_n($x,0);
      last if $n > $#primes;
      push @got, $primes[$n];
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- primes Y axis");
}

#------------------------------------------------------------------------------
# A137928 -- N values on diagonal X=1-Y positive and negative
{
  my $anum = 'A137928';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n(1-$y,$y);
      last unless @got < @$bvalues;
      if ($y != 0) {
        push @got, $path->xy_to_n(1-(-$y),-$y);
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=Y+1 diagonal, positive and negative");
}

#------------------------------------------------------------------------------
# A002061 -- central polygonal numbers, N values on diagonal X=Y pos and neg
{
  my $anum = 'A002061';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n($y,$y);
      last unless @got < @$bvalues;
      push @got, $path->xy_to_n(-$y,-$y);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=Y+1 diagonal, positive and negative");
}

#------------------------------------------------------------------------------
# A016814 -- N values (4n+1)^2 on SE diagonal every second square
{
  my $anum = 'A016814';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $i = 0; @got < @$bvalues; $i+=2) {
      push @got, $path->xy_to_n($i,-$i);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=Y diagonal");
}

#------------------------------------------------------------------------------
# A033952 -- AllDigits on negative Y axis

{
  my $anum = 'A033952';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::NumSeq::AllDigits }) {
    $skip = "Math::NumSeq::AllDigits not available";
    MyTestHelpers::diag ("Math::NumSeq::AllDigits not available -- $@");

  } else {
    my $seq = Math::NumSeq::AllDigits->new;
    for (my $y = 0; @got < @$bvalues; $y--) {
      my $n = $path->xy_to_n (0, $y);
      push @got, $seq->ith($n);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- AllDigits negative Y axis");
}

#------------------------------------------------------------------------------
# A033953 -- AllDigits starting 0, on negative Y axis

{
  my $anum = 'A033953';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::NumSeq::AllDigits }) {
    $skip = "Math::NumSeq::AllDigits not available";
    MyTestHelpers::diag ("Math::NumSeq::AllDigits not available -- $@");

  } else {
    my $seq = Math::NumSeq::AllDigits->new;
    for (my $y = 0; @got < @$bvalues; $y--) {
      my $n = $path->xy_to_n (0, $y);
      push @got, $seq->ith($n-1);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- AllDigits starting 0, negative Y axis");
}

#------------------------------------------------------------------------------
# A033988 -- AllDigits starting 0, on negative X axis

{
  my $anum = 'A033988';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::NumSeq::AllDigits }) {
    $skip = "Math::NumSeq::AllDigits not available";
    MyTestHelpers::diag ("Math::NumSeq::AllDigits not available -- $@");

  } else {
    my $seq = Math::NumSeq::AllDigits->new;
    for (my $x = 0; @got < @$bvalues; $x--) {
      my $n = $path->xy_to_n ($x, 0);
      push @got, $seq->ith($n-1);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- AllDigits starting 0, negative X axis");
}

#------------------------------------------------------------------------------
# A033989 -- AllDigits starting 0, on positive Y axis

{
  my $anum = 'A033989';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::NumSeq::AllDigits }) {
    $skip = "Math::NumSeq::AllDigits not available";
    MyTestHelpers::diag ("Math::NumSeq::AllDigits not available -- $@");

  } else {
    my $seq = Math::NumSeq::AllDigits->new;
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $n = $path->xy_to_n (0, $y);
      push @got, $seq->ith($n-1);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- AllDigits starting 0, negative X axis");
}

#------------------------------------------------------------------------------
# A033990 -- AllDigits starting 0, on positive X axis

{
  my $anum = 'A033990';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $skip;
  if (! $bvalues) {
    $skip = "$anum not available";

  } elsif (! eval { require Math::NumSeq::AllDigits }) {
    $skip = "Math::NumSeq::AllDigits not available";
    MyTestHelpers::diag ("Math::NumSeq::AllDigits not available -- $@");

  } else {
    my $seq = Math::NumSeq::AllDigits->new;
    for (my $x = 0; @got < @$bvalues; $x++) {
      my $n = $path->xy_to_n ($x, 0);
      push @got, $seq->ith($n-1);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip ($skip,
        numeq_array(\@got, $bvalues),
        1, "$anum -- AllDigits starting 0, negative X axis");
}

#------------------------------------------------------------------------------
# A016754 -- N values on X=-Y diagonal X>=0
{
  my $anum = 'A016754';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $x = 0; @got < @$bvalues; $x++) {
      push @got, $path->xy_to_n($x,-$x);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=-Y diagonal for X>=0");
}

#------------------------------------------------------------------------------
# A053755 -- N values on X=-Y diagonal X<=0
{
  my $anum = 'A053755';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $x = 0; @got < @$bvalues; $x--) {
      push @got, $path->xy_to_n($x,-$x);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=-Y diagonal for X>=0");
}

#------------------------------------------------------------------------------
# A033951 -- N values negative Y axis

{
  my $anum = 'A033951';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $y = 0; @got < @$bvalues; $y--) {
      push @got, $path->xy_to_n(0,$y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=-Y diagonal for X>=0");
}

#------------------------------------------------------------------------------
# A054556 -- N values on Y axis
{
  my $anum = 'A054556';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n(0,$y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Y axis");
}

#------------------------------------------------------------------------------
# A054552 -- N values on X axis
{
  my $anum = 'A054552';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $x = 0; @got < @$bvalues; $x++) {
      my $n = $path->xy_to_n ($x, 0);
      push @got, $n;
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X axis");
}

#------------------------------------------------------------------------------
# A054567 -- N values on negative X axis
{
  my $anum = 'A054567';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $x = 0; @got < @$bvalues; $x++) {
      my $n = $path->xy_to_n (-$x, 0);
      push @got, $n;
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X axis");
}

#------------------------------------------------------------------------------
# A054554 -- N values on X=Y diagonal
{
  my $anum = 'A054554';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n($i,$i);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=Y diagonal");
}

#------------------------------------------------------------------------------
# A054569 -- N values on negative X=Y diagonal
{
  my $anum = 'A054569';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n(-$i,-$i);
    }
    ### bvalues: join(',',@{$bvalues}[0..20])
    ### got: '    '.join(',',@got[0..20])
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X=Y diagonal");
}

#------------------------------------------------------------------------------
# A180714 -- coord sum X+Y
{
  my $anum = 'A180714';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      my $sum = $x + $y;
      push @got, $sum;
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- sum coords X+Y");
}

#------------------------------------------------------------------------------
# A068225 -- permutation N at X+1,Y
{
  my $anum = 'A068225';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      push @got, A068225($n);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- permutation N at X+1,Y");
}

# starting n=1
sub A068225 {
  my ($n) = @_;
  my ($x, $y) = $path->n_to_xy ($n);
  return $path->xy_to_n ($x+1,$y);
}

#------------------------------------------------------------------------------
# A068226 -- permutation N at X-1,Y
{
  my $anum = 'A068226';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $path->xy_to_n ($x-1,$y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- permutation N at X-1,Y");
}

#------------------------------------------------------------------------------
exit 0;
