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
plan tests => 4;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::ImaginaryBase;
use Math::PlanePath::Diagonals;
use Math::PlanePath::Base::Digits
  'bit_split_lowtohigh';

# uncomment this to run the ### lines
# use Smart::Comments '###';


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
# A057300 -- N at transpose Y,X, radix=2

{
  my $anum = 'A057300';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::ImaginaryBase->new;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      ($x, $y) = ($y, $x);
      my $n = $path->xy_to_n ($x, $y);
      push @got, $n;
    }
    $diff = diff_nums(\@got, $bvalues);
  }
  skip (! $bvalues,
        $diff, undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A163327 -- N at transpose Y,X, radix=3

{
  my $anum = 'A163327';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
  my @got;
    my $path = Math::PlanePath::ImaginaryBase->new (radix => 3);
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      ($x, $y) = ($y, $x);
      my $n = $path->xy_to_n ($x, $y);
      push @got, $n;
    }
    $diff = diff_nums(\@got, $bvalues);
  }
  skip (! $bvalues,
        $diff, undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A126006 -- N at transpose Y,X, radix=4

{
  my $anum = 'A126006';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
  my @got;
    my $path = Math::PlanePath::ImaginaryBase->new (radix => 4);
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      ($x, $y) = ($y, $x);
      my $n = $path->xy_to_n ($x, $y);
      push @got, $n;
    }
    $diff = diff_nums(\@got, $bvalues);
  }
  skip (! $bvalues,
        $diff, undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A217558 -- N at transpose Y,X, radix=16

{
  my $anum = 'A217558';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
  my @got;
    my $path = Math::PlanePath::ImaginaryBase->new (radix => 16);
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $path->n_to_xy ($n);
      ($x, $y) = ($y, $x);
      my $n = $path->xy_to_n ($x, $y);
      push @got, $n;
    }
    $diff = diff_nums(\@got, $bvalues);
  }
  skip (! $bvalues,
        $diff, undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A039724 -- negabinary positives -> index, written in binary
{
  my $anum = 'A039724';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    require Math::PlanePath::ZOrderCurve;
    my $path = Math::PlanePath::ImaginaryBase->new;
    my $zorder = Math::PlanePath::ZOrderCurve->new;

    for (my $nega = 0; @got < @$bvalues; $nega++) {
      my $n = $path->xy_to_n ($nega,0);
      $n = delete_odd_bits($n);
      push @got, to_binary($n);
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff, undef);
}

sub delete_odd_bits {
  my ($n) = @_;
  my @digits = bit_split_lowtohigh($n);
  my $bit = 1;
  my $ret = 0;
  while (@digits) {
    if (shift @digits) {
      $ret |= $bit;
    }
    shift @digits;
    $bit <<= 1;
  }
  return $ret;
}
# or by string ...
# if (length($str) & 1) { $str = "0$str" }
# $str =~ s/.(.)/$1/g;

sub to_binary {
  my ($n) = @_;
  return ($n < 0 ? '-' : '') . sprintf('%b', abs($n));
}

#------------------------------------------------------------------------------

exit 0;
