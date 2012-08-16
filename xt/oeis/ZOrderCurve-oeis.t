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
plan tests => 8;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::ZOrderCurve;
use Math::PlanePath::Diagonals;

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
# A163328 -- radix=3 diagonals same axis
{
  my $anum = 'A163328';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $zorder   = Math::PlanePath::ZOrderCurve->new (radix => 3);
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'up',
                                                    n_start => 0);
    for (my $n = $diagonal->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal->n_to_xy ($n);
      push @got, $zorder->xy_to_n ($x, $y);
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

# A163329 -- radix=3 diagonals same axis, inverse
{
  my $anum = 'A163329';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $zorder   = Math::PlanePath::ZOrderCurve->new (radix => 3);
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'up',
                                                    n_start => 0);
    for (my $n = $zorder->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $zorder->n_to_xy ($n);
      push @got, $diagonal->xy_to_n ($x, $y);
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
# A163330 -- radix=3 diagonals opposite axis
{
  my $anum = 'A163330';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $zorder   = Math::PlanePath::ZOrderCurve->new (radix => 3);
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'down',
                                                    n_start => 0);
    for (my $n = $diagonal->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal->n_to_xy ($n);
      push @got, $zorder->xy_to_n ($x, $y);
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

# A163331 -- radix=3 diagonals same axis, inverse
{
  my $anum = 'A163331';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $zorder   = Math::PlanePath::ZOrderCurve->new (radix => 3);
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'down',
                                                    n_start => 0);
    for (my $n = $zorder->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $zorder->n_to_xy ($n);
      push @got, $diagonal->xy_to_n ($x, $y);
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
# A054238 -- diagonals same axis
{
  my $anum = 'A054238';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $zorder   = Math::PlanePath::ZOrderCurve->new;
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'up',
                                                    n_start => 0);
    for (my $n = $diagonal->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal->n_to_xy ($n);
      push @got, $zorder->xy_to_n ($x, $y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A054239 -- diagonals same axis, inverse
{
  my $anum = 'A054239';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $zorder   = Math::PlanePath::ZOrderCurve->new;
    my $diagonal = Math::PlanePath::Diagonals->new (direction => 'up',
                                                    n_start => 0);
    for (my $n = $zorder->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $zorder->n_to_xy ($n);
      push @got, $diagonal->xy_to_n ($x, $y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}


#------------------------------------------------------------------------------
# A057300 -- N at transpose Y,X, radix=2

{
  my $anum = 'A057300';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::ZOrderCurve->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      ($x, $y) = ($y, $x);
      my $n = $path->xy_to_n ($x, $y);
      push @got, $n;
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
# A163327 -- N at transpose Y,X, radix=3

{
  my $anum = 'A163327';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $path = Math::PlanePath::ZOrderCurve->new (radix => 3);
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      ($x, $y) = ($y, $x);
      my $n = $path->xy_to_n ($x, $y);
      push @got, $n;
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

exit 0;
