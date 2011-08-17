#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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
BEGIN { plan tests => 2 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::CellularRule54;

# uncomment this to run the ### lines
#use Devel::Comments '###';


MyTestHelpers::diag ("OEIS dir ",MyOEIS::oeis_dir());

my $path = Math::PlanePath::CellularRule54->new;

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
# A118109 - 0/1 by rows
{
  my $anum = 'A118109';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    my $x = 0;
    my $y = 0;
    foreach my $n (1 .. @$bvalues) {
      push @got, ($path->xy_to_n ($x, $y) ? 1 : 0);
      $x++;
      if ($x > $y) {
        $y++;
        $x = -$y;
      }
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

#------------------------------------------------------------------------------
# A118108 - rows as binary bignums
{
  my $anum = 'A118108';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my @got;
  if ($bvalues) {
    require Math::BigInt;
    my $y = 0;
    foreach my $n (1 .. @$bvalues) {
      my $b = 0;
      foreach my $i (0 .. 2*$y+1) {
        if ($path->xy_to_n ($y-$i, $y)) {
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
  skip (! $bvalues,
        streq_array(\@got, $bvalues),
        1, "$anum");
}

exit 0;
