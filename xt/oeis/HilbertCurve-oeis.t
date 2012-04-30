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
use List::Util 'min', 'max';
use Test;
plan tests => 46;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::HilbertCurve;
use Math::PlanePath::Diagonals;
use Math::PlanePath::ZOrderCurve;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $hilbert  = Math::PlanePath::HilbertCurve->new;
my $diagonal = Math::PlanePath::Diagonals->new;
my $zorder   = Math::PlanePath::ZOrderCurve->new;

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

sub zorder_perm {
  my ($n) = @_;
  my ($x, $y) = $zorder->n_to_xy ($n);
  return $hilbert->xy_to_n ($x, $y);
}
sub zorder_perm_inverse {
  my ($n) = @_;
  my ($x, $y) = $hilbert->n_to_xy ($n);
  return $zorder->xy_to_n ($x, $y);
}
sub zorder_perm_rep {
  my ($n, $reps) = @_;
  foreach (1 .. $reps) {
    my ($x, $y) = $zorder->n_to_xy ($n);
    $n = $hilbert->xy_to_n ($x, $y);
  }
  return $n;
}
sub zorder_cycle_length {
  my ($n) = @_;
  my $count = 1;
  my $p = $n;
  for (;;) {
    $p = zorder_perm($p);
    if ($p == $n) {
      last;
    }
    $count++;
  }
  return $count;
}
sub zorder_is_2cycle {
  my ($n) = @_;
  my $p1 = zorder_perm($n);
  if ($p1 == $n) { return 0; }
  my $p2 = zorder_perm($p1);
  return ($p2 == $n);
}
sub zorder_is_3cycle {
  my ($n) = @_;
  my $p1 = zorder_perm($n);
  if ($p1 == $n) { return 0; }
  my $p2 = zorder_perm($p1);
  if ($p2 == $n) { return 0; }
  my $p3 = zorder_perm($p2);
  return ($p3 == $n);
}


#------------------------------------------------------------------------------
# A163891 - positions where cycle length some new previously unseen value
#
# len: 1, 1, 2, 2, 6, 3, 3, 6, 6, 6, 3, 3, 6, 3, 6, 3, 1, 3, 3, 3, 1, 1, 2, 2,
#      ^
# 91:  0     2     4  5
{
  my $anum = 'A163891';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    $#$bvalues = 20;
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    my %seen;
    for (my $n = 0; @got < @$bvalues; $n++) {
      my $len = zorder_cycle_length($n);
      if (! $seen{$len}) {
        push @got, $n;
        $seen{$len} = 1;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..10]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..10]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
       "$anum - cycle length by N");
}

#------------------------------------------------------------------------------
# A163893 - first diffs of positions where cycle length some new unseen value
{
  my $anum = 'A163893';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    $#$bvalues = 20;
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    my %seen = (1 => 1);
    my $prev = 0;
    for (my $n = 0; @got < @$bvalues; $n++) {
      my $len = zorder_cycle_length($n);
      if (! $seen{$len}) {
        push @got, $n-$prev;
        $prev = $n;
        $seen{$len} = 1;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..10]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..10]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
       "$anum - cycle length by N");
}


#------------------------------------------------------------------------------
# A163896 - value where A163894 is a new high

{
  my $anum = 'A163896';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    $#$bvalues = 8; # shorten

    my $high = -1;
    for (my $n = 0; @got < @$bvalues; $n++) {
      my $value = A163894_perm_n_not($n);
      if ($value > $high) {
        $high = $value;
        push @got, $value;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..6]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..6]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163895 - position where A163894 is a new high

{
  my $anum = 'A163895';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    $#$bvalues = 8; # shorten

    my $high = -1;
    for (my $n = 0; @got < @$bvalues; $n++) {
      my $value = A163894_perm_n_not($n);
      if ($value > $high) {
        $high = $value;
        push @got, $n;
      }
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..6]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..6]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163894 - first i for which (perm^n)[i] != i

{
  my $anum = 'A163894';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    $#$bvalues = 200; # shorten

    for (my $n = 0; @got < @$bvalues; $n++) {
      push @got, A163894_perm_n_not($n);
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..7]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..7]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

sub A163894_perm_n_not {
  my ($n) = @_;
  if ($n == 0) {
    return 0;
  }
  for (my $i = 0; ; $i++) {
    my $p = zorder_perm_rep ($i, $n);
    if ($p != $i) {
      return $i;
    }
  }
}

#------------------------------------------------------------------------------
# A163909 - num 3-cycles in 4^k blocks, even k only

{
  my $anum = 'A163909';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    $#$bvalues = 5; # shorten
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my $target = 1;
    my $target_even = 1;
    my $count = 0;
    my @seen;
    for (my $n = 0; @got < @$bvalues; $n++) {
      if ($n >= $target) {
        if ($target_even) {
          push @got, $count;
        }
        $target_even ^= 1;
        $count = 0;
        $target *= 4;
        @seen = ();
        $#seen = $target; # pre-extend
      }

      unless ($seen[$n]) {
        my $p1 = zorder_perm($n);
        next if $p1 == $n; # a fixed point
        my $p2 = zorder_perm($p1);
        next if $p2 == $n; # a 2-cycle
        my $p3 = zorder_perm($p2);
        next unless $p3 == $n; # not a 3-cycle
        $count++;
        $seen[$n] = 1;
        $seen[$p1] = 1;
        $seen[$p2] = 1;
      }
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..7]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..7]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163914 - num 3-cycles in 4^k blocks
{
  my $anum = 'A163914';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    $#$bvalues = 8; # shorten
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my $target = 1;
    my $count = 0;
    my @seen;
    for (my $n = 0; @got < @$bvalues; $n++) {
      if ($n >= $target) {
        push @got, $count;
        $count = 0;
        $target *= 4;
        @seen = ();
        $#seen = $target; # pre-extend
      }

      unless ($seen[$n]) {
        my $p1 = zorder_perm($n);
        next if $p1 == $n; # a fixed point
        my $p2 = zorder_perm($p1);
        next if $p2 == $n; # a 2-cycle
        my $p3 = zorder_perm($p2);
        next unless $p3 == $n; # not a 3-cycle
        $count++;
        $seen[$n] = 1;
        $seen[$p1] = 1;
        $seen[$p2] = 1;
      }
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..10]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..10]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163908 - perm twice, by diagonals, inverse

{
  my $anum = 'A163908';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    for (my $n = 0; @got < @$bvalues; $n++) {
      my $nn = zorder_perm_inverse(zorder_perm_inverse($n));
      my ($x, $y) = $zorder->n_to_xy ($nn);
      ($x,$y) = ($y,$x);    # same axis as Hilbert
      my $dn = $diagonal->xy_to_n ($x, $y);
      push @got, $dn-1;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
       "$anum - double-perm by diagonals, inverse");
}

#------------------------------------------------------------------------------
# A163907 - perm twice, by diagonals

{
  my $anum = 'A163907';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    for (my $dn = $diagonal->n_start; @got < @$bvalues; $dn++) {
      my ($x, $y) = $diagonal->n_to_xy ($dn);
      ($x,$y) = ($y,$x);    # same axis as Hilbert
      my $n = $zorder->xy_to_n ($x, $y);
      push @got, zorder_perm(zorder_perm($n));
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
       "$anum - double-perm by diagonals");
}

#------------------------------------------------------------------------------
# A163904 - cycle length by diagonals

{
  my $anum = 'A163904';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    for (my $dn = $diagonal->n_start; @got < @$bvalues; $dn++) {
      my ($x, $y) = $diagonal->n_to_xy ($dn);
      ($x,$y) = ($y,$x);    # same axis as Hilbert
      my $hn = $hilbert->xy_to_n ($x, $y);
      push @got, zorder_cycle_length($hn);
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
       "$anum - cycle length by diagonals");
}

#------------------------------------------------------------------------------
# A163890 - cycle length by N
{
  my $anum = 'A163890';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    $#$bvalues = 10000; # shorten
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    for (my $n = 0; @got < @$bvalues; $n++) {
      push @got, zorder_cycle_length($n);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
       "$anum - cycle length by N");
}

#------------------------------------------------------------------------------
# A163900 - squared distance between Hilbert and Z order

{
  my $anum = 'A163900';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    for (my $n = 0; @got < @$bvalues; $n++) {
      my ($hx, $hy) = $hilbert->n_to_xy ($n);
      my ($zx, $zy) = $zorder->n_to_xy ($n);
      my $dx = $hx - $zx;
      my $dy = $hy - $zy;
      push @got, $dx**2 + $dy**2;
    }
    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..7]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..7]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1,
       "$anum - squared distance between Hilbert and ZOrder");
}

#------------------------------------------------------------------------------
# A163912 - LCM of cycle lengths in 4^k blocks

{
  my $anum = 'A163912';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    $#$bvalues = 6; # shorten

    my $target = 1;
    my $max = 0;
    my %lengths;
    for (my $n = 0; @got < @$bvalues; $n++) {
      if ($n >= $target) {
        push @got, lcm(keys %lengths);
        $target *= 4;
        %lengths = ();
      }
      $lengths{zorder_cycle_length($n)} = 1;
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..7]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..7]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

use Math::PlanePath::GcdRationals;
sub lcm {
  my $lcm = 1;
  foreach my $n (@_) {
    my $gcd = Math::PlanePath::GcdRationals::_gcd($lcm,$n);
    $lcm = $lcm * $n / $gcd;
  }
  return $lcm;
}

#------------------------------------------------------------------------------
# A163911 - max cycle in 4^k blocks
{
  my $anum = 'A163911';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    $#$bvalues = 7; # shorten

    my $target = 1;
    my $max = 0;
    for (my $n = 0; @got < @$bvalues; $n++) {
      if ($n >= $target) {
        push @got, $max;
        $max = 0;
        $target *= 4;
      }
      $max = max ($max, zorder_cycle_length($n));
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..10]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..10]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}




# #------------------------------------------------------------------------------
# # A147600 - num fixed points in 4^k blocks
# {
#   my $anum = 'A147600';
#   my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
#   my @got;
#   if ($bvalues) {
#     MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
#     # $#$bvalues = 9;
# 
#     my $target = 1;
#     my $count = 0;
#     for (my $n = 0; @got < @$bvalues; $n++) {
#       if ($n >= $target) {
#         push @got, $count;
#         $count = 0;
#         $target *= 4;
#       }
# 
#       if ($n == zorder_perm($n)) {
#         $count++;
#       }
#     }
# 
#     if (! numeq_array(\@got, $bvalues)) {
#       MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..10]));
#       MyTestHelpers::diag ("got:     ",join(',',@got[0..10]));
#     }
#   } else {
#     MyTestHelpers::diag ("$anum not available");
#   }
#   skip (! $bvalues,
#         numeq_array(\@got, $bvalues),
#         1);
# }

#------------------------------------------------------------------------------
# A163910 - num cycles in 4^k blocks
{
  my $anum = 'A163910';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    $#$bvalues = 9;

    my $target = 1;
    my $count = 0;
    my @seen;
    for (my $n = 0; @got < @$bvalues; $n++) {
      if ($n >= $target) {
        push @got, $count;
        $count = 0;
        $target *= 4;
        @seen = ();
        $#seen = $target; # pre-extend
      }

      $count++;
      my $p = $n;
      for (;;) {
        $p = zorder_perm($p);
        if ($seen[$p]) {
          $count--;
          last;
        }
        $seen[$p] = 1;
        last if $p == $n;
      }
      $seen[$n] = 1;
    }

    if (! numeq_array(\@got, $bvalues)) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..10]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..10]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163355 - in Z order sequence

{
  my $anum = 'A163355';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (0 .. $#$bvalues) {
      push @got, zorder_perm($n);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - ZOrder");
}

# A163356 - inverse
{
  my $anum = 'A163356';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      push @got, $zorder->xy_to_n ($x, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163905 - applied twice
{
  my $anum = 'A163905';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (0 .. $#$bvalues) {
      push @got, zorder_perm(zorder_perm($n));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163915 - applied three times
{
  my $anum = 'A163915';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (0 .. $#$bvalues) {
      push @got, zorder_perm(zorder_perm(zorder_perm($n)));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163901 - fixed-point N values
{
  my $anum = 'A163901';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    for (my $n = 0; @got < @$bvalues; $n++) {
      if (zorder_perm($n) == $n) {
        push @got, $n;
      }
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163902 - 2-cycle N values
{
  my $anum = 'A163902';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    for (my $n = 0; @got < @$bvalues; $n++) {
      if (zorder_is_2cycle($n)) {
        push @got, $n;
      }
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163903 - 3-cycle N values
{
  my $anum = 'A163903';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    for (my $n = 0; @got < @$bvalues; $n++) {
      if (zorder_is_3cycle($n)) {
        push @got, $n;
      }
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A062880 -- diagonal X=Y is base 4 digits 0,2 only
{
  my $anum = 'A062880';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    for (my $i = 0; @got < @$bvalues; $i++) {
      push @got, $hilbert->xy_to_n ($i,$i);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- column at X=0");
}

#------------------------------------------------------------------------------
# A059252 - Y coord

{
  my $anum = 'A059252';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      push @got, $y;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - Y coord");
}

# A059253 - X coord
{
  my $anum = 'A059253';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      push @got, $x;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - X coord");
}

# A059261 - X+Y
{
  my $anum = 'A059261';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      push @got, $x+$y;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - X+Y");
}

# A059285 - X-Y
{
  my $anum = 'A059285';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      push @got, $x-$y;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - X-Y");
}

# A163547 - X^2+Y^2
{
  my $anum = 'A163547';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      push @got, $x*$x+$y*$y;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - X^2+Y^2");
}

#------------------------------------------------------------------------------
# A163357 - in diagonal sequence

{
  my $anum = 'A163357';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (1 .. @$bvalues) {
      my ($y, $x) = $diagonal->n_to_xy ($n);     # transposed, same side
      push @got, $hilbert->xy_to_n ($x, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163358 - inverse
{
  my $anum = 'A163358';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (0 .. $#$bvalues) {
      my ($y, $x) = $hilbert->n_to_xy ($n);        # transposed, same side
      push @got, $diagonal->xy_to_n ($x, $y) - 1;  # 0-based diagonals
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163359 - in diagonal sequence, opp sides

{
  my $anum = 'A163359';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $diagonal->n_to_xy ($n);     # plain, opposite sides
      push @got, $hilbert->xy_to_n ($x, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163360 - inverse
{
  my $anum = 'A163360';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);     # plain, opposite sides
      push @got, $diagonal->xy_to_n ($x, $y) - 1;  # 0-based diagonals
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163361 - diagonal sequence, one based

{
  my $anum = 'A163361';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $diagonal->n_to_xy ($n);
      ($x, $y) = ($y, $x);                    # transpose for same side
      push @got, $hilbert->xy_to_n ($x, $y) + 1; # 1-based Hilbert
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163362 - inverse
{
  my $anum = 'A163362';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      ($x, $y) = ($y, $x);                    # transpose for same side
      push @got, $diagonal->xy_to_n ($x, $y); # 1-based Hilbert
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163363 - diagonal sequence, one based, opp sides

{
  my $anum = 'A163363';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $diagonal->n_to_xy ($n);  # no transpose for opp side
      push @got, $hilbert->xy_to_n ($x, $y) + 1;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

# A163364 - inverse
{
  my $anum = 'A163364';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);  # no transpose for opp side
      push @got, $diagonal->xy_to_n ($x, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1);
}

#------------------------------------------------------------------------------
# A163365 - diagonal sums
{
  my $anum = 'A163365';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $d (0 .. $#$bvalues) {
      my $sum = 0;
      foreach my $x (0 .. $d) {
        my $y = $d - $x;
        $sum += $hilbert->xy_to_n ($x, $y);
      }
      push @got, $sum;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - diagonal sums");
}

# A163477 - diagonal sums divided by 4
{
  my $anum = 'A163477';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $d (0 .. $#$bvalues) {
      my $sum = 0;
      foreach my $x (0 .. $d) {
        my $y = $d - $x;
        $sum += $hilbert->xy_to_n ($x, $y);
      }
      push @got, int($sum/4);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum - diagonal sums divided by 4");
}

#------------------------------------------------------------------------------
# A163482 -- row at Y=0
{
  my $anum = 'A163482';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $x (0 .. $#$bvalues) {
      push @got, $hilbert->xy_to_n ($x, 0);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- row at Y=0");
}

#------------------------------------------------------------------------------
# A163483 -- column at X=0
{
  my $anum = 'A163483';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $y (0 .. $#$bvalues) {
      push @got, $hilbert->xy_to_n (0, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- column at X=0");
}

#------------------------------------------------------------------------------
# A163538 -- delta X
# first entry is for N=0 no change
{
  my $anum = 'A163538';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    my ($prev_x, $prev_y) = (0, 0);
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      my $dx = $x - $prev_x;
      push @got, $dx;
      ($prev_x, $prev_y) = ($x, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- delta X (transpose)");
}

#------------------------------------------------------------------------------
# A163539 -- delta Y
# first entry is for N=0 no change
{
  my $anum = 'A163539';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    my ($prev_x, $prev_y) = (0, 0);
    foreach my $n (0 .. $#$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      my $dy = $y - $prev_y;
      push @got, $dy;
      ($prev_x, $prev_y) = ($x, $y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- delta Y (transpose)");
}

#------------------------------------------------------------------------------
# A163540 -- absolute direction 0=east, 1=south, 2=west, 3=north
# Y coordinates reckoned down the page, so south is Y increasing

{
  my $anum = 'A163540';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    my ($prev_x, $prev_y) = $hilbert->n_to_xy (0);
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      my $dx = $x - $prev_x;
      my $dy = $y - $prev_y;
      push @got, MyOEIS::dxdy_to_direction ($dx, $dy);
      ($prev_x,$prev_y) = ($x,$y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- absolute direction");
}

#------------------------------------------------------------------------------
# A163541 -- absolute direction transpose 0=east, 1=south, 2=west, 3=north

{
  my $anum = 'A163541';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    my ($prev_x, $prev_y) = $hilbert->n_to_xy (0);
    foreach my $n (1 .. @$bvalues) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      my $dx = $x - $prev_x;
      my $dy = $y - $prev_y;
      push @got, MyOEIS::dxdy_to_direction ($dy, $dx);
      ($prev_x,$prev_y) = ($x,$y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- absolute direction transpose");
}

#------------------------------------------------------------------------------
# A163542 -- relative direction 0=ahead, 1=right, 2=left
# Y coordinates reckoned down the page
{
  my $anum = 'A163542';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    my ($n0_x, $n0_y) = $hilbert->n_to_xy (0);
    my ($p_x, $p_y) = $hilbert->n_to_xy (1);
    my ($p_dx, $p_dy) = ($p_x - $n0_x, $p_y - $n0_y);
    foreach my $n (2 .. @$bvalues + 1) {
      my ($x, $y) = $hilbert->n_to_xy ($n);
      my $dx = ($x - $p_x);
      my $dy = ($y - $p_y);

      if ($p_dx) {
        if ($dx) {
          push @got, 0;  # ahead horizontally
        } elsif ($dy == $p_dx) {
          push @got, 1;  # right
        } else {
          push @got, 2;  # left
        }
      } else {
        # p_dy
        if ($dy) {
          push @got, 0;  # ahead horizontally
        } elsif ($dx == $p_dy) {
          push @got, 2;  # left
        } else {
          push @got, 1;  # right
        }
      }
      ### $n
      ### $p_dx
      ### $p_dy
      ### $dx
      ### $dy
      ### is: "$got[-1]   at idx $#got"

      ($p_dx,$p_dy) = ($dx,$dy);
      ($p_x,$p_y) = ($x,$y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction");
}

#------------------------------------------------------------------------------
# A163543 -- relative direction 0=ahead, 1=right, 2=left
# Y coordinates reckoned down the page

sub transpose {
  my ($x, $y) = @_;
  return ($y, $x);
}
{
  my $anum = 'A163543';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    my ($n0_x, $n0_y) = transpose ($hilbert->n_to_xy (0));
    my ($p_x, $p_y) = transpose ($hilbert->n_to_xy (1));
    my ($p_dx, $p_dy) = ($p_x - $n0_x, $p_y - $n0_y);
    foreach my $n (2 .. @$bvalues + 1) {
      my ($x, $y) = transpose ($hilbert->n_to_xy ($n));
      my $dx = ($x - $p_x);
      my $dy = ($y - $p_y);

      if ($p_dx) {
        if ($dx) {
          push @got, 0;  # ahead horizontally
        } elsif ($dy == $p_dx) {
          push @got, 1;  # right
        } else {
          push @got, 2;  # left
        }
      } else {
        # p_dy
        if ($dy) {
          push @got, 0;  # ahead horizontally
        } elsif ($dx == $p_dy) {
          push @got, 2;  # left
        } else {
          push @got, 1;  # right
        }
      }
      ### $n
      ### $p_dx
      ### $p_dy
      ### $dx
      ### $dy
      ### is: "$got[-1]   at idx $#got"

      ($p_dx,$p_dy) = ($dx,$dy);
      ($p_x,$p_y) = ($x,$y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- relative direction transposed");
}


exit 0;