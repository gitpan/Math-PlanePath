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
plan tests => 8;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::KnightSpiral;
use Math::PlanePath::SquareSpiral;

# uncomment this to run the ### lines
#use Smart::Comments '###';


MyTestHelpers::diag ("OEIS dir ",MyOEIS::oeis_dir());

my $knight = Math::PlanePath::KnightSpiral->new;
my $square = Math::PlanePath::SquareSpiral->new;

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
# A068608 - N values in square spiral order, same first step
{
  my $anum = 'A068608';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $knight->n_to_xy ($n);
      push @got, $square->xy_to_n ($x, $y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

# A068609 - rotate 90 degrees
{
  my $anum = 'A068609';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $knight->n_to_xy ($n);
      ### knight: "$n  $x,$y"
      ($x, $y) = (-$y, $x);
      push @got, $square->xy_to_n ($x, $y);
      ### rotated: "$x,$y"
      ### is: "got[$#got] = $got[-1]"
    }
  }

  skip (! $bvalues ? "no B file"
        : 0,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

# A068610 - rotate 180 degrees
{
  my $anum = 'A068610';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $knight->n_to_xy ($n);
      ($x, $y) = (-$x, -$y);
      push @got, $square->xy_to_n ($x, $y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

# A068611 - rotate 270 degrees
{
  my $anum = 'A068611';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $knight->n_to_xy ($n);
      ($x, $y) = ($y, -$x);
      push @got, $square->xy_to_n ($x, $y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

# A068612 - rotate 180 degrees, opp direction, being X negated
{
  my $anum = 'A068612';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $knight->n_to_xy ($n);
      $x = -$x;
      push @got, $square->xy_to_n ($x, $y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

# A068613 -
{
  my $anum = 'A068613';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $knight->n_to_xy ($n);
      ($x, $y) = (-$y, -$x);
      push @got, $square->xy_to_n ($x, $y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

# A068614 - clockwise, Y negated
{
  my $anum = 'A068614';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $knight->n_to_xy ($n);
      $y = -$y;
      push @got, $square->xy_to_n ($x, $y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

# A068615 - transpose
{
  my $anum = 'A068615';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $knight->n_to_xy ($n);
      ($y, $x) = ($x, $y);
      push @got, $square->xy_to_n ($x, $y);
    }
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

exit 0;
