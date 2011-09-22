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
BEGIN { plan tests => 7 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::RationalsTree;

# uncomment this to run the ### lines
#use Devel::Comments '###';

# A059893 - bit reverse all but the high 1
# A162911 - drib tree numerators
# A162912 - drib tree denominators

sub numeq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  while (@$a1 && @$a2) {
    if ($a1->[0] ne $a2->[0]) {
      return 0;
    }
    shift @$a1;
    shift @$a2;
  }
  return (@$a1 == @$a2);
}

#------------------------------------------------------------------------------
# A002487 -- CW numerators are Stern diatomic

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my $anum = 'A002487';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    shift @$bvalues; # beginning at N=1
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $x;
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- CW tree numerators as Stern diatomic");
}

#------------------------------------------------------------------------------
# A002487 -- CW denominators are Stern diatomic, with extra 1

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my $anum = 'A002487';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    splice @$bvalues, 0,2;   # beginning at N=2
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $y;
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- CW tree denominators as Stern diatomic");
}

#------------------------------------------------------------------------------
# A162909 -- Bird tree numerators

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
  my $anum = 'A162909';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $x;
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Bird tree numerators");
}

#------------------------------------------------------------------------------
# A162910 -- Bird tree denominators

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
  my $anum = 'A162910';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $y;
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Bird tree denominators");
}

#------------------------------------------------------------------------------
# A162911 -- Drib tree numerators

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Drib');
  my $anum = 'A162911';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $x;
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Drib tree numerators");
}

#------------------------------------------------------------------------------
# A162911 -- Drib tree numerators - Bird tree reverse N

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
  my $anum = 'A162911';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy (_reverse ($n));
      push @got, $x;
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Drib tree numerators by bit reversal");
}

sub _reverse {
  my ($n) = @_;
  my $rev = 1;
  while ($n > 1) {
    $rev = 2*$rev + ($n % 2);
    $n = int($n/2);
  }
  return $rev;
}

#------------------------------------------------------------------------------
# A162912 -- Drib tree denominators

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
  my $anum = 'A162912';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy (_reverse ($n));
      push @got, $y;
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Drib tree denominators by bit reversal");
}

#------------------------------------------------------------------------------
exit 0;
