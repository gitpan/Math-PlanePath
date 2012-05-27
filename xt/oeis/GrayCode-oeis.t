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

use Test;
plan tests => 10;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::GrayCode;
use Math::PlanePath::Diagonals;

# uncomment this to run the ### lines
#use Smart::Comments '###';

my $diagonal_path = Math::PlanePath::Diagonals->new;

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
# A163233 -- diagonals sF
{
  my $anum = 'A163233';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my $gray_path = Math::PlanePath::GrayCode->new
      (apply_type => 'sF');
    for (my $n = $diagonal_path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal_path->n_to_xy ($n);
      ($x, $y) = ($y, $x);
      my $n = $gray_path->xy_to_n ($x, $y);
      push @got, $n;
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
        "$anum -- diagonals sF");
}

# A163234 -- diagonals sF inverse
{
  my $anum = 'A163234';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my @got;
    my $gray_path = Math::PlanePath::GrayCode->new
      (apply_type => 'sF');
    for (my $n = $gray_path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $gray_path->n_to_xy ($n);
      ($x, $y) = ($y, $x);
      my $n = $diagonal_path->xy_to_n ($x, $y);
      push @got, $n + $gray_path->n_start - $diagonal_path->n_start;
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A163235 -- diagonals sF, opposite side start
{
  my $anum = 'A163235';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my $gray_path = Math::PlanePath::GrayCode->new
      (apply_type => 'sF');
    for (my $n = $diagonal_path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal_path->n_to_xy ($n);
      my $n = $gray_path->xy_to_n ($x, $y);
      push @got, $n;
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
        1);
}

# A163236 -- diagonals sF inverse, opposite side start
{
  my $anum = 'A163236';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $diff;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my $gray_path = Math::PlanePath::GrayCode->new
      (apply_type => 'sF');
    for (my $n = $gray_path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $gray_path->n_to_xy ($n);
      my $n = $diagonal_path->xy_to_n ($x, $y);
      push @got, $n + $gray_path->n_start - $diagonal_path->n_start;
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A163237 -- diagonals sF, same side start, flip base-4 digits 2,3

sub flip_base4_23 {
  my ($n) = @_;
  my @digits = Math::PlanePath::_digit_split_lowtohigh($n,4);
  foreach my $digit (@digits) {
    if ($digit == 2) { $digit = 3; }
    elsif ($digit == 3) { $digit = 2; }
  }
  return Math::PlanePath::GrayCode::_digit_join(\@digits,4);
}


{
  my $anum = 'A163237';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my $gray_path = Math::PlanePath::GrayCode->new
      (apply_type => 'sF');
    for (my $n = $diagonal_path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal_path->n_to_xy ($n);
      ($x, $y) = ($y, $x);
      my $n = $gray_path->xy_to_n ($x, $y);
      $n = flip_base4_23($n);
      push @got, $n;
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
        1);
}

# A163238 -- inverse
{
  my $anum = 'A163238';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $diff;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my $gray_path = Math::PlanePath::GrayCode->new
      (apply_type => 'sF');
    for (my $n = $gray_path->n_start; @got < @$bvalues; $n++) {
      my $n = flip_base4_23($n);
      my ($x, $y) = $gray_path->n_to_xy ($n);
      ($x, $y) = ($y, $x);
      $n = $diagonal_path->xy_to_n ($x, $y);
      push @got, $n + $gray_path->n_start - $diagonal_path->n_start;
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        $diff, undef);
}


#------------------------------------------------------------------------------
# A163239 -- diagonals sF, opposite side start, flip base-4 digits 2,3

{
  my $anum = 'A163239';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my $gray_path = Math::PlanePath::GrayCode->new
      (apply_type => 'sF');
    for (my $n = $diagonal_path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $diagonal_path->n_to_xy ($n);
      my $n = $gray_path->xy_to_n ($x, $y);
      $n = flip_base4_23($n);
      push @got, $n;
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
        1);
}

# A163240 -- inverse
{
  my $anum = 'A163240';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $diff;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my $gray_path = Math::PlanePath::GrayCode->new
      (apply_type => 'sF');
    for (my $n = $gray_path->n_start; @got < @$bvalues; $n++) {
      my $n = flip_base4_23($n);
      my ($x, $y) = $gray_path->n_to_xy ($n);
      $n = $diagonal_path->xy_to_n ($x, $y);
      push @got, $n + $gray_path->n_start - $diagonal_path->n_start;
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        $diff, undef);
}

#------------------------------------------------------------------------------
# A163242 -- sF diagonal sums
{
  my $anum = 'A163242';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my $gray_path = Math::PlanePath::GrayCode->new
      (apply_type => 'sF');
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $sum = 0;
      foreach my $i (0 .. $y) {
        $sum += $gray_path->xy_to_n ($i, $y-$i);
      }
      push @got, $sum;
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
        1);
}

#------------------------------------------------------------------------------
# A163478 -- sF diagonal sums, divided by 3

{
  my $anum = 'A163478';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my $gray_path = Math::PlanePath::GrayCode->new
      (apply_type => 'sF');
    for (my $y = 0; @got < @$bvalues; $y++) {
      my $sum = 0;
      foreach my $i (0 .. $y) {
        $sum += $gray_path->xy_to_n ($i, $y-$i);
      }
      push @got, $sum / 3;
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
        1);
}

#------------------------------------------------------------------------------
exit 0;
