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
BEGIN { plan tests => 4 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::CornerReplicate;
use Math::PlanePath::ZOrderCurve;

# uncomment this to run the ### lines
#use Smart::Comments '###';

my $crep = Math::PlanePath::CornerReplicate->new;
my $zorder = Math::PlanePath::ZOrderCurve->new;

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


#------------------------------------------------------------------------------
# A000695 -- X axis base 4 digits 0,1 only
{
  my $anum = 'A000695';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $x (0 .. $#$bvalues) {
      my $n = $crep->xy_to_n ($x, 0);
      push @got, $n;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- X axis");
}

#------------------------------------------------------------------------------
# A001196 -- Y axis
{
  my $anum = 'A001196';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $y (0 .. $#$bvalues) {
      my $n = $crep->xy_to_n (0, $y);
      push @got, $n;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- Y axis");
}

#------------------------------------------------------------------------------
# A062880 -- N diagonal
{
  my $anum = 'A062880';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    foreach my $i (0 .. $#$bvalues) {
      my $n = $crep->xy_to_n ($i, $i);
      push @got, $n;
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        numeq_array(\@got, $bvalues),
        1, "$anum -- leading diagonal");
}


#------------------------------------------------------------------------------
# A163241 -- flip base-4 digits 2,3, map to ZOrderCurve

{
  my $anum = 'A163241';
  my $radix = 2;
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");
    for (my $n = $crep->n_start; @got < @$bvalues; $n++) {
      my ($x, $y) = $crep->n_to_xy ($n);
      my $n = $zorder->xy_to_n ($x, $y);
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


#------------------------------------------------------------------------------
exit 0;
