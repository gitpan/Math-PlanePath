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


use 5.010;
use strict;
use Math::PlanePath::GcdRationals;

# uncomment this to run the ### lines
use Smart::Comments;


{
  require Math::PlanePath::DiagonalsOctant;
  require Math::PlanePath::PyramidRows;
  my $diag  = Math::PlanePath::DiagonalsOctant->new;
  my $horiz = Math::PlanePath::PyramidRows->new (step => 1);
  my $gcd   = Math::PlanePath::GcdRationals->new;

  my %seen;
  my @xy;
  foreach my $n (1 .. 99) {
    my ($hx,$hy) = $horiz->n_to_xy($n) or die;
    my $dn = $diag->xy_to_n($hx,$hy) // die;

    # my ($hx,$hy) = $diag->n_to_xy($n) or die;
    # my $dn = $horiz->xy_to_n($hx,$hy) // die;

    ### at: "n=$n  hxy=$hx,$hy  dn=$dn"


    if ($seen{$dn}) {
      die "saw $dn hxy=$hx,$hy from $seen{$dn} already";
    }
    $seen{$dn} = "n=$n,hxy=$hx,$hy";

    # $dn = $n;
    my ($x,$y) = $gcd->n_to_xy($dn);
    $xy[$x][$y] = $n;
    ### store: "n=$n at $x,$y"
  }
  foreach my $y (0 .. 10) {
    foreach my $x (0 .. 10) {
      printf "%3s", $xy[$x][$y]//'.';
    }
    print "\n";
  }
  exit 0;
}

{
  my $path = Math::PlanePath::GcdRationals->new;
  require Math::Prime::XS;
  my @primes = Math::Prime::XS::sieve_primes(10000);
  my $fmax = 0;
  foreach my $y (1 .. 5000) {
    foreach my $x (1 .. 5000) {
      my $n = $path->xy_to_n($x+1,$y+1) // next;
      my $est = ($x+$y)**2 + $x;
      my $f = $est / $n;
      if ($f > $fmax + .5) {
        print "$f\n";
        $fmax = $f;
      }
    }
  }
  exit 0;
}

{
  my $path = Math::PlanePath::GcdRationals->new;
  foreach my $y (3 .. 50) {
    foreach my $x (3 .. 50) {
      my $n = $path->xy_to_n($x,$y) // next;

      my $slope = int($x/$y) + 1;
      my $g = $slope+1;
      my $fn = $x*$g + $y*$g*(($y-2)*$g + 1)/2;

      if ($n != $fn) {
        ### $n
        ### $fn
        ### $g
        ### $x
        ### $y

        my $int = int($x/$y);
        my $i = $x % $y;
        if ($i == 0) {
          $i = $y;
          $int--;
        }
        $int++;
        $i *= $int;
      }
    }
  }
  exit 0;
}

{
  my $path = Math::PlanePath::GcdRationals->new;
  foreach my $y (1 .. 500) {
    my $prev_n = 0;
    foreach my $x (1 .. 500) {
      my $n = $path->xy_to_n($x,$y) // next;
      if ($n <= $prev_n) {
        die "not monotonic $n cf $prev_n";
      }
      $prev_n = $n;
    }
  }
  exit 0;
}

{
my $path = Math::PlanePath::GcdRationals->new;
  print "N =";
  foreach my $n (1 .. 11) {
    printf "%5d", $n;
  }
  print "\n";

  print "X/Y =";
  foreach my $n (1 .. 11) {
    my ($x,$y) = $path->n_to_xy($n);
    print " $x/$y,"
  }
  print " etc\n";
  exit 0;
}
