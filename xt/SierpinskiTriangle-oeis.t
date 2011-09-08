#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

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
BEGIN { plan tests => 3 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::SierpinskiTriangle;

# uncomment this to run the ### lines
#use Devel::Comments '###';


MyTestHelpers::diag ("OEIS dir ",MyOEIS::oeis_dir());

my $path = Math::PlanePath::SierpinskiTriangle->new;

sub streq_array {
  my ($a1, $a2) = @_;
  if (! ref $a1 || ! ref $a2) {
    return 0;
  }
  while (@$a1 && @$a2) {
    if ($a1->[0] ne $a2->[0]) {
      MyTestHelpers::diag ("differ: ", $a1->[0], ' ', $a2->[0]);
      return 0;
    }
    shift @$a1;
    shift @$a2;
  }
  return (@$a1 == @$a2);
}

#------------------------------------------------------------------------------
# A047999 - 1/0 by rows, without the skipped (x^y)&1==1 points of triangular
# lattice
{
  my $anum = 'A047999';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $x = 0;
    my $y = 0;
    foreach my $n (1 .. @$bvalues) {
      push @got, (defined($path->xy_to_n($x,$y)) ? 1 : 0);
      $x += 2;
      if ($x > $y) {
        $y++;
        $x = -$y;
      }
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A001317 - rows as binary bignums, without the skipped (x^y)&1==1 points of
# triangular lattice
{
  my $anum = 'A001317';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::BigInt;
    my $y = 0;
    foreach my $n (1 .. @$bvalues) {
      my $b = 0;
      foreach my $i (0 .. $y) {
        my $x = $y-2*$i;
        if (defined ($path->xy_to_n($x,$y))) {
          $b += Math::BigInt->new(2) ** $i;
        }
      }
      push @got, "$b";
      $y++;
    }
    ### @got
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A006046 - total number of points up to row N, ie. cumulative count

{
  my $anum = 'A006046';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    foreach my $y (0 .. $#$bvalues) {
      push @got, $path->xy_to_n(-$y,$y);
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  ### bvalues: join(',',@{$bvalues}[0..20])
  ### got: '    '.join(',',@got[0..20])
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

exit 0;
