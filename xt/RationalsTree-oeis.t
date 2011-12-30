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
BEGIN { plan tests => 19 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::RationalsTree;

# uncomment this to run the ### lines
#use Smart::Comments '###';


# cf A059893 - bit reverse all but the high 1

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
# A000975 -- without consecutive equal bits

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Bird');
  my $anum = 'A000975';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    push @got, 0;  # extra initial 0 in A000975
    for (my $y = 1; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n (1, $y);
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A086893 -- pos of F(n+1)/F(n) in Stern diatomic

# F(n+1)/F(n) in CW
{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my $anum = 'A086893';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $f1 = 1;
    my $f0 = 1;
    while (@got < @$bvalues) {
      push @got, $path->xy_to_n ($f1, $f0);
      ($f1,$f0) = ($f1+$f0,$f1);
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

# 1/X in Drib
{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Drib');
  my $anum = 'A086893';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    for (my $x = 1; @got < @$bvalues; $x++) {
      push @got, $path->xy_to_n ($x, 1);
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}


#------------------------------------------------------------------------------
# A061547 -- pos of F(n)/F(n+1) in Stern diatomic

# F(n)/F(n+1) in CW
{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my $anum = 'A061547';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    push @got, 0;  # extra initial 0 in A061547
    my $f1 = 1;
    my $f0 = 1;
    while (@got < @$bvalues) {
      push @got, $path->xy_to_n ($f0, $f1);
      ($f1,$f0) = ($f1+$f0,$f1);
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
    ### bvalues: join(',',@{$bvalues}[0..20])
    ### got: '    '.join(',',@got[0..20])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}

# Y/1 in Drib
{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'Drib');
  my $anum = 'A061547';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    push @got, 0;  # extra initial 0 in A061547
    for (my $y = 1; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n (1, $y);
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
    ### bvalues: join(',',@{$bvalues}[0..20])
    ### got: '    '.join(',',@got[0..20])
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum");
}



#------------------------------------------------------------------------------
# A007305 -- SB numerators

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
  my $anum = 'A007305';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    splice @$bvalues,0,2; # drop initial value=0,value=1 from oeis
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
        1, "$anum -- SB tree numerators");
}

#------------------------------------------------------------------------------
# A047679 -- SB denominators

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
  my $anum = 'A047679';
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
        1, "$anum -- SB tree denominators");
}

#------------------------------------------------------------------------------
# A007306 -- SB num+den

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'SB');
  my $anum = 'A007306';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    splice @$bvalues,0,2; # drop initial value=1,value=1 from oeis
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $x+$y;
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- SB tree num+den");
}

#------------------------------------------------------------------------------
# A002487 -- CW numerators are Stern diatomic

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my $anum = 'A002487';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    shift @$bvalues; # drop initial value=0 from oeis
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
# A002487 -- CW denominators are Stern diatomic

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my $anum = 'A002487';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    splice @$bvalues, 0,2;   # drop initial value=0,value=1 from oeis
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
# A070990 -- CW Y-X is Stern diatomic first diffs

{
  my $path = Math::PlanePath::RationalsTree->new (tree_type => 'CW');
  my $anum = 'A070990';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    unshift @$bvalues, 0;   # extra 0 in RationalsTree
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $y - $x;
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- CW tree Y-X as Stern diatomic first diffs");
}

#------------------------------------------------------------------------------
# A020650 -- AYT tree numerators

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');
  my $anum = 'A020650';
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
        1, "$anum -- AYT tree numerators");
}

#------------------------------------------------------------------------------
# A162910 -- AYT tree denominators

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');
  my $anum = 'A020651';
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
        1, "$anum -- AYT tree denominators");
}

#------------------------------------------------------------------------------
# A086592 -- AYT num+den is Kepler denominators

{
  my $path  = Math::PlanePath::RationalsTree->new (tree_type => 'AYT');
  my $anum = 'A086592';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $path->n_to_xy ($n);
      push @got, $x+$y;
    }
    MyTestHelpers::diag ("$anum has $#$bvalues values");
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- AYT tree num+den, is Kepler denominators");
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
