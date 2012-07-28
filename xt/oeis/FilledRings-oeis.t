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
use Math::BigInt;
use Math::PlanePath::FilledRings;

use Test;
plan tests => 2;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

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
# A036704 -- count |z|<=n+1/2
{
  my $anum = 'A036704';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::FilledRings->new;
    for (my $x = 1; @got < @$bvalues; $x++) {
      push @got, $path->xy_to_n($x,0)-1;
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

#------------------------------------------------------------------------------
# A036708 -- half plane count n-1/2 < |z|<=n+1/2, b>=0
#            first diffs of half plane count
# N(X)/2+X-1 - (N(X-1)/2+X-1-1)
# = (N(X)-N(X-1))/2 + X-1 - X + 2
# = (N(X)-N(X-1))/2 + 1
{
  my $anum = 'A036708';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got = (1);
    my $path = Math::PlanePath::FilledRings->new;
    for (my $x = 2; @got < @$bvalues; $x++) {
      push @got, ($path->xy_to_n($x,0)-$path->xy_to_n($x-1,0))/2 + 1;
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


#------------------------------------------------------------------------------
# A036707 -- half plane count |z|<=n+1/2, b>=0
{
  my $anum = 'A036707';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::FilledRings->new;
    for (my $x = 1; @got < @$bvalues; $x++) {
      push @got, $path->xy_to_n($x,0)/2 + $x-1;
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

#------------------------------------------------------------------------------
# A036706 -- 1/4 of first diffs of N along X axis,
{
  my $anum = 'A036706';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::FilledRings->new;
    for (my $x = 1; @got < @$bvalues; $x++) {
      push @got, int (($path->xy_to_n($x,0) - $path->xy_to_n($x-1,0)) / 4);
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

#------------------------------------------------------------------------------
# A036705 -- first diffs of N along X axis,
#    count of z=a+bi satisfying n-1/2 < |z| <= n+1/2
{
  my $anum = 'A036705';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::FilledRings->new;
    for (my $x = 1; @got < @$bvalues; $x++) {
      push @got, $path->xy_to_n($x,0) - $path->xy_to_n($x-1,0);
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

#------------------------------------------------------------------------------
exit 0;
