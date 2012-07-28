#!/usr/bin/perl -w

# Copyright 2012 Kevin Ryde

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
use Math::BigInt;
use Math::PlanePath::DiagonalsOctant;

use Test;
plan tests => 13;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;


# uncomment this to run the ### lines
#use Smart::Comments '###';

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
sub diff_nums {
  my ($gotaref, $wantaref) = @_;
  for (my $i = 0; $i < @$gotaref; $i++) {
    if ($i > @$wantaref) {
      return "want ends prematurely pos=$i";
    }
    my $got = $gotaref->[$i];
    my $want = $wantaref->[$i];
    if (! defined $got && ! defined $want) {
      next;
    }
    if (! defined $got || ! defined $want) {
      return "different pos=$i got=".(defined $got ? $got : '[undef]')
        ." want=".(defined $want ? $want : '[undef]');
    }
    $got =~ /^[0-9.-]+$/
      or return "not a number pos=$i got='$got'";
    $want =~ /^[0-9.-]+$/
      or return "not a number pos=$i want='$want'";
    if ($got != $want) {
      return "different pos=$i numbers got=$got want=$want";
    }
  }
  return undef;
}


#------------------------------------------------------------------------------
# A079823 -- concat of rows numbers in diagonals octant order
{
  my $anum = qq{A079823}; # not xreffed
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    require Math::PlanePath::PyramidRows;
    my $diag = Math::PlanePath::DiagonalsOctant->new;
    my $rows = Math::PlanePath::PyramidRows->new(step=>1);
    my $prev_d = 0;
    my $str = '';
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $diag->n_to_xy($n);
      my $d = $x+$y;
      if ($d != $prev_d) {
        push @got, $str;
        $str = '';
        $prev_d = $d;
      }
      $str .= $rows->xy_to_n($x,$y);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..12]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..12]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A079826 -- concat of rows numbers in diagonals octant order
#            rows numbered alternately left and right
{
  my $anum = qq{A079826}; # not xreffed
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum,
                                                      max_count => 10); # typo
  my $diff;
  if ($bvalues) {
    my @got;
    require Math::PlanePath::PyramidRows;
    my $diag = Math::PlanePath::DiagonalsOctant->new;
    my $rows = Math::PlanePath::PyramidRows->new(step=>1);
    my $prev_d = 0;
    my $str = '';
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $diag->n_to_xy($n);
      my $d = $x+$y;
      if ($d != $prev_d) {
        push @got, Math::BigInt->new($str);
        $str = '';
        $prev_d = $d;
      }
      if ($y % 2) {
        $x = $y-$x;
      }
      $str .= $rows->xy_to_n($x,$y);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..12]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..12]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A091018 -- permutation diagonals octant -> rows, 0 based
{
  my $anum = 'A091018';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    require Math::PlanePath::PyramidRows;
    my $diag = Math::PlanePath::DiagonalsOctant->new;
    my $rows = Math::PlanePath::PyramidRows->new(step=>1);
    for (my $n = $diag->n_start; @got < @$bvalues; $n++) {
      my ($x,$y) = $diag->n_to_xy($n);
      push @got, $rows->xy_to_n($x,$y) - 1;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A090894 -- permutation diagonals octant -> rows, 0 based, upwards
{
  my $anum = 'A090894';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    require Math::PlanePath::PyramidRows;
    my $diag = Math::PlanePath::DiagonalsOctant->new(direction=>'up');
    my $rows = Math::PlanePath::PyramidRows->new(step=>1);
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $diag->n_to_xy($n);
      push @got, $rows->xy_to_n($x,$y) - 1;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A091995 -- permutation diagonals octant -> rows, 1 based, upwards
{
  my $anum = 'A091995';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    require Math::PlanePath::PyramidRows;
    my $diag = Math::PlanePath::DiagonalsOctant->new(direction=>'up');
    my $rows = Math::PlanePath::PyramidRows->new(step=>1);
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $diag->n_to_xy($n);
      push @got, $rows->xy_to_n($x,$y);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A056536 -- permutation diagonals octant -> rows
{
  my $anum = 'A056536';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    require Math::PlanePath::PyramidRows;
    my $diag = Math::PlanePath::DiagonalsOctant->new;
    my $rows = Math::PlanePath::PyramidRows->new(step=>1);
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $diag->n_to_xy($n);
      push @got, $rows->xy_to_n($x,$y);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A056537 -- permutation rows -> diagonals octant
{
  my $anum = 'A056537';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    require Math::PlanePath::PyramidRows;
    my $diag = Math::PlanePath::DiagonalsOctant->new;
    my $rows = Math::PlanePath::PyramidRows->new(step=>1);
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $rows->n_to_xy($n);
      push @got, $diag->xy_to_n($x,$y);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A004652 -- N start,end of even diagonals
{
  my $anum = 'A004652';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got = (0);
    my $path = Math::PlanePath::DiagonalsOctant->new;
    for (my $y = 0; @got < @$bvalues; $y += 2) {
      push @got, $path->xy_to_n (0,$y);
      last unless @got < @$bvalues;
      push @got, $path->xy_to_n ($y/2,$y/2);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A002620 -- N end each diagonal
{
  my $anum = 'A002620';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my $diff;
    if ($bvalues) {
      my @got = (0,0);
      my $path = Math::PlanePath::DiagonalsOctant->new;
      for (my $x = 0; @got < @$bvalues; $x++) {
        push @got, $path->xy_to_n ($x,$x);
        last unless @got < @$bvalues;
        push @got, $path->xy_to_n ($x,$x+1);
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          $diff, undef);
  }
  {
    my $diff;
    if ($bvalues) {
      my @got = (0,0);
      my $path = Math::PlanePath::DiagonalsOctant->new (direction => 'up');
      for (my $y = 0; @got < @$bvalues; $y++) {
        push @got, $path->xy_to_n (0,$y);
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          $diff, undef);
  }
}

#------------------------------------------------------------------------------
# A055087 -- X coord
{
  my $anum = 'A055087';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::DiagonalsOctant->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $x;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A055086 -- X+Y
{
  my $anum = 'A055086';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::DiagonalsOctant->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $x+$y;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A082375 -- Y-X
{
  my $anum = 'A082375';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::DiagonalsOctant->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $y-$x;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
exit 0;
