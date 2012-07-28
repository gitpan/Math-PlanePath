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
plan tests => 6;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::FactorRationals;

# uncomment this to run the ### lines
#use Smart::Comments '###';


MyTestHelpers::diag ("OEIS dir ",MyOEIS::oeis_dir());

my $path = Math::PlanePath::FactorRationals->new;

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
# A019554 - product

{
  my $anum = 'A019554';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy ($n);
      push @got, $x * $y;
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  }

  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}


#------------------------------------------------------------------------------
# A071974 - numerators

{
  my $anum = 'A071974';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy ($n);
      push @got, $x;
    }
  }

  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A071975 - denominators

{
  my $anum = 'A071975';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy ($n);
      push @got, $y;
    }
  }

  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}


#------------------------------------------------------------------------------
# A102631 - n^2/squarefreekernel(n), is column at X=1

{
  my $anum = 'A102631';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $y = 1; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n (1, $y);
    }
  }

  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}


#------------------------------------------------------------------------------
# A060837 - permutation DiagonalRationals N -> FactorRationals N

{
  my $anum = 'A060837';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::PlanePath::DiagonalRationals;
    my $columns = Math::PlanePath::DiagonalRationals->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x,$y) = $columns->n_to_xy ($n);
      push @got, $path->xy_to_n($x,$y);
    }
  }

  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}


#------------------------------------------------------------------------------
# A071970 - permutation Stern a[i]/[ai+1] which is Calkin-Wilf N -> power N

{
  my $anum = 'A071970';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::PlanePath::RationalsTree;
    my $sb = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x,$y) = $sb->n_to_xy ($n);
      push @got, $path->xy_to_n($x,$y);
    }
  }

  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}


#------------------------------------------------------------------------------
exit 0;
