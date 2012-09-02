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

use Math::PlanePath::EToothpickTree;

# uncomment this to run the ### lines
#use Smart::Comments '###';

my $max_count = 20;

my $snow_path = Math::PlanePath::EToothpickTree->new (start => 'snowflake');

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

sub tree_level_children {
  my ($path, $level) = @_;

  my $tree_level_children
    = ($path->{'tree_level_children'} ||= [ [], [$path->n_start] ]);

  while ($#$tree_level_children < $level) {
    ### tree_level_children() extend: join(',',@{$tree_level_children->[-1]})

    my @children;
    foreach my $n (@{$tree_level_children->[-1]}) {
      push @children, $path->tree_n_children($n);
    }
    if (scalar(@children) == 0) {
      die "Oops, no children at $#$tree_level_children";
    }
    push @$tree_level_children, \@children;

    # compare tree_level_n_range()
    {
      my $num_children = scalar(@children);
      my $this_level = $#$tree_level_children - 1;
      my ($n_lo, $n_hi) = $path->_UNTESTED__tree_level_n_range($this_level);
      my $n_width = $n_hi - $n_lo + 1;
      # MyTestHelpers::diag ("this_level=$this_level num_children=$num_children n_width=$n_width ($n_lo to $n_hi)");
      if ($n_width != $num_children) {
        ### $path
        die "Oops, this_level=$this_level num_children=$num_children n_width=$n_width (n_lo=$n_lo to n_hi=$n_hi)\n"
          . "children: ".join(',',@children);
      }
    }
  }
  return @{$tree_level_children->[$level]};  # list of n values
}

#------------------------------------------------------------------------------
# A161328 - total cells E

{
  my $anum = 'A161328';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_count => $max_count);

  my $diff;
  if ($bvalues) {
    my $e_path = Math::PlanePath::EToothpickTree->new;
    my @got;
    my $total = 0;
    for (my $level = 0; @got < @$bvalues; $level++) {
      my @children = tree_level_children($e_path,$level);
      $total += scalar(@children);
      push @got, $total;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A161329 - cells added

{
  my $anum = 'A161329';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_count => $max_count);

  my $diff;
  if ($bvalues) {
    my $e_path = Math::PlanePath::EToothpickTree->new;
    my @got;
    for (my $level = 1; @got < @$bvalues; $level++) {
      my @children = tree_level_children($e_path,$level);
      push @got, scalar(@children);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A161330 - snowflake total cells

{
  my $anum = 'A161330';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_count => $max_count);

  my $diff;
  if ($bvalues) {
    my @got;
    my $total = 0;
    for (my $level = 0; @got < @$bvalues; $level++) {
      my @children = tree_level_children($snow_path,$level);
      if ($level == 1) {
        $total++;
      }
      $total += scalar(@children);
      push @got, $total;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A161331 - snowflake cells added

{
  my $anum = 'A161331';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_count => $max_count);

  my $diff;
  if ($bvalues) {
    my @got = (2);
    for (my $level = 2; @got < @$bvalues; $level++) {
      my @children = tree_level_children($snow_path,$level);
      push @got, scalar(@children);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}


#------------------------------------------------------------------------------
# A160120 - total cells Y

{
  my $anum = 'A160120';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum); # max_count => $max_count

  my $diff;
  if ($bvalues) {
    my $y_path = Math::PlanePath::EToothpickTree->new (shape => 'Y');
    my @got;
    my $total = 0;
    for (my $level = 0; @got < @$bvalues; $level++) {
      my @children = tree_level_children($y_path,$level);
      $total += scalar(@children);
      push @got, $total;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A160121 - cells added Y

{
  my $anum = 'A160121';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);  # , max_count => $max_count

  my $diff;
  if ($bvalues) {
    my $y_path = Math::PlanePath::EToothpickTree->new (shape => 'Y');
    my @got;
    for (my $level = 1; @got < @$bvalues; $level++) {
      my @children = tree_level_children($y_path,$level);
      push @got, scalar(@children);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A161206 - total cells V

{
  my $anum = 'A161206';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum); # , max_count => $max_count

  my $diff;
  if ($bvalues) {
    my $v_path = Math::PlanePath::EToothpickTree->new (shape => 'V');
    my @got;
    my $total = 0;
    for (my $level = 0; @got < @$bvalues; $level++) {
      my @children = tree_level_children($v_path,$level);
      $total += scalar(@children);
      push @got, $total;
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A161207 - cells added V

{
  my $anum = 'A161207';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_count => $max_count);

  my $diff;
  if ($bvalues) {
    my $v_path = Math::PlanePath::EToothpickTree->new (shape => 'V');
    my @got;
    for (my $level = 1; @got < @$bvalues; $level++) {
      my @children = tree_level_children($v_path,$level);
      push @got, scalar(@children);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@$bvalues));
      MyTestHelpers::diag ("got:     ",join(',',@got));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
exit 0;
