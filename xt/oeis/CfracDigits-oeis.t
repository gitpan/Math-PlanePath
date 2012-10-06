#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

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
plan tests => 14;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();

use MyOEIS;
use Math::PlanePath::CfracDigits;

use Math::PlanePath::Base::Digits
  'digit_join_lowtohigh';

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
# A032924 - N in X=1 column, ternary no digit 0

{
  my $anum = 'A032924';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $path = Math::PlanePath::CfracDigits->new;
  my $diff;
  if ($bvalues) {
    my @got;
    for (my $y = 3; @got < @$bvalues; $y++) {
      push @got, $path->xy_to_n(1,$y);
    }
    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..3]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..3]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum by path");
}


#------------------------------------------------------------------------------
exit 0;
