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
use warnings;
use Test::More tests => 8;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::KnightSpiral;
use Math::PlanePath::SquareSpiral;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $knight = Math::PlanePath::KnightSpiral->new;
my $square = Math::PlanePath::SquareSpiral->new;

#------------------------------------------------------------------------------

# A068608 - same first step
SKIP: {
  my $anum = 'A068608';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (1 .. @$bvalues) {
    my ($x, $y) = $knight->n_to_xy ($n);
    push @got, $square->xy_to_n ($x, $y);
  }
  is_deeply (\@got, $bvalues, "$anum");
}

# A068609 - rotate 90 degrees
SKIP: {
  my $anum = 'A068609';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  # typo duplicated 37 in A068609.html in Jan 2011
  if (scalar(grep {$_==37} @$bvalues) > 1) {
    skip "$anum has duplicate 37", 1;
  }

  my @got;
  foreach my $n (1 .. @$bvalues) {
    my ($x, $y) = $knight->n_to_xy ($n);
    ### knight: "$n  $x,$y"
    ($x, $y) = (-$y, $x);
    push @got, $square->xy_to_n ($x, $y);
    ### rotated: "$x,$y"
    ### is: "got[$#got] = $got[-1]"
  }
  is_deeply (\@got, $bvalues, "$anum");
}

# A068610 - rotate 180 degrees
SKIP: {
  my $anum = 'A068610';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (1 .. @$bvalues) {
    my ($x, $y) = $knight->n_to_xy ($n);
    ($x, $y) = (-$x, -$y);
    push @got, $square->xy_to_n ($x, $y);
  }
  is_deeply (\@got, $bvalues, "$anum");
}

# A068611 - rotate 270 degrees
SKIP: {
  my $anum = 'A068611';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (1 .. @$bvalues) {
    my ($x, $y) = $knight->n_to_xy ($n);
    ($x, $y) = ($y, -$x);
    push @got, $square->xy_to_n ($x, $y);
  }
  is_deeply (\@got, $bvalues, "$anum");
}

# A068612 - rotate 180 degrees, opp direction, being X negated
SKIP: {
  my $anum = 'A068612';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (1 .. @$bvalues) {
    my ($x, $y) = $knight->n_to_xy ($n);
    $x = -$x;
    push @got, $square->xy_to_n ($x, $y);
  }
  is_deeply (\@got, $bvalues, "$anum");
}

# A068613 -
SKIP: {
  my $anum = 'A068613';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (1 .. @$bvalues) {
    my ($x, $y) = $knight->n_to_xy ($n);
    ($x, $y) = (-$y, -$x);
    push @got, $square->xy_to_n ($x, $y);
  }
  is_deeply (\@got, $bvalues, "$anum");
}

# A068614 - clockwise, Y negated
SKIP: {
  my $anum = 'A068614';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (1 .. @$bvalues) {
    my ($x, $y) = $knight->n_to_xy ($n);
    $y = -$y;
    push @got, $square->xy_to_n ($x, $y);
  }
  is_deeply (\@got, $bvalues, "$anum");
}

# A068615 - transpose
SKIP: {
  my $anum = 'A068615';
  my $bvalues = MyOEIS::read_values($anum)
    || skip "$anum not available", 1;

  my @got;
  foreach my $n (1 .. @$bvalues) {
    my ($x, $y) = $knight->n_to_xy ($n);
    ($y, $x) = ($x, $y);
    push @got, $square->xy_to_n ($x, $y);
  }
  is_deeply (\@got, $bvalues, "$anum");
}

exit 0;
