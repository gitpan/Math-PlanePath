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
use Test;
plan tests => 2;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use List::Util 'min', 'max';
use Math::PlanePath::Hypot;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::Hypot->new;

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
# A093837 - denominators N(r) / r^2

{
  my $anum = 'A093837';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  require Math::BigRat;
  my $diff;
  if ($bvalues) {
    my @got;
    for (my $r = 1; @got < @$bvalues; $r++) {
      my $Nr = Nr($r);
      my $rsquared = $r*$r;
      my $frac = Math::BigRat->new("$Nr/$rsquared");
      push @got, $frac->denominator;
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

sub Nr {
  my ($r) = @_;
  my $n = $path->xy_to_n($r,0);
  for (;;) {
    my $m = $n+1;
    my ($x,$y) = $path->n_to_xy($m);
    if ($x*$x+$y*$y > $r*$r) {
      return $n;
    }
    $n = $m;
  }
}

#------------------------------------------------------------------------------
# A093832 - N(r) / r^2 > pi

use constant 1.02 PI => 4 * atan2(1,1);  # similar to Math::Complex

{
  my $anum = 'A093832';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum, max_value => 500);
  require Math::BigRat;
  my $diff;
  if ($bvalues) {
    my @got;
    for (my $r = 1; @got < @$bvalues; $r++) {
      my $Nr = Nr($r);
      my $rsquared = $r*$r;
      if ($Nr / $rsquared > PI) {
        push @got, $r;
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
exit 0;
