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
plan tests => 18;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::ImaginaryBase;
use Math::PlanePath::Diagonals;
use Math::PlanePath::Base::Digits 'digit_split_lowtohigh';

# uncomment this to run the ### lines
#use Smart::Comments '###';


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
# A039724 -- negabinary positives -> index, written in binary
{
  my $anum = 'A039724';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  my $diff;
  if ($bvalues) {
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
  my @digits = digit_split_lowtohigh($n,2);
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
