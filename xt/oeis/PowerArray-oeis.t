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
use Test;
plan tests => 14;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::PowerArray;

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

#------------------------------------------------------------------------------
# A067251 -- radix=10, N on Y axis, no trailing 0 digits
{
  my $anum = 'A067251';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::PowerArray->new (radix => 10);
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n(0,$y);
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
# A153733 remove trailing 1s
{
  my $anum = 'A153733';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $power = Math::PlanePath::PowerArray->new;
    for (my $n = $power->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $power->n_to_xy ($n);
      push @got, 2*$y;
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
# A000265 -- 2*Y+1, odd part of n dividing out factors of 2
{
  my $anum = 'A000265';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $power = Math::PlanePath::PowerArray->new;
    for (my $n = $power->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $power->n_to_xy ($n);
      push @got, 2*$y+1;
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
# A094267 -- dX
{
  my $anum = 'A094267';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::PowerArray->new (radix => 2);
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($dx,$dy) = $path->n_to_dxdy($n);
      push @got, $dx;
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
# A108715 -- dY
{
  my $anum = 'A108715';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::PowerArray->new (radix => 2);
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($dx,$dy) = $path->n_to_dxdy($n);
      push @got, $dy;
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
# A118417 -- N on X=Y+1 diagonal
{
  my $anum = 'A118417';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::PowerArray->new (radix => 2);
    require Math::BigInt;
    for (my $i = Math::BigInt->new(0); @got < @$bvalues; $i++) {
      push @got, $path->xy_to_n($i+1,$i);
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
# A005408 -- N on Y axis, odd numbers
{
  my $anum = 'A005408';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::PowerArray->new;
    for (my $y = 0; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n(0,$y);
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
# A057716 -- N not on X axis, the non 2^X
{
  my $anum = 'A057716';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got = (0); # extra 0
  if ($bvalues) {
    my $path = Math::PlanePath::PowerArray->new (radix => 2);
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      if ($y != 0) {
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
        1,
        "$anum");
}

#------------------------------------------------------------------------------
# A135765 -- odd numbers radix 3, down from Y axis
#
# 0     1 2     3 4      5  6
# 0 . . 3 4 . . 7 8 . . 11 12
# 2*y+($y%2)
#
# math-image --all --wx --path=PowerArray,radix=3 --output=numbers --size=15x20
#
# A135765 odd numbers by factors of 3
# product A000244 3^n, A007310 1or5 mod 6 is LCF>=5
#    1     5     7   11   13   17  19  23  25  29
#    3    15    21   33   39   51  57  69  75
#    9    25    63   99  117  153 171 207
#   27   135   189  297  351  459 513
#   81   405   567  891 1053 1377
#  243  1215  1701 2673 3159
#  729  3645  5103 8019
# 2187 10935 15309
# 6561 32805
#

{
  my $anum = 'A135765';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::PlanePath::Diagonals;
    my $diagonals  = Math::PlanePath::Diagonals->new (direction => 'down');
    my $power = Math::PlanePath::PowerArray->new (radix => 3);
    for (my $n = $diagonals->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonals->n_to_xy ($n);
      $y = 2*$y+($y%2); # stretch
      push @got, $power->xy_to_n($x,$y);
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
# A006519 -- 2^X coord
{
  my $anum = 'A006519';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::PowerArray->new (radix => 2);
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, 2**$x;
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
# A025480 -- Y coord
{
  my $anum = 'A025480';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::PowerArray->new (radix => 2);
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $y;
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
# A003602 -- Y+1 coord, k for which N=(2k-1)*2^m
{
  my $anum = 'A003602';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::PowerArray->new (radixt => 2);
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $y+1;
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
# A054582 -- dispersion traversed by diagonals, up from X axis
{
  my $anum = 'A054582';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::PlanePath::Diagonals;
    my $diagonals  = Math::PlanePath::Diagonals->new (direction => 'up');
    my $power = Math::PlanePath::PowerArray->new;
    for (my $n = $diagonals->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonals->n_to_xy ($n);
      push @got, $power->xy_to_n($x,$y);
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
# A075300 -- dispersion traversed by diagonals, minus 1, so starts from 0
{
  my $anum = 'A075300';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::PlanePath::Diagonals;
    my $diagonals  = Math::PlanePath::Diagonals->new (direction => 'up',
                                                      n_start => 0);
    my $power = Math::PlanePath::PowerArray->new;
    for (my $n = $diagonals->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonals->n_to_xy ($n);
      push @got, $power->xy_to_n($x,$y);
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
# A135764 -- dispersion traversed by diagonals, down from Y axis
{
  my $anum = 'A135764';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::PlanePath::Diagonals;
    my $diagonals  = Math::PlanePath::Diagonals->new (direction => 'down');
    my $power = Math::PlanePath::PowerArray->new;
    for (my $n = $diagonals->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonals->n_to_xy ($n);
      push @got, $power->xy_to_n($x,$y);
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
exit 0;
