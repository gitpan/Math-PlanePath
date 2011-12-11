#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

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
BEGIN { plan tests => 5 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::DiagonalRationals;

# uncomment this to run the ### lines
#use Smart::Comments '###';


MyTestHelpers::diag ("OEIS dir ",MyOEIS::oeis_dir());

my $cantor = Math::PlanePath::DiagonalRationals->new;

sub streq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  while (@$a1 && @$a2) {
    if ($a1->[0] ne $a2->[0]) {
      MyTestHelpers::diag ("differ: ", $a1->[0], ' ', $a2->[0]);
      return 0;
    }
    shift @$a1;
    shift @$a2;
  }
  return (@$a1 == @$a2);
}


#------------------------------------------------------------------------------
# A020652 - numerators
{
  my $anum = 'A020652';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    splice @$bvalues, 5000; # trim down
    foreach my $n (1 .. @$bvalues) {
      my ($x,$y) = $cantor->n_to_xy ($n);
      push @got, $x;
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }

  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A020653 - denominators
{
  my $anum = 'A020653';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    splice @$bvalues, 5000; # trim down
    foreach my $n (1 .. @$bvalues) {
      my ($x,$y) = $cantor->n_to_xy ($n);
      push @got, $y;
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }

  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A054424 - permutation diagonal N -> SB N 
# A054426 - inverse SB N -> Cantor N 

{
  my $anum = 'A054424';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::PlanePath::RationalsTree;
    my $sb = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
    foreach my $n (1 .. @$bvalues) {
      my ($x,$y) = $cantor->n_to_xy ($n);
      push @got, $sb->xy_to_n($x,$y);
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }

  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}
{
  my $anum = 'A054426';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::PlanePath::RationalsTree;
    my $sb = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
    foreach my $n (1 .. @$bvalues) {
      my ($x,$y) = $sb->n_to_xy ($n);
      push @got, $cantor->xy_to_n($x,$y);
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }

  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A054425 - A054424 mapping expanded out to 0s at common-factor X,Y

{
  my $anum = 'A054425';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::PlanePath::Diagonals;
    require Math::PlanePath::RationalsTree;
    my $diag = Math::PlanePath::Diagonals->new;
    my $sb = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
    my $n = 1;
    while (@got < @$bvalues) {
      my ($x,$y) = $diag->n_to_xy($n++);
      $x++;
      $y++;
      ### frac: "$x/$y"
      my $cn = $cantor->xy_to_n ($x,$y);
      if (defined $cn) {
        push @got, $sb->xy_to_n($x,$y);
      } else {
        push @got, 0;
      }
    }
    ### bvalues: join(',',@{$bvalues}[0..40])
    ### got: '    '.join(',',@got[0..40])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }

  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}


exit 0;
