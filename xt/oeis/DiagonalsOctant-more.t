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
use Math::PlanePath::DiagonalsOctant;

use Test;
plan tests => 1;

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
# A092180 -- primes in rows, traversed by DiagonalOctant
{
  my $anum = 'A092180';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);
  my $diff;
  if ($bvalues) {
    my @got;
    require Math::PlanePath::PyramidRows;
    my $diag = Math::PlanePath::DiagonalsOctant->new(direction=>'up');
    my $rows = Math::PlanePath::PyramidRows->new(step=>1);
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $diag->n_to_xy($n);
      push @got, nthprime ($rows->xy_to_n($x,$y) - 1);
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

sub nthprime {
  my ($n) = @_;
  for (my $p = 2; ; $p++) {
    next unless is_prime($p);
    if (--$n < 0) {
      return $p;
    }
  }
}
sub is_prime {
  my ($p) = @_;
  foreach my $i (2 .. $p-1) {
    if (($p % $i) == 0) {
      return 0;
    }
  }
  return 1;
}


#------------------------------------------------------------------------------
exit 0;
