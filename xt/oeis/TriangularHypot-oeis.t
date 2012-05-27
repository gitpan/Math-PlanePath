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
BEGIN { plan tests => 2 }

use lib 't','xt';
use MyTestHelpers;
MyTestHelpers::nowarnings();
use MyOEIS;

use List::Util 'min', 'max';
use Math::PlanePath::TriangularHypot;

# uncomment this to run the ### lines
#use Smart::Comments '###';


my $path = Math::PlanePath::TriangularHypot->new;

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
# A004016 - count of points at distance n

{
  my $anum = 'A004016';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my @got;
    my $path = Math::PlanePath::TriangularHypot->new;
    my $prev_h = 0;
    my $count = 0;
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = ($x*$x + 3*$y*$y) / 4;

      # Same when rotate -45 as per POD notes.
      # ($x,$y) = (($x+$y)/2,
      #            ($y-$x)/2);
      # $h = $x*$x + $x*$y + $y*$y;

      if ($h == $prev_h) {
        $count++;
      } else {
        $got[$prev_h] = $count;
        $count = 1;
        $prev_h = $h;
      }
    }
    foreach (@got) { $_ ||= 0 }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
# A035019 - count of each hypot distance

{
  my $anum = 'A035019';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    MyTestHelpers::diag ("$anum has ",scalar(@$bvalues)," values");

    my @got;
    my $path = Math::PlanePath::TriangularHypot->new;
    my $prev_h = 0;
    my $count = 0;
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = $x*$x + 3*$y*$y;
      if ($h == $prev_h) {
        $count++;
      } else {
        push @got, $count;
        $count = 1;
        $prev_h = $h;
      }
    }

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     ",join(',',@got[0..20]));
    }
  } else {
    MyTestHelpers::diag ("$anum not available");
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
exit 0;
