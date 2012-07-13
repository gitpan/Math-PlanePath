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
plan tests => 9;

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
# A092572 - all X^2+3Y^2 values which occur, points="all" X>0,Y>0
{
  my $anum = 'A092572';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::TriangularHypot->new (points => 'all');
    my $prev_h = -1;
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      next unless ($x > 0 && $y > 0);

      my $h = $x*$x + 3*$y*$y;
      if ($h != $prev_h) {
        push @got, $h;
        $prev_h = $h;
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
# A158937 - all X^2+3Y^2 values which occur, points="all" X>0,Y>0, with repeats
{
  my $anum = 'A158937';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::TriangularHypot->new (points => 'all');
    my $prev_h = -1;
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      next unless ($x > 0 && $y > 0);

      my $h = $x*$x + 3*$y*$y;
      push @got, $h;
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
# A092573 - count of points at distance n, points="all" X>0,Y>0

{
  my $anum = 'A092573';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::TriangularHypot->new (points => 'all');
    my $prev_h = 0;
    my $count = 0;
    for (my $n = 1; @got+1 < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      next unless ($x > 0 && $y > 0);

      my $h = $x*$x + 3*$y*$y;
      if ($h == $prev_h) {
        $count++;
      } else {
        $got[$prev_h] = $count;
        $count = 1;
        $prev_h = $h;
      }
    }
    shift @got;  # drop n=0, start from n=1
    $#got = $#$bvalues;   # trim
    foreach my $i (0 .. $#$bvalues) { $got[$i] ||= 0 }  # pad

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
# A092574 - all X^2+3Y^2 values which occur, points="all" X>0,Y>0 gcd(X,Y)=1
{
  my $anum = 'A092574';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::TriangularHypot->new (points => 'all');
    my $prev_h = -1;
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      next unless ($x > 0 && $y > 0);
      next unless gcd($x,$y) == 1;

      my $h = $x*$x + 3*$y*$y;
      if ($h != $prev_h) {
        push @got, $h;
        $prev_h = $h;
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
# A092575 - count of points at distance n, points="all" X>0,Y>0 gcd(X,Y)=1

{
  my $anum = 'A092575';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::TriangularHypot->new (points => 'all');
    my $prev_h = 0;
    my $count = 0;
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      next unless ($x > 0 && $y > 0);
      next unless gcd($x,$y) == 1;

      my $h = $x*$x + 3*$y*$y;
      if ($h == $prev_h) {
        $count++;
      } else {
        $got[$prev_h] = $count;
        $count = 1;
        $prev_h = $h;
      }
    }
    shift @got;  # drop n=0, start from n=1
    $#got = $#$bvalues;   # trim
    foreach my $i (0 .. $#$bvalues) { $got[$i] ||= 0 }  # pad

    $diff = diff_nums(\@got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: len=$#$bvalues  ",join(',',@{$bvalues}[0..20]));
      MyTestHelpers::diag ("got:     len=$#got  ",join(',',@got[0..20]));
    }
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

sub gcd {
  my ($x, $y) = @_;
  #### _gcd(): "$x,$y"

  if ($y > $x) {
    $y %= $x;
  }
  for (;;) {
    if ($y <= 1) {
      return ($y == 0 ? $x : 1);
    }
    ($x,$y) = ($y, $x % $y);
  }
}

#------------------------------------------------------------------------------
# A088534 - count of points 0<=x<=y, points="even"

{
  my $anum = 'A088534';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my @got = (0) x scalar(@$bvalues);
    my $path = Math::PlanePath::TriangularHypot->new;
    my $prev_h = 0;
    my $count = 0;
    for (my $n = 1; ; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      # next unless 0 <= $x && $x <= $y;
      next unless 0 <= $y && $y <= $x/3;

      my $h = ($x*$x + 3*$y*$y) / 4;

      # Same when rotate -45 as per POD notes.
      # ($x,$y) = (($x+$y)/2,
      #            ($y-$x)/2);
      # $h = $x*$x + $x*$y + $y*$y;

      if ($h == $prev_h) {
        $count++;
      } else {
        last if $prev_h > $#$bvalues;
        $got[$prev_h] = $count;
        $count = 1;
        $prev_h = $h;
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
# A003136 - Loeschian numbers, norms of A2 lattice

{
  my $anum = 'A003136';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
    my @got;
    my $path = Math::PlanePath::TriangularHypot->new;
    my $prev_h = -1;
    for (my $n = 1; @got < @$bvalues; $n++) {
      my ($x,$y) = $path->n_to_xy($n);
      my $h = ($x*$x + 3*$y*$y) / 4;

      if ($h != $prev_h) {
        push @got, $h;
        $prev_h = $h;
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
# A004016 - count of points at distance n

{
  my $anum = 'A004016';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
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
    $#got = $#$bvalues;   # trim
    foreach my $i (0 .. $#$bvalues) { $got[$i] ||= 0 }  # pad

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
# A035019 - count of each hypot distance

{
  my $anum = 'A035019';
  my ($bvalues, $lo, $filename) = MyOEIS::read_values($anum);

  my $diff;
  if ($bvalues) {
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
  }
  skip (! $bvalues,
        $diff,
        undef,
        "$anum");
}

#------------------------------------------------------------------------------
exit 0;
