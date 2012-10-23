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
use Math::Prime::XS 0.23 'is_prime'; # version 0.23 fix for 1928099

use Test;
plan tests => 4;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::ToothpickTree;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::ToothpickTree->new;

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
# tree

{
  my @tree_level_children = ([], [$path->n_start]);
  sub tree_level_children {
    my ($level) = @_;
    while ($#tree_level_children < $level) {
      ### extend: join(',',@{$tree_level_children[-1]})
      my @children;
      foreach my $n (@{$tree_level_children[-1]}) {
        push @children, $path->tree_n_children($n);
      }
      if (scalar(@children) == 0) {
        die "Oops, no children at $#tree_level_children";
      }
      push @tree_level_children, \@children;

      # compare tree_level_n_range()
      {
        my $num_children = scalar(@children);
        my $this_level = $#tree_level_children - 1;
        my ($n_lo, $n_hi) = $path->_UNTESTED__tree_level_n_range($this_level);
        my $n_width = $n_hi - $n_lo + 1;
        # MyTestHelpers::diag ("this_level=$this_level num_children=$num_children n_width=$n_width ($n_lo to $n_hi)");
        if ($n_width != $num_children) {
          die "Oops, this_level=$this_level num_children=$num_children n_width=$n_width ($n_lo to $n_hi)";
        }
      }
    }
    return @{$tree_level_children[$level]};  # list of n values
  }
}


#------------------------------------------------------------------------------
# A152998 - parts=2 total cells

{
  my $anum = 'A152998';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::ToothpickTree->new (parts => 2);
    my @got;
    my $total = 0;
    for (my $depth = 0; @got < @$bvalues; $depth++) {
      push @got, $path->tree_depth_to_n($depth);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A152999 primes among parts=2 total cells

{
  my $anum = 'A152999';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::ToothpickTree->new (parts => 2);
    my @got;
    my $total = 0;
    for (my $depth = 0; @got < @$bvalues; $depth++) {
      my $n = $path->tree_depth_to_n($depth);
      if (is_prime ($n)) {
        push @got, $n;
      }
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A139250 - parts=4 total cells

{
  my $anum = 'A139250';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_count => 500);

  {
    my $diff;
    if ($bvalues) {
      my $path = Math::PlanePath::ToothpickTree->new (parts => 4);
      my @got;
      my $total = 0;
      for (my $depth = 0; @got < @$bvalues; $depth++) {
        push @got, $path->tree_depth_to_n($depth);
      }
      $diff = diff_nums(\@got, $bvalues);
      if ($diff) {
        MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
        MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
      }
    }
    skip (! $bvalues,
          $diff,
          undef,
          "$anum");
  }
  # {
  # my $diff;
  # if ($bvalues) {
  #   my @got;
  #   my $total = 0;
  #   for (my $level = 0; @got < @$bvalues; $level++) {
  #     my @children = tree_level_children($level);
  #     $total += scalar(@children);
  #     push @got, $total;
  #   }
  #   $diff = diff_nums(\@got, $bvalues);
  #   if ($diff) {
  #     MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
  #     MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
  #   }
  # }
  # skip (! $bvalues,
  #       $diff,
  #       undef,
  #       "$anum");
  # }
}


#------------------------------------------------------------------------------
# A153000 - parts=1 total cells

{
  my $anum = 'A153000';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::ToothpickTree->new (parts => 1);
    my @got;
    my $total = 0;
    for (my $depth = 0; @got < @$bvalues; $depth++) {
      push @got, $path->tree_depth_to_n($depth);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

exit 0;


#------------------------------------------------------------------------------
# A139253 - primes in A139250 total cells

{
  my $anum = 'A139253';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_value => 20000);

  my $diff;
  if ($bvalues) {
    my @got;
    my $total = 0;
    for (my $level = 0; @got < @$bvalues; $level++) {
      my @children = tree_level_children($level);
      $total += scalar(@children);
      if (is_prime($total)) {
        push @got, $total;
      }
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A153000 total in first quad

{
  my $anum = 'A153000';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_count => 100);

  my $diff;
  if ($bvalues) {
    my @got;
    my $total = 0;
    for (my $level = 2; @got < @$bvalues; $level++) {
      my @children = tree_level_children($level);
      my $added = scalar(@children);
      if ($level == 2) {
        $total += 0;
      } else {
        $added % 4 == 0 or die;
        $total += $added / 4;
      }
      push @got, $total;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}


#------------------------------------------------------------------------------
# A152968 - cells added / 2, starting level 2 where all even

{
  my $anum = 'A152968';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_count => 100);

  my $diff;
  if ($bvalues) {
    my @got;
    for (my $level = 2; @got < @$bvalues; $level++) {
      my @children = tree_level_children($level);
      push @got, scalar(@children) / 2;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A152978 - cells added / 4, starting level 3 where all multiples of 4

{
  my $anum = 'A152978';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_count => 100);

  my $diff;
  if ($bvalues) {
    my @got;
    for (my $level = 3; @got < @$bvalues; $level++) {
      my @children = tree_level_children($level);
      push @got, scalar(@children) / 4;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A147614 grid points if length 2

{
  my $anum = 'A147614';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_count => 100);

  my $diff;
  if ($bvalues) {
    my @got;
    my %seen;
    for (my $level = 0; @got < @$bvalues; $level++) {
      my @children = tree_level_children($level);
      foreach my $n (@children) {
        my ($x,$y) = $path->n_to_xy($n);
        $seen{"$x,$y"} = 1;
        if (($x+$y) % 2) {
          $seen{($x+1).",$y"} = 1;
          $seen{($x-1).",$y"} = 1;
        } else {
          $seen{"$x,".($y+1)} = 1;
          $seen{"$x,".($y-1)} = 1;
        }
      }
      push @got, scalar(keys %seen);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}


#------------------------------------------------------------------------------
# A139251 - cells added

{
  my $anum = 'A139251';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_count => 100);

  my $diff;
  if ($bvalues) {
    my @got;
    for (my $level = 0; @got < @$bvalues; $level++) {
      my @children = tree_level_children($level);
      push @got, scalar(@children);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
exit 0;
