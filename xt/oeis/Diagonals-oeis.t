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
plan tests => 2;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

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


#------------------------------------------------------------------------------
# A038722 -- permutation N at transpose Y,X, n_start=1
{
  my $anum = 'A038722';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my @got;
    if ($bvalues) {
      my $path = Math::PlanePath::Diagonals->new;
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
          1, "$anum -- permutation transpose");
  }
  {
    my @got;
    if ($bvalues) {
      my $path = Math::PlanePath::Diagonals->new (direction => 'up');
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
          1, "$anum -- permutation transpose");
  }
}

#------------------------------------------------------------------------------
# A061579 -- permutation N at transpose Y,X
{
  my $anum = 'A061579';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  {
    my @got;
    if ($bvalues) {
      my $path = Math::PlanePath::Diagonals->new (n_start => 0);
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
          1, "$anum -- permutation transpose");
  }
  {
    my @got;
    if ($bvalues) {
      my $path = Math::PlanePath::Diagonals->new (n_start => 0,
                                                  direction => 'up');
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
          1, "$anum -- permutation transpose");
  }
}

#------------------------------------------------------------------------------
exit 0;
