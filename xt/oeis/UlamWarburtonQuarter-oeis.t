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
plan tests => 6;

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use Math::PlanePath::UlamWarburtonQuarter;

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
# A147610 - 3^(count 1-bits)

{
  my $anum = 'A147610';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::UlamWarburtonQuarter->new;
    my @got;
    my $prev_depth = 0;
    my $count = 0;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my $depth = $path->tree_n_to_depth($n);
      if ($depth != $prev_depth) {
        push @got, $count;    # N end of $prev_depth
        $count = 0;
        $prev_depth = $depth;
      }
      $count++;
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
# A151920 - cumulative 3^(count 1-bits)

{
  my $anum = 'A151920';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my $path = Math::PlanePath::UlamWarburtonQuarter->new;
    my @got;
    my $prev_depth = 0;
    for (my $n = $path->n_start; @got < @$bvalues; $n++) {
      my $depth = $path->tree_n_to_depth($n);
      if ($depth != $prev_depth) {
        push @got, $n-1;    # N end of $prev_depth
        $prev_depth = $depth;
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
